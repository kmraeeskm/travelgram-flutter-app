// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:boxicons/boxicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:travelgram/auth/user_provider.dart';

class Post {
  final String name;
  final String location;
  final String imageurl;
  final String bio;
  final String dpurl;

  Post({
    required this.name,
    required this.location,
    required this.imageurl,
    required this.bio,
    required this.dpurl,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final postDocs =
          await FirebaseFirestore.instance.collection('posts').get();

      for (var postDoc in postDocs.docs) {
        final userId = postDoc['uId'];

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        final userData = userDoc.data() as Map<String, dynamic>;
        final post = Post(
          dpurl: userData['photourl'],
          bio: postDoc['description'],
          imageurl: postDoc['imageUrl'],
          location: postDoc['location'],
          name: userData['username'],
        );
        _posts.add(post);
      }

      setState(() {});
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

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
        ],
      ),
      body: ListView.builder(
        cacheExtent: 30,
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return PostBox(
            dpurl: post.dpurl,
            bio: post.bio,
            imageurl: post.imageurl,
            location: post.location,
            name: post.name,
          );
        },
      ),
    );
  }
}

class PostBox extends StatelessWidget {
  const PostBox({
    super.key,
    required this.name,
    required this.location,
    required this.imageurl,
    required this.dpurl,
    required this.bio,
  });
  final String name;
  final String location;
  final String imageurl;
  final String bio;
  final String dpurl;

  @override
  Widget build(BuildContext context) {
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
                  Icon(Boxicons.bx_dots_horizontal),
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
                      Icon(
                        Boxicons.bx_heart,
                        color: Colors.red,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Icon(Boxicons.bx_comment),
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
