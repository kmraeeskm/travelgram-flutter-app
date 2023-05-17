// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stepper_counter_swipe/stepper_counter_swipe.dart';
import 'package:travelgram/screen/add_post.dart';
import 'package:travelgram/screen/date.dart';
import 'package:travelgram/utils/show_more.dart';
import 'package:uuid/uuid.dart';

class AddHotelDetails extends StatefulWidget {
  const AddHotelDetails({super.key});

  @override
  State<AddHotelDetails> createState() => _AddHotelDetailsState();
}

class _AddHotelDetailsState extends State<AddHotelDetails> {
  PlatformFile? pickedFile;
  UploadTask? task;
  PlatformFile? pickedFileMain;
  TextEditingController hotelName = TextEditingController();
  TextEditingController hotelDesc = TextEditingController();
  String c = '';
  String p = '';
  int roomCount = 0;
  bool isNAc = false;

  bool isAc = false;
  int AcC = 0;
  String lalo = '';
  int NAcC = 0;
  // File? file;
  // File? fileMain;
  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.first;

    setState(() {
      pickedFile = path;
      subImagesArray.add(
        pickedFile!.path!,
      );
    });
  }

  getUserLocation() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await GeocodingPlatform.instance
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    print(placemark);
    String city = '${placemark.locality}';
    String administrativeArea = '${placemark.administrativeArea}';
    setState(() {
      lalo = '${position.latitude} ${position.longitude}';

      c = city;
      p = administrativeArea;
    });
  }

  Future uploadHostel() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser!;
    final fileMain = File(pickedFileMain!.path!);
    String postId = const Uuid().v1();
    final destination = 'hotels/$postId';

    task = FirebaseApi.uploadFile(destination, fileMain);
    setState(() {});

    final snapshot = await task!.whenComplete(() {});
    final urlDownloadMain = await snapshot.ref.getDownloadURL();
    print(urlDownloadMain);

    try {
      _firestore.collection('hotels').doc(postId).set({
        'postId': postId,
        'uId': user.uid,
        'imageUrl': urlDownloadMain,
        'location': '$c,$p',
        'time': DateTime.now(),
        'description': hotelDesc.text,
        'name': hotelName.text,
        'roomCount': roomCount,

        // 'Ac': isAc,
        // 'NAc': isNAc,
        // 'AcC': AcC,
        // 'NAcC': NAcC,
        // 'lalo': lalo,
        // 'likes': [],
        // 'subPics': [],
      });
    } catch (e) {
      print(e.toString());
    }

    try {
      _firestore.collection('users').doc(user.uid).update({
        'hotels': FieldValue.arrayUnion([postId])
      });
    } catch (e) {
      print(e.toString());
    }

    try {
      int count = 0;
      for (var x in subImagesArray) {
        final destination = 'hotels/${postId}/${count}';
        var file = File(x);
        task = FirebaseApi.uploadFile(destination, file);
        setState(() {});

        final snapshot = await task!.whenComplete(() {});
        final urlDownload = await snapshot.ref.getDownloadURL();
        print(urlDownload);
        try {
          _firestore.collection('hotels').doc(postId).update({
            'subPics': FieldValue.arrayUnion([urlDownload])
          });
        } catch (e) {
          print(e.toString());
        }
        count += 1;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    try {
      getUserLocation();
    } catch (e) {
      print(e.toString());
    }
  }

  Future selectFileMain() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.first;

    setState(() {
      pickedFileMain = path;
    });
  }

  List<String> subImagesArray = [];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: width * 0.9,
                  height: height * 0.5,
                  child: Stack(
                    children: [
                      Positioned(
                        left: width * 0.02,
                        child: SizedBox(
                          width: width * 0.85,
                          height: height * 0.5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(80),
                            child: (pickedFileMain == null)
                                ? GestureDetector(
                                    onTap: selectFileMain,
                                    child: Image(
                                      fit: BoxFit.cover,
                                      image:
                                          AssetImage("assets/upload_photo.gif"),
                                    ),
                                  )
                                : Image.file(
                                    fit: BoxFit.cover,
                                    File(
                                      pickedFileMain!.path!,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: height * 0.15,
                          child: ListView.builder(
                            itemCount: subImagesArray.length + 1,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              print(index);
                              // print(subImagesArray[index]);
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: width * 0.3,
                                  height: height * 0.15,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: index == subImagesArray.length
                                        ? GestureDetector(
                                            onTap: selectFile,
                                            child: Image(
                                              fit: BoxFit.cover,
                                              image: AssetImage(
                                                  'assets/upload_photo.gif'),
                                            ),
                                          )
                                        : Image.file(
                                            fit: BoxFit.cover,
                                            File(subImagesArray[index]),
                                          ),
                                  ),
                                ),
                              );
                              ;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: hotelName,
                  decoration: InputDecoration(
                    hintText: 'Hotel Name',
                    border: InputBorder.none,
                  ),
                ),
                Text("$c, $p"),
                // ExpandableShowMoreWidget(
                //   text:
                //       ' to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10',
                //   height: 150,
                // )
                TextField(
                  maxLines: 3,
                  controller: hotelDesc,
                  decoration: InputDecoration(
                    hintText: 'Say something',
                    border: InputBorder.none,
                  ),
                ),

                // Container(
                //   padding: const EdgeInsets.all(2.0),
                //   child: Row(
                //     children: [
                //       SizedBox(
                //         width: 58,
                //       ),
                //       Text('AC'),
                //       SizedBox(
                //         width: 10,
                //       ),
                //       Container(
                //         height: 60,
                //         child: MSHCheckbox(
                //           size: 40,
                //           value: isAc,
                //           colorConfig:
                //               MSHColorConfig.fromCheckedUncheckedDisabled(
                //             checkedColor: Colors.blue,
                //           ),
                //           style: MSHCheckboxStyle.stroke,
                //           onChanged: (selected) {
                //             setState(() {
                //               isAc = selected;
                //             });
                //           },
                //         ),
                //       ),
                //       SizedBox(
                //         width: 20,
                //       ),
                //       Text('Non AC'),
                //       SizedBox(
                //         width: 10,
                //       ),
                //       Container(
                //         height: 60,
                //         child: MSHCheckbox(
                //           size: 40,
                //           value: isNAc,
                //           colorConfig:
                //               MSHColorConfig.fromCheckedUncheckedDisabled(
                //             checkedColor: Colors.blue,
                //           ),
                //           style: MSHCheckboxStyle.stroke,
                //           onChanged: (selected) {
                //             setState(() {
                //               isNAc = selected;
                //             });
                //           },
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Container(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    children: [
                      Text('Rooms'),
                      // isAc
                      //     ? Container(
                      //         height: 60,
                      //         child: StepperSwipe(
                      //           stepperValue: 80,
                      //           initialValue: 0,
                      //           withPlusMinus: true,
                      //           withFastCount: true,
                      //           speedTransitionLimitCount: 40,
                      //           onChanged: (int value) =>
                      //               print('new value $value'),
                      //           firstIncrementDuration:
                      //               Duration(milliseconds: 250),
                      //           secondIncrementDuration:
                      //               Duration(microseconds: 1),
                      //           direction: Axis.horizontal,
                      //           dragButtonColor: Color(0xFFbd91d4),
                      //           maxValue: 500,
                      //           minValue: 0,
                      //         ),
                      //       )
                      //     : SizedBox(
                      //         width: 80,
                      //       ),
                      // isNAc
                      //     ?
                      Container(
                        height: 60,
                        child: StepperSwipe(
                          stepperValue: 10,
                          initialValue: 0,
                          withPlusMinus: true,
                          withFastCount: true,
                          speedTransitionLimitCount: 40,
                          onChanged: (int value) {
                            roomCount = value;
                          },
                          firstIncrementDuration: Duration(milliseconds: 250),
                          secondIncrementDuration: Duration(microseconds: 1),
                          direction: Axis.horizontal,
                          dragButtonColor: Color(0xFFbd91d4),
                          maxValue: 500,
                          minValue: 0,
                        ),
                      )
                      // :
                      //  SizedBox(
                      //     width: 20,
                      //   ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 10,
                  ),
                  color: Colors.white,
                  height: 80,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            uploadHostel();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.black,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Register Hotel',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
