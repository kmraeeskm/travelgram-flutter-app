import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReviewModalSheet extends StatefulWidget {
  final String postID;
  final String uId;

  const ReviewModalSheet({
    super.key,
    required this.postID,
    required this.uId,
  });

  @override
  State<ReviewModalSheet> createState() => _ReviewModalSheetState();
}

class _ReviewModalSheetState extends State<ReviewModalSheet> {
  final TextEditingController commentText = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      fetchComments() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('comments')
        .doc(widget.uId)
        .collection(widget.postID)
        .get();

    final comments = querySnapshot.docs;
    if (comments.length > 0) {
      return comments;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(children: [
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  children: [
                    Text(
                      'Comments',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ),
              Row(children: [
                const Icon(Icons.toggle_off_outlined),
                const SizedBox(
                  width: 5,
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close)),
              ])
            ],
          ),
          const Divider(
            color: Color.fromARGB(255, 143, 143, 143),
          ),
          const Divider(
            color: Color.fromARGB(255, 143, 143, 143),
          ),
          FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
            future: fetchComments(),
            builder: (BuildContext context,
                AsyncSnapshot<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
                    snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData || snapshot.data == []) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text('No comments found.'),
                    ),
                  ],
                );
              } else {
                print("found data");
                print(snapshot.data);
                if (snapshot.data!.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text('No comments found.'),
                      ),
                    ],
                  );
                } else {
                  final comments = snapshot.data ?? [];
                  return Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (comments[index].id == "rating") {
                              } else {
                                final comment = comments[index].data();

                                final name = comment['comment'] as String?;
                                final text = comment['text'] as String?;

                                return ListTile(
                                  title: Text(name ?? ''),
                                  // subtitle: Text(text ?? ''),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ]),
      ),
    );
  }
}
