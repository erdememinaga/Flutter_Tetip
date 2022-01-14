import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class DoktorHastaSohbetPage extends StatefulWidget {
  User user;
  String seciliHastaId, seciliSohbetId, sohbetName, sohbetUrl, userToken;
  DoktorHastaSohbetPage(
      {this.seciliHastaId,
      this.user,
      this.seciliSohbetId,
      this.sohbetName,
      this.sohbetUrl,
      this.userToken});
  @override
  State<DoktorHastaSohbetPage> createState() => _DoktorHastaSohbetPageState();
}

class _DoktorHastaSohbetPageState extends State<DoktorHastaSohbetPage> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final _formKeyMesaj = GlobalKey<FormState>();
  List<Widget> mesajWidgetList = List<Widget>();
  //Bildirim için firebase cloud messasing server tokenı

  final String serverToken =
      'AAAAukIfrJ4:APA91bFKVs1ZlO8ZSKT_z8xl3jIEzbvKu1ff33v8cdAMGJwbLR3SVfaXnqTSLYsvOp_9v5Twci-oc2fyn64fJLKMjuWIyGUa2nvaPQ_8DUNg57V7Wr7OJ5lJL8S1i-0AFpU3_LlxYpYa';
  String mesaj = "";

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    //appbar kısmında gerekli veri taşıma işlemleri ile sohbet edilen kişinin resmi ve adı görünür

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: widget.sohbetUrl != "null"
                          ? NetworkImage(widget.sohbetUrl)
                          : NetworkImage(
                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSgBhcplevwUKGRs1P-Ps8Mwf2wOwnW_R_JIA&usqp=CAU"))),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(widget.sohbetName),
            ),
          ],
        ),
        backgroundColor: Colors.indigo[500],
      ),
      body: FutureBuilder<Object>(
          future: _getMesajlar(screenSize),
          builder: (context, snapshot) {
            return Stack(
              children: [
                Container(
                  width: screenSize.width,
                  height: screenSize.height,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.orange[300], Colors.cyan[300]])),
                ),
                Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 60.0),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: mesajWidgetList),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Form(
                                key: _formKeyMesaj,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      hintText: "Mesaj yaz",
                                      hintStyle:
                                          TextStyle(color: Colors.black54),
                                      border: InputBorder.none),
                                  onSaved: (var value) {
                                    mesaj = value;
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            FloatingActionButton(
                              onPressed: () {
                                _formKeyMesaj.currentState.save();
                                if (mesaj != "") {
                                  sendAndRetrieveMessage(
                                      widget.userToken, mesaj);
                                  setState(() {
                                    _sendMessage(mesaj);
                                    _formKeyMesaj.currentState.reset();
                                  });
                                }
                              },
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 18,
                              ),
                              backgroundColor: Colors.blue,
                              elevation: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
    );
  }
  //mesaj gönderme butonuna tıklanıldığında gerekli filtreler ile mesaj kaydedili.

  void _sendMessage(String mesaj) async {
    await _firebaseFirestore
        .collection("doktorlar")
        .doc(widget.user.uid)
        .collection("sohbetler")
        .doc(widget.seciliSohbetId)
        .collection("mesajlar")
        .add({"mesaj": mesaj, "gönderen": "doktor", "date": DateTime.now()});
  }

  //seçili sohbet mesajları tarihe göre çekilir ve
  // sender ve receiver olmak üzere çift yönlü widgetlar oluşturulur.
  _getMesajlar(Size screenSize) async {
    print(widget.seciliSohbetId);
    mesajWidgetList.clear();
    await _firebaseFirestore
        .collection("doktorlar")
        .doc(widget.user.uid)
        .collection("sohbetler")
        .doc(widget.seciliSohbetId)
        .collection("mesajlar")
        .orderBy("date")
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                print(element.data()["mesaj"] +
                    element.data()["date"].toString());
                if (element.data()["gönderen"] == "hasta") {
                  mesajWidgetList.add(_receiverMessageWidget(
                      screenSize, element.data()["mesaj"]));
                } else {
                  mesajWidgetList.add(_senderMessageWidget(
                      screenSize, element.data()["mesaj"]));
                }
              })
            });
  }

  _senderMessageWidget(Size screenSize, String message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.indigo[100],
                border: Border.all(width: 2, color: Colors.indigo),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15))),
            width: screenSize.width / 1.7,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Text(message),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _receiverMessageWidget(Size screenSize, String message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.cyan[100],
                border: Border.all(width: 2, color: Colors.blue),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            width: screenSize.width / 1.7,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Text(message),
              ),
            ),
          ),
        ],
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

//bildirim gönderme fonksiyonu mesajda görüşülen kişinin token bilgisine mesaj içeriği ve mesajı gönderen
//kişiyi içeren bir bildirim gönderir
  Future<Map<String, dynamic>> sendAndRetrieveMessage(
      String token, String mesaj) async {
    print("tokennnnn: " + token);
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '${mesaj}',
            'title': '${widget.user.email} yeni mesaj..'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': token,
        },
      ),
    );

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );

    return completer.future;
  }
}
