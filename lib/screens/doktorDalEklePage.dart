import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tetip/screens/doktorProfile.dart';

class DoktorDalEkle extends StatefulWidget {
  User user;
  List<String> dallarList;
  DoktorDalEkle({this.user, this.dallarList});
  @override
  State<DoktorDalEkle> createState() => _DoktorDalEkleState();
}

class _DoktorDalEkleState extends State<DoktorDalEkle> {
  //doktor uzmanlık alanlarına yeni uzmanlık alanları ekleyebilir.
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  List<Widget> dallarWidgetList = List<Widget>();
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    dallarWidgetList.clear();
    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DoktorProfile(user: widget.user)));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Dal Ekle"),
          backgroundColor: Colors.indigo[500],
        ),
        body: FutureBuilder<Object>(
            future: getDallar(screenSize),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return spinkit();
              } else {
                if (snapshot.hasError) return Center(child: Text('hata'));
                return SingleChildScrollView(
                  child: Stack(
                    children: [
                      Container(
                        width: screenSize.width,
                        height: screenSize.height,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                          Colors.orange[300],
                          Colors.cyan[300]
                        ])),
                      ),
                      Column(
                        children: dallarWidgetList,
                      ),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }

  //Sistemde kayıtlı olan tüm dallar çekilir ve doktor istediği dalları kendi uzmanlık
  //alanlarına ekleyebilir
  getDallar(Size screenSize) async {
    dallarWidgetList.clear();
    await _firebaseFirestore
        .collection("anabilimdallari")
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                bool kontrol = true;
                for (var i = 0; i < widget.dallarList.length; i++) {
                  if (widget.dallarList[i] == element.data()["dal"]) {
                    kontrol = false;
                    print(widget.dallarList[i] + element.data()["dal"]);
                  }
                }
                if (kontrol) {
                  dallarWidgetList.add(Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: screenSize.width,
                      height: screenSize.height / 10,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.indigoAccent,
                          border: Border.all()),
                      child: InkWell(
                          child: Center(
                              child: Text(
                            element.data()["dal"].toString().toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )),
                          onTap: () async {
                            await _firebaseFirestore
                                .collection("doktorlar")
                                .doc(widget.user.uid)
                                .collection("dallar")
                                .add({"dal": element.data()["dal"]});
                            await _firebaseFirestore
                                .collection("anabilimdallari")
                                .doc(element.id)
                                .collection("doktorlar")
                                .add({"doktorid": widget.user.uid});
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DoktorProfile(user: widget.user)));
                          }),
                    ),
                  ));
                }
              })
            });
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

///
///
