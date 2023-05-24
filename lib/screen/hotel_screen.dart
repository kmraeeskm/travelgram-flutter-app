// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:boxicons/boxicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:travelgram/auth/auth_methods.dart';
import 'package:travelgram/auth/firestoremethods.dart';
import 'package:travelgram/auth/user_provider.dart';
import 'package:travelgram/screen/bookings_page.dart';
import 'package:travelgram/screen/comment_modal_sheet.dart';
import 'package:travelgram/screen/hotel/hotel_details.dart';
import 'package:travelgram/utils/show_more.dart';

class HotelScreen extends StatefulWidget {
  const HotelScreen({Key? key});

  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

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
          GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => BookingsPage()));
            },
            child: AppBarIcon(
              iconData: CupertinoIcons.ticket,
              color: Colors.white,
              iconColor: Colors.black,
            ),
          ),
          SizedBox(
            width: 16,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text.rich(
              TextSpan(
                text: 'Find best hotels for\n',
                style: TextStyle(
                  fontSize: height * 0.035,
                ),
                children: [
                  TextSpan(
                    text: 'Your Special Moments!\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: height * 0.04,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: height * 0.65,
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('hotels').get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    cacheExtent: 30,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      print(snapshot.data!.docs[index].data());
                      var post = snapshot.data!.docs[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => HotelDetails(
                                snap: post,
                              ),
                            ),
                          );
                        },
                        child: PostBox(
                          pid: post['postId'],
                          dpurl: post['imageUrl'],
                          bio: post['description'],
                          imageurl: post['imageUrl'],
                          location: post['location'],
                          name: post['name'],
                          rate: post['rate'],
                        ),
                      );
                    },
                  );
                }
                return Container();
              },
            ),
          ),
        ],
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
    required this.rate,
  });
  final String name;
  final String location;
  final String imageurl;
  final String bio;
  final String dpurl;
  final int rate;

  final String pid;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
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
        androidBarrierDismissible: true,
        context: context,
        builder: (_) => BasicDialogAlert(
          title: Text("Select action"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildListItem("Get Reccomendations"),
                _buildListItem("Share"),
                _buildListItem("Report"),
              ],
            ),
          ),
          actions: <Widget>[
            // BasicDialogAction(
            //   title: Text("Cancel"),
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            // ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16,
        bottom: 32,
      ),
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
          padding: const EdgeInsets.all(6.0),
          child: SizedBox(
            width: width * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  height: 12,
                ),
                Stack(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: width * 0.7,
                      width: width * 0.7,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: imageurl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromARGB(218, 241, 241, 241)),
                        height: height * 0.06,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    child: Text('₹ $rate'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Text(
                  bio,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                // ExpandableShowMoreWidget(
                //   text: bio,
                //   height: 50,
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('hotels')
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
                                              .collection('hotels')
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
                                      color:
                                          isLiked ? Colors.red : Colors.black,
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
                    StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          bool containsPostId = false;
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          final bookmarksExists =
                              data != null && data.containsKey('bookmarks');

                          // Do something with the bookmarks list
                          if (bookmarksExists) {
                            containsPostId =
                                data['bookmarks'].contains(pid) ? true : false;
                            return IconButton(
                              onPressed: () {
                                fireStoreMethods()
                                    .bookmark(pid, data['bookmarks']);
                              },
                              icon: Icon(Boxicons.bx_bookmark,
                                  color: containsPostId
                                      ? Colors.red
                                      : Colors.black),
                            );
                          }
                          return IconButton(
                            onPressed: () {
                              fireStoreMethods().bookmark(pid, []);
                            },
                            icon:
                                Icon(Boxicons.bx_bookmark, color: Colors.black),
                          );
                        }),
                  ],
                ),
              ],
            ),
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
