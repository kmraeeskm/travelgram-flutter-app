// ignore_for_file: prefer_const_constructors

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class RecieverBox extends StatefulWidget {
  RecieverBox({super.key, required this.message, required this.type});
  final String message;
  final String type;

  @override
  State<RecieverBox> createState() => _RecieverBoxState();
}

class _RecieverBoxState extends State<RecieverBox> {
  final audioPlayer = AudioPlayer();
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isplaying = false;
  final user = FirebaseAuth.instance.currentUser!;

  Future<String> getImageUrl(String uid) async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final imageUrl = userSnapshot.data()?['photourl'] as String?;
    return imageUrl ?? 'https://example.com/default-image.png';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 10,
        ),
        widget.type == 'text'
            ? Flexible(
                child: Container(
                  width: 200,
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 223, 224, 226),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                        child: Text(
                      widget.message,
                    )),
                  ),
                ),
              )
            : Container(
                width: 200,
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 223, 224, 226),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    )),
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: StatefulBuilder(builder: (context, setState) {
                      return Container(
                        width: width * 0.58,
                        padding: EdgeInsets.only(top: 3),
                        child: Row(
                          children: [
                            IconButton(
                              constraints: const BoxConstraints(
                                minWidth: 50,
                              ),
                              onPressed: () async {
                                if (isplaying) {
                                  await audioPlayer.pause();
                                  setState(() {
                                    isplaying = false;
                                  });
                                } else {
                                  audioPlayer.onDurationChanged
                                      .listen((Duration duration) {
                                    setState(() => _duration = duration);
                                  });
                                  audioPlayer.onPositionChanged
                                      .listen((Duration position) {
                                    setState(() => _position = position);
                                  });
                                  audioPlayer.onPlayerStateChanged
                                      .listen((state) {
                                    if (state == PlayerState.completed) {
                                      setState(() {
                                        _position = Duration();
                                        isplaying = false;
                                      });
                                    }
                                  });

                                  await audioPlayer
                                      .play(UrlSource(widget.message));
                                  setState(() {
                                    isplaying = true;
                                  });
                                }
                              },
                              icon: Icon(
                                isplaying
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                              ),
                            ),
                            SizedBox(
                              width: width * 0.27,
                              child: ProgressBar(
                                progress: _position,
                                buffered: _duration,
                                total: _duration,
                                progressBarColor: Colors.red,
                                baseBarColor: Colors.white.withOpacity(0.24),
                                onSeek: (Duration duration) {
                                  audioPlayer.seek(duration);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    })),
              ),
        SizedBox(
          width: 10,
        ),
        FutureBuilder<String>(
          future: getImageUrl(FirebaseAuth.instance.currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircleAvatar(
                radius: 20,
                backgroundColor: Color.fromARGB(255, 221, 221, 221),
              ); // Placeholder while loading
            } else if (snapshot.hasError) {
              return CircleAvatar(
                backgroundColor: Colors.white,
                child:
                    Icon(Icons.error), // Display error icon if there's an error
              );
            } else {
              return CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(snapshot.data!),
                radius: 20,
              );
            }
          },
        ),
      ],
    );
  }
}
