import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tetip/screens/doktorDalEklePage.dart';
import 'package:tetip/screens/doktorProfileEdit.dart';

class DoktorProfile extends StatefulWidget {
  User user;
  DoktorProfile({this.user});
  @override
  State<DoktorProfile> createState() => _DoktorProfileState();
}

class _DoktorProfileState extends State<DoktorProfile> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<Widget> dallarWidgetList = List<Widget>();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  List<String> dallarList = List<String>();
  String profileImageUrl = "", name, surName, email;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    // TODO: implement build
    dallarWidgetList.clear();
    dallarList.clear();
    return FutureBuilder<Object>(
        future: _getDoktorProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return spinkit();
          } else {
            if (snapshot.hasError) return Center(child: Text('hata'));
            return Scaffold(
              appBar: AppBar(
                title: Text("Profil"),
                backgroundColor: Colors.indigo[500],
              ),
              body: Stack(
                children: [
                  Container(
                    width: screenSize.width,
                    height: screenSize.height,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.orange[300], Colors.cyan[300]])),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: InkWell(
                              onTap: () async {
                                FilePickerResult result =
                                    await FilePicker.platform.pickFiles();

                                if (result != null) {
                                  File file = File(result.files.single.path);
                                  Reference reference = _firebaseStorage
                                      .ref()
                                      .child("${widget.user.uid}");
                                  UploadTask task = reference.putFile(file);
                                  await task.whenComplete(() async {
                                    try {
                                      String profileUrl =
                                          await reference.getDownloadURL();
                                      print("profile url download link : " +
                                          profileUrl);
                                      setState(() {
                                        profileImageUrl = profileUrl;
                                      });
                                      _firebaseFirestore
                                          .collection("doktorlar")
                                          .doc(widget.user.uid)
                                          .update(
                                              {"photoUrl": profileImageUrl});
                                    } catch (onError) {
                                      print("Error");
                                    }
                                  });
                                } else {
                                  // User canceled the picker
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    border: Border.all(
                                        width: 2, color: Colors.indigo),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: profileImageUrl != ""
                                            ? NetworkImage(profileImageUrl)
                                            : NetworkImage(
                                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSgBhcplevwUKGRs1P-Ps8Mwf2wOwnW_R_JIA&usqp=CAU")),
                                  ),
                                  height: screenSize.height / 4,
                                  width: screenSize.height / 4,
                                ),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0, bottom: 20),
                          child: Text(
                            "Kişisel Bilgiler",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w800),
                          ),
                        ),
                        FutureBuilder<Object>(
                            future: _getDoktorBilimDallar(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return spinkit();
                              } else {
                                if (snapshot.hasError)
                                  return Center(child: Text('hata'));
                                return Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: screenSize.width / 1.4,
                                        decoration: BoxDecoration(
                                            color: Colors.indigo[100],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all()),
                                        child: Column(
                                          children: [
                                            _propWidget("İsim", name),
                                            Divider(),
                                            _propWidget("Soyisim", surName),
                                            Divider(),
                                            _propWidget("Email", email),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: screenSize.width / 1.4,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Column(
                                                  children: [
                                                    Icon(Icons.edit),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              DoktorProfileEdit(
                                                                  user: widget
                                                                      .user,
                                                                  name: name,
                                                                  surName:
                                                                      surName)));
                                                },
                                              )
                                            ]),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: Text(
                                          "Uzmanlık Alanları",
                                          style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                      Container(
                                        width: screenSize.width / 1.4,
                                        height: screenSize.height / 6,
                                        decoration: BoxDecoration(
                                            color: Colors.indigo[100],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all()),
                                        child: Scrollbar(
                                          child: SingleChildScrollView(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                  children: dallarWidgetList),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: screenSize.width / 1.4,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Column(
                                                  children: [Icon(Icons.add)],
                                                ),
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              DoktorDalEkle(
                                                                  user: widget
                                                                      .user,
                                                                  dallarList:
                                                                      dallarList)));
                                                },
                                              )
                                            ]),
                                      )
                                    ],
                                  ),
                                );
                              }
                            })
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  //Doktorun anabilimdalları çekilir ve gösterilir.
  _getDoktorBilimDallar() async {
    dallarWidgetList.clear();
    await _firebaseFirestore
        .collection("doktorlar")
        .doc(widget.user.uid)
        .collection("dallar")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        print(element.data()["dal"]);
        dallarList.add(element.data()["dal"]);
        dallarWidgetList.add(Column(
          children: [
            ListTile(
              title: Text(element.data()["dal"].toString()),
            ),
            Divider()
          ],
        ));
      });
    });
  }

  //Doktor profil bilgileri çekilir ve gerekli yerlere taşınır.
  _getDoktorProfile() async {
    dallarWidgetList.clear();
    dallarList.clear();
    await _firebaseFirestore
        .collection("doktorlar")
        .doc(widget.user.uid)
        .get()
        .then((value) => {
              if (value.data()["photoUrl"] != null)
                {
                  profileImageUrl = value.data()["photoUrl"],
                },
              name = value.data()["name"],
              surName = value.data()["surName"],
              email = value.data()["email"]
            });
  }

  _propWidget(String prop1, String prop2) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ListTile(
        title: Row(
          children: [
            Text(prop1 + ": ", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(prop2),
          ],
        ),
      ),
    );
  }

  Widget spinkit() {
    return Center(
        child: SpinKitFadingCircle(
      size: 65,
      itemBuilder: (BuildContext context, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: index.isEven ? Colors.indigo : Colors.orange,
          ),
        );
      },
    ));
  }
}
