
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'doktorPage.dart';
import 'hastaPage.dart';
import 'loginPage.dart';
class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  void initState() {
    super.initState();

    //current user metodu daha önce sisteme giriş yapmış bir kullanıcı var mı onu kontrol eder.
    currentUser();

//firebase messasing için config
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
    );
  }
  //gerekli initializerlar
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.lightGreenAccent[50], body: _kontrol());
  }

// User varsa bu userın hasta mı doktor mu olduu kontrol edilerek gerekli sayfaya yönlendirme yapılır.
  void currentUser()async {
    User user = await _firebaseAuth.currentUser;
    if (user!=null) {
      String kontrol,userToken;
     await _firebaseMessaging.getToken().then((val) {
                  userToken = val.toString();
                });
      await FirebaseFirestore.instance
          .collection("hastalar")
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          if (user.uid == result.id) {
            kontrol = "hasta";
          }
        });
      });
      if (kontrol == "hasta") {
        await FirebaseFirestore.instance.collection("hastalar").doc(user.uid).update({
          "userToken": userToken
        });
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HastaPage(user: user)));
      } else {
         await FirebaseFirestore.instance.collection("doktorlar").doc(user.uid).update({
          "userToken": userToken
        });
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DoktorPage(user: user)));
      }
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }

  }

  _kontrol() {}
}
