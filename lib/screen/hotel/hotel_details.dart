// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelgram/screen/add_post.dart';
import 'package:travelgram/screen/date.dart';
import 'package:travelgram/screen/home_screen.dart';
import 'package:travelgram/screen/hotel/booking_confirm.dart';
import 'package:travelgram/utils/show_more.dart';
import 'package:uuid/uuid.dart';

class HotelDetails extends StatefulWidget {
  var snap;
  HotelDetails({super.key, required this.snap});

  @override
  State<HotelDetails> createState() => _HotelDetailsState();
}

class _HotelDetailsState extends State<HotelDetails> {
  List<DateTime> _disabledDates = [
    DateTime.now().add(Duration(days: 1)),
    DateTime.now().add(Duration(days: 2)),
    DateTime.now().add(Duration(days: 3)),
  ];
  DateTime? startDate;
  DateTime? endDate;
  Future uploadHostel() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser!;
    String BookingId = const Uuid().v1();

    try {
      _firestore.collection('bookings').doc(BookingId).set({
        'bookingId': BookingId,
        'uId': user.uid,
        'hostelId': widget.snap['postId'],
        'time': DateTime.now(),
        'dates': '$startDate - $endDate'
      });
    } catch (e) {
      print(e.toString());
    }

    try {
      _firestore.collection('hotels').doc(widget.snap['postId']).update({
        'bookings': FieldValue.arrayUnion([BookingId])
      });
    } catch (e) {
      print(e.toString());
    }
  }

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
                          width: width * 0.9,
                          height: height * 0.5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                widget.snap['imageUrl'],
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
                            itemCount: 4,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return HotelExtras(
                                width: width,
                                height: height,
                                url: widget.snap['subPics'][0],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(widget.snap['name']),
                Text(widget.snap['location']),
                ExpandableShowMoreWidget(
                  text: widget.snap['description'],
                  height: 150,
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 10,
        ),
        color: Colors.white,
        height: 80,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[200],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.heart_broken),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showCustomDateRangePicker(
                    context,
                    dismissible: true,
                    minimumDate:
                        DateTime.now().subtract(const Duration(days: 30)),
                    maximumDate: DateTime.now().add(const Duration(days: 30)),
                    endDate: endDate,
                    startDate: startDate,
                    backgroundColor: Colors.white,
                    primaryColor: Color.fromARGB(255, 204, 89, 127),
                    onApplyClick: (start, end) async {
                      setState(() {
                        endDate = end;
                        startDate = start;
                      });
                      await uploadHostel();
                      Navigator.of(context).pop();
                    },
                    onCancelClick: () {
                      setState(() {
                        endDate = null;
                        startDate = null;
                      });
                    },
                  );
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
                        'Book now',
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
    );
  }
}

class HotelExtras extends StatelessWidget {
  const HotelExtras({
    super.key,
    required this.width,
    required this.height,
    required this.url,
  });

  final double width;
  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: width * 0.3,
        height: height * 0.15,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image(
            fit: BoxFit.cover,
            image: NetworkImage(
              url,
            ),
          ),
        ),
      ),
    );
  }
}
