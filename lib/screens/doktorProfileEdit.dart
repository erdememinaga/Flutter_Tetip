import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tetip/screens/doktorProfile.dart';
import 'package:tetip/screens/hastaProfile.dart';

class DoktorProfileEdit extends StatefulWidget {
  User user;
  String name, surName;
  DoktorProfileEdit({this.user, this.name, this.surName});
  @override
  _DoktorProfileEditState createState() => _DoktorProfileEditState();
}

class _DoktorProfileEditState extends State<DoktorProfileEdit> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  String _name, _surName, _email, _password;
  double _elevation = 10;
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Bilgileri Düzenle"),
        backgroundColor: Colors.indigo[500],
      ),
      body: SingleChildScrollView(
        child: Stack(children: [
          Container(
            width: screenSize.width,
            height: screenSize.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.orange[300], Colors.cyan[300]])),
          ),
          _editFormWidget(screenSize)
        ]),
      ),
    );
  }

//Doktor profil bilgileri editlenebilir bir şekilde aktarılır
// form tamamlandığında kaydedlirek veriler güncellenir.
  _editFormWidget(Size screenSize) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: screenSize.width / 1.3,
                      decoration: BoxDecoration(
                        color: Colors.indigo[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        initialValue: widget.name,
                        decoration: InputDecoration(
                          labelText: "İsim",
                          fillColor: Colors.white,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(15.0),
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Lütfen isminizi giriniz';
                          }
                          return null;
                        },
                        onSaved: (var value) {
                          _name = value;
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: screenSize.width / 1.3,
                      decoration: BoxDecoration(
                        color: Colors.indigo[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        initialValue: widget.surName,
                        decoration: InputDecoration(
                          labelText: "Soyisim",
                          fillColor: Colors.white,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(15.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Lütfen soyisminizi giriniz';
                          }
                          return null;
                        },
                        onSaved: (var value) {
                          _surName = value;
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: screenSize.width / 1.3,
                      decoration: BoxDecoration(
                        color: Colors.indigo[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        initialValue: widget.user.email,
                        decoration: InputDecoration(
                          labelText: "E-posta giriniz",
                          fillColor: Colors.white,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(15.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Lütfen epostanızı giriniz';
                          }
                          return null;
                        },
                        onSaved: (var value) {
                          _email = value;
                        },
                      ),
                    ),
                  ),
                  //sifre
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: screenSize.width / 1.3,
                      decoration: BoxDecoration(
                        color: Colors.indigo[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Şifrenizi giriniz",
                          fillColor: Colors.white,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(15.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Lütfen şifrenizi giriniz';
                          }
                          return null;
                        },
                        onSaved: (var value) {
                          _password = value;
                        },
                      ),
                    ),
                  ),
                  Material(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: _elevation,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.orange[300], Colors.cyan[300]]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FlatButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            await _firebaseFirestore
                                .collection("doktorlar")
                                .doc(widget.user.uid)
                                .update({
                              "name": _name,
                              "surName": _surName,
                              "email": _email,
                              "password": _password
                            });
                            //Navigator.pop(context);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DoktorProfile(user: widget.user)));
                          }
                        },
                        child: Text(
                          "Kaydet",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
