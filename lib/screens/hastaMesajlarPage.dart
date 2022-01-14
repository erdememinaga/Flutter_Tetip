import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tetip/dbControllers/authServices.dart';
import 'package:tetip/screens/doktorHastaSohbetPage.dart';
import 'package:tetip/screens/doktorProfile.dart';
import 'package:tetip/screens/hastaDoktorSohbetPage.dart';
import 'package:tetip/screens/rootPage.dart';

class HastaMesajlarPage extends StatefulWidget {
  User user;
  HastaMesajlarPage({this.user});
  @override
  State<HastaMesajlarPage> createState() => _HastaMesajlarPageState();
}

class _HastaMesajlarPageState extends State<HastaMesajlarPage> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<Widget> sohbetWidgetList = List<Widget>();
  List<String> doktorIds = List<String>();
  List<Map<String, String>> sohbetDoktorIdsMap = List<Map<String, String>>();
  AuthServices authServices = AuthServices();
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("Mesajlar"),
          backgroundColor: Colors.indigo[500],
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: screenSize.width,
                height: screenSize.height,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.orange[300], Colors.cyan[300]])),
              ),
              FutureBuilder<Object>(
                  //burada Futurebuilder ile hasta sohbetlerinin async olarak gelmesi sağlanmaktadır
                  future: _getSohbetler(screenSize),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return spinkit();
                    } else {
                      if (snapshot.hasError) return Center(child: Text('hata'));
                      return sohbetWidgetList.length == 0
                          ? Center(child: Text("Hata"))
                          : Column(children: sohbetWidgetList);
                    }
                  }),
            ],
          ),
        ));
  }

  //bu metod ile sohbetler çekilir gösterilir.f
  _getSohbetler(Size screenSize) async {
    sohbetWidgetList.clear();
    sohbetDoktorIdsMap.clear();
    doktorIds.clear();
    await _firebaseFirestore.collection("doktorlar").get().then((value) => {
          value.docs.forEach((element) async {
            print(element.data());
            doktorIds.add(element.id);
          })
        });
    for (var i = 0; i < doktorIds.length; i++) {
      await _firebaseFirestore
          .collection("doktorlar")
          .doc(doktorIds[i])
          .collection("sohbetler")
          .get()
          .then((elementValue) => {
                elementValue.docs.forEach((elementValueElement) {
                  if (widget.user.uid ==
                      elementValueElement.data()["hastaid"]) {
                    print("doktorid : " +
                        doktorIds[i].toString() +
                        " , " +
                        "hastaid : " +
                        elementValueElement.data()["hastaid"] +
                        " , " +
                        "sohbetid : " +
                        elementValueElement.id.toString());
                    sohbetDoktorIdsMap.add({
                      "doktorid": doktorIds[i].toString(),
                      "hastaid":
                          elementValueElement.data()["hastaid"].toString(),
                      "sohbetid": elementValueElement.id.toString(),
                    });
                  }
                })
              });
    }

    for (var i = 0; i < sohbetDoktorIdsMap.length; i++) {
      await _firebaseFirestore
          .collection("doktorlar")
          .doc(sohbetDoktorIdsMap[i]["doktorid"])
          .get()
          .then((value) => {
                sohbetWidgetList.add(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: screenSize.width,
                    height: screenSize.height / 8,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.indigoAccent,
                        border: Border.all()),
                    child: InkWell(
                      child: Center(
                          child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: value
                                                  .data()["photoUrl"]
                                                  .toString() !=
                                              "null"
                                          ? NetworkImage(
                                              value.data()["photoUrl"])
                                          : NetworkImage(
                                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSgBhcplevwUKGRs1P-Ps8Mwf2wOwnW_R_JIA&usqp=CAU"))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(
                              value
                                      .data()["name"]
                                      .toString()
                                      .toUpperCase()
                                      .toString()
                                      .toUpperCase() +
                                  " " +
                                  value
                                      .data()["surName"]
                                      .toString()
                                      .toUpperCase()
                                      .toString()
                                      .toUpperCase() +
                                  " (" +
                                  value.data()["email"] +
                                  ")",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      )),
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HastaDoktorSohbetPage(
                                      user: widget.user,
                                      seciliDoktorId: sohbetDoktorIdsMap[i]
                                          ["doktorid"],
                                      seciliSohbetId: sohbetDoktorIdsMap[i]
                                          ["sohbetid"],
                                      sohbetName: value.data()["name"],
                                      sohbetUrl:
                                          value.data()["photoUrl"].toString(),
                                      userToken: value.data()["userToken"],
                                    )));
                      },
                    ),
                  ),
                ))
              });
    }
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
