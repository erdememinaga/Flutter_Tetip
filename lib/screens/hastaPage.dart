import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tetip/dbControllers/authServices.dart';
import 'package:tetip/screens/bilimDallarPage.dart';
import 'package:tetip/screens/hastaMesajlarPage.dart';
import 'package:tetip/screens/hastaProfile.dart';
import 'package:tetip/screens/rootPage.dart';

class HastaPage extends StatefulWidget {
  User user;
  HastaPage({this.user});
  @override
  State<HastaPage> createState() => _HastaPageState();
}

class _HastaPageState extends State<HastaPage> {
  AuthServices authServices = AuthServices();
  @override
  void initState() {
    super.initState();
  }

//Hasta anasayfasıdır sağ üstteki butonlar ile porfiline gidebilir veya çıkış yapabilir.
//hizmet al butonu ile hizmet alma sayfasına gidebilir.
//mesajlarım butonu ile önceki mesajlaşmalarını görebilir.
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
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
                              HastaProfile(user: widget.user)));
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
        body: Stack(
          children: [
            Container(
              width: screenSize.width,
              height: screenSize.height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.orange[300], Colors.cyan[300]])),
            ),
            Center(
              child: Container(
                height: screenSize.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _hizmetButton(screenSize),
                    _mesajlarButton(screenSize),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  _hizmetButton(Size screenSize) {
    return Material(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(width: 3, color: Colors.blueGrey[600])),
      elevation: 5,
      child: Container(
        height: screenSize.height / 2.8,
        width: screenSize.width / 2.2,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(colors: [Colors.orange, Colors.green])),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            //sayfa yönlendirmesi
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BilimDallarPage(user: widget.user)));
          },
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: screenSize.width / 2.6,
                  height: screenSize.width / 2.6,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/hizmet.png"),
                          fit: BoxFit.cover)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Hizmet Al",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                )
              ]),
        ),
      ),
    );
  }

  _mesajlarButton(Size screenSize) {
    return Material(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(width: 3, color: Colors.blueGrey[600])),
      elevation: 5,
      child: Container(
        height: screenSize.height / 2.8,
        width: screenSize.width / 2.2,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(colors: [Colors.purple, Colors.cyan])),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            //sayfa yönlendirmesi
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HastaMesajlarPage(user: widget.user)));
          },
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: screenSize.width / 2.6,
                  height: screenSize.width / 2.6,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/message.png"),
                          fit: BoxFit.cover)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Mesajlarım",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
