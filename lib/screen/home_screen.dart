// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:boxicons/boxicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:travelgram/auth/user_provider.dart';
import 'package:travelgram/screen/comment_modal_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userModel = userProvider.userModel;
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          'Travelgram',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          AppBarIcon(
            iconData: Boxicons.bx_bell,
            color: Colors.white,
            iconColor: Colors.black,
          ),
          SizedBox(
            width: 16,
          ),
          AppBarIcon(
            iconData: Boxicons.bx_message,
            color: Colors.white,
            iconColor: Colors.black,
          ),
          SizedBox(
            width: 16,
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('posts').get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              cacheExtent: 30,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var post = snapshot.data!.docs[index];

                return PostBox(
                  pid: post['postId'],
                  dpurl: post['proPic'],
                  bio: post['description'],
                  imageurl: post['imageUrl'],
                  location: post['location'],
                  name: post['name'],
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}

class PostBox extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;

  PostBox({
    super.key,
    required this.name,
    required this.location,
    required this.imageurl,
    required this.dpurl,
    required this.bio,
    required this.pid,
  });
  final String name;
  final String location;
  final String imageurl;
  final String bio;
  final String dpurl;
  final String pid;

  @override
  Widget build(BuildContext context) {
    Widget _buildListItem(String title) {
      return Column(
        children: [
          Container(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(child: Text(title)),
              ],
            ),
          ),
          const Divider(height: 0.5),
        ],
      );
    }

    _showListAlert(BuildContext context) {
      showPlatformDialog(
        context: context,
        builder: (_) => BasicDialogAlert(
          title: Text("Select action"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildListItem("Share"),
                _buildListItem("Report"),
              ],
            ),
          ),
          actions: <Widget>[
            BasicDialogAction(
              title: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 236, 236, 236),
                spreadRadius: 3,
                blurRadius: 4,
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: ClipOval(
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: dpurl,
                            fit: BoxFit.cover,
                            width: 36,
                            height: 36,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name),
                          Text(
                            location,
                            style: TextStyle(
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                      onTap: () {
                        _showListAlert(context);
                      },
                      child: Icon(Boxicons.bx_dots_horizontal)),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                height: 400,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: imageurl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(bio),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .doc(pid)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            Map<String, dynamic> data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            int likesCount = data['likes'] != null
                                ? data['likes'].length
                                : 0;
                            bool isLiked = data['likes'] != null
                                ? data['likes'].contains(user.uid)
                                : false;
                            return Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    DocumentReference postRef =
                                        FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(pid);
                                    if (isLiked) {
                                      postRef.update({
                                        'likes':
                                            FieldValue.arrayRemove([user.uid])
                                      });
                                    } else {
                                      postRef.update({
                                        'likes':
                                            FieldValue.arrayUnion([user.uid])
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    Boxicons.bx_heart,
                                    color: isLiked ? Colors.red : Colors.black,
                                  ),
                                ),
                                Text('$likesCount')
                              ],
                            );
                          }),
                      SizedBox(
                        width: 16,
                      ),
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('comments')
                            .doc(pid)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<
                                    DocumentSnapshot<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.hasData) {
                            final comments = snapshot.data!.data();
                            if (comments != null &&
                                comments.containsKey('comments')) {
                              final commentsList =
                                  comments['comments'] as List<dynamic>;
                              final numComments = commentsList.length;
                              return Column(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          context: context,
                                          builder: (context) {
                                            return CommentModalSheet(
                                              postID: pid,
                                              name: name,
                                            );
                                          });
                                    },
                                    icon: Icon(Boxicons.bx_comment),
                                  ),
                                  Text(numComments.toString()),
                                ],
                              );
                            }
                          }
                          // Return a default value if the document does not exist
                          return Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  print("what");
                                  showModalBottomSheet(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      context: context,
                                      builder: (context) {
                                        return CommentModalSheet(
                                          postID: pid,
                                          name: name,
                                        );
                                      });
                                },
                                icon: Icon(Boxicons.bx_comment),
                              ),
                              Text('0'),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  Icon(Boxicons.bx_bookmark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBarIcon extends StatelessWidget {
  const AppBarIcon({
    super.key,
    required this.iconData,
    required this.color,
    required this.iconColor,
  });
  final IconData iconData;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 236, 236, 236),
            spreadRadius: 3,
            blurRadius: 4,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          iconData,
          color: iconColor,
        ),
      ),
    );
  }
}
