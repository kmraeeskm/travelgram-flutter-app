// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:boxicons/boxicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:travelgram/auth/auth_methods.dart';
import 'package:travelgram/auth/user_provider.dart';
import 'package:travelgram/screen/home_screen.dart';
import 'package:travelgram/screen/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;
  List<dynamic> postIDsOfUser = [];
  List<QueryDocumentSnapshot> documents = [];
  void signOutUser() async {
    await authmethods().signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => loginscreen(),
      ),
    );
  }

  Future getpostIDsOfUser() async {
    await _firestore.collection('users').doc(user.uid).get().then((doc) {
      postIDsOfUser = doc.data()!['posts'];
    });
  }

  Future getPosts(List<dynamic> postIds) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    List<Future<QuerySnapshot>> futures = [];

    for (String id in postIds) {
      futures.add(
          _firestore.collection('posts').where('postId', isEqualTo: id).get());
    }

    List<QuerySnapshot> snapshots = await Future.wait(futures);

    documents = [];

    for (QuerySnapshot snapshot in snapshots) {
      print(snapshot.docs.first);

      try {
        documents.add(snapshot.docs.first);
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userModel = userProvider.userModel;

    return Scaffold(
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.maxFinite,
                    child: Image(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                          'https://images.pexels.com/photos/2876511/pexels-photo-2876511.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Transform.translate(
                        offset: Offset(0, 30),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                userModel!.photourl,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          signOutUser();
                        },
                        child: Text('Account settings'),
                      ),
                      Text(
                        userModel.username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          signOutUser();
                        },
                        child: Text('Log out'),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                ],
              ),
              Expanded(
                child: FutureBuilder(
                  future: getpostIDsOfUser(),
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }
                    if (postIDsOfUser.isEmpty) {
                      return Center(
                        child: Text('No posts found.'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Column(
                        children: [
                          Expanded(
                            child: FutureBuilder(
                              future: getPosts(postIDsOfUser),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: LoadingAnimationWidget.waveDots(
                                        color: Colors.white, size: 40),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.done) {}

                                return MasonryGridView.builder(
                                    itemCount: documents.length,
                                    gridDelegate:
                                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                    ),
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> data =
                                          documents[index].data()
                                              as Map<String, dynamic>;
                                      print('data');
                                      print(data);
                                      return Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child:
                                              Image.network(data['imageUrl']),
                                        ),
                                      );
                                    });
                              },
                            ),
                          ),
                        ],
                      );
                    }
                    return Container();
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
