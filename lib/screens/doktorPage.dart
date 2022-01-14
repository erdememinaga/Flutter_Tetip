import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tetip/dbControllers/authServices.dart';
import 'package:tetip/screens/doktorHastaSohbetPage.dart';
import 'package:tetip/screens/doktorProfile.dart';
import 'package:tetip/screens/rootPage.dart';

class DoktorPage extends StatefulWidget {
  User user;
  DoktorPage({this.user});
  @override
  State<DoktorPage> createState() => _DoktorPageState();
}

class _DoktorPageState extends State<DoktorPage> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<Widget> sohbetWidgetList = List<Widget>();
  List<String> sohbetHastaIds = List<String>();
  List<Map<String, String>> sohbetHastaIdsMap = List<Map<String, String>>();
  AuthServices authServices = AuthServices();

  @override
  void initState() {
    super.initState();
    //print("token :"+_firebaseMessaging.getToken().toString());
  }

  @override
  Widget build(BuildContext context) {
    //doktor anasayfasında mesajları görünmektedir
    //appbardaki butonlar ile profiline gidebilir veya çıkış yapabilir.
    Size screenSize = MediaQuery.of(context).size;

    sohbetWidgetList.clear();
    sohbetHastaIds.clear();
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("Anasayfa"),
          centerTitle: true,
          backgroundColor: Colors.indigo[500],
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DoktorProfile(user: widget.user)));
                },
                icon: Icon(Icons.person)),
            IconButton(
                onPressed: () async {
                  await authServices.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => RootPage()));
                },
                icon: Icon(Icons.logout))
          ],
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
                  future: _getSohbetler(screenSize),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return spinkit();
                    } else {
                      if (snapshot.hasError) return Center(child: Text('hata'));
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Sohbetler",
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.message,
                                    color: Colors.black,
                                    size: 25,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Column(children: sohbetWidgetList),
                        ],
                      );
                    }
                  }),
            ],
          ),
        ));
  }

  //Doktorun sohbetleri çekilir ve gerekli yerlere koyularak ekranda gösterilir
  //sohbete tıklanıldığında sohbet detayına gitmektedir.
  _getSohbetler(Size screenSize) async {
    sohbetHastaIds.clear();

    sohbetWidgetList.clear();
    await _firebaseFirestore
        .collection("doktorlar")
        .doc(widget.user.uid)
        .collection("sohbetler")
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                sohbetHastaIdsMap.add({
                  "hastaId": element.data()["hastaid"].toString(),
                  "seciliSohbetId": element.id.toString()
                });
                sohbetHastaIds.add(element.data()["hastaid"]);
              })
            });

    for (var i = 0; i < sohbetHastaIds.length; i++) {
      await _firebaseFirestore
          .collection("hastalar")
          .doc(sohbetHastaIds[i])
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
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                            ? NetworkImage(value
                                                .data()["photoUrl"]
                                                .toString())
                                            : NetworkImage(
                                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSgBhcplevwUKGRs1P-Ps8Mwf2wOwnW_R_JIA&usqp=CAU"))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Text(
                                value.data()["name"].toString().toUpperCase(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )),
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DoktorHastaSohbetPage(
                                    user: widget.user,
                                    seciliHastaId: sohbetHastaIdsMap[i]
                                        ["hastaId"],
                                    seciliSohbetId: sohbetHastaIdsMap[i]
                                        ["seciliSohbetId"],
                                    sohbetName: value.data()["name"],
                                    sohbetUrl:
                                        value.data()["photoUrl"].toString(),
                                    userToken:
                                        value.data()["userToken"].toString())));
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
