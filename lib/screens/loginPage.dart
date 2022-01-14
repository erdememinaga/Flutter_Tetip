import 'package:flutter/material.dart';
import 'package:tetip/dbControllers/authServices.dart';
import 'package:tetip/screens/rootPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toggle_switch/toggle_switch.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

//Bu sayfada login ve register seçenkleri hasta ve doktor seçenekleri ile
//filtrelenerek giriş ve yeni kayıt yapılır
//bu sayede bir sonraki sayfaya geçilir.
int selectedToggle = 0;
Gradient themeColorLight =
    LinearGradient(colors: [Colors.orange[300], Colors.cyan[300]]);
Color colorFormField = Color.fromRGBO(234, 224, 224, 1);

class _LoginPageState extends State<LoginPage> {
  final _formKeyhasta = GlobalKey<FormState>();
  final _formKeyDoktor = GlobalKey<FormState>();
  String _name, _surName, _hastaNumber, _email, _password;
  double _elevation = 10;
  AuthServices authServices = AuthServices();
  bool loginFormControl = true, _obsCureText = true, _checked = false;
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: _bodyWidget(screenSize),
    );
  }

  _bodyWidget(Size screenSize) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Container(
              height: loginFormControl == true
                  ? screenSize.height
                  : screenSize.height * 1.3,
              width: screenSize.width,
              decoration: BoxDecoration(
                gradient: themeColorLight,
              )),
          Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100, bottom: 50),
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/login.png"),
                            fit: BoxFit.scaleDown)),
                    height: screenSize.height / 4,
                    width: screenSize.width / 1.2,
                  ),
                ),
              ),
              _choiceButton(screenSize),
              loginFormControl == true
                  ? _loginFormWidget2(screenSize)
                  : _registerFormWidget2(screenSize),
              loginFormControl == true
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: FlatButton(
                              onPressed: () {
                                setState(() {
                                  loginFormControl = false;
                                });
                              },
                              child: Text(
                                "Kayıt Ol",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: FlatButton(
                              onPressed: () {
                                setState(() {
                                  loginFormControl = true;
                                });
                              },
                              child: Text(
                                "Giriş Yap",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))),
                    )
            ],
          ),
        ],
      ),
    );
  }

  _choiceButton(Size screenSize) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        child: ToggleSwitch(
          initialLabelIndex: selectedToggle,
          minHeight: 50.0,
          minWidth: 150.0,
          cornerRadius: 20.0,
          activeBgColor: Colors.indigo,
          inactiveBgColor: Colors.white,
          activeFgColor: Colors.white,
          inactiveFgColor: Colors.black,
          labels: ['Hasta Girişi', 'Doktor Girişi'],
          icons: [Icons.login, Icons.login],
          onToggle: (index) {
            setState(() {
              selectedToggle = index;
            });
          },
        ),
      ),
    );
  }

  _loginFormWidget2(Size screenSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Form(
          key: selectedToggle == 0 ? _formKeyhasta : _formKeyDoktor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: screenSize.width / 1.3,
                  decoration: BoxDecoration(
                      color: Colors.indigo[100],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.indigo)),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "*******@gmail.com",
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(15),
                            top: Radius.circular(15)),
                        //borderSide: BorderSide(color: Colors.red),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                            bottom: Radius.circular(15)),
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
                      border: Border.all(color: Colors.indigo)),
                  child: TextFormField(
                    obscureText: _obsCureText,
                    decoration: InputDecoration(
                      hintText: "Password",
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(15),
                            top: Radius.circular(15)),
                        // borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                            bottom: Radius.circular(15)),
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
                        colors: [Colors.blue[600], Colors.indigo[200]]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FlatButton(
                    onPressed: () async {
                      if (_elevation == 10) {
                        setState(() {
                          _elevation = 0;
                          _elevation = 10;
                        });
                      } else {
                        setState(() {
                          _elevation = 0;
                        });
                      }

                      if (selectedToggle == 0) {
                        if (_formKeyhasta.currentState.validate()) {
                          _formKeyhasta.currentState.save();

                          User userS =
                              await authServices.signIn(_email, _password);
                          String kontrol;
                          await FirebaseFirestore.instance
                              .collection("hastalar")
                              .get()
                              .then((querySnapshot) {
                            querySnapshot.docs.forEach((result) {
                              if (userS.uid == result.id) {
                                kontrol = "hasta";
                              }
                            });
                          });
                          if (kontrol == "hasta") {
                            return Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RootPage()));
                          }
                        }
                      } else {
                        if (_formKeyDoktor.currentState.validate()) {
                          _formKeyDoktor.currentState.save();

                          User userT =
                              await authServices.signIn(_email, _password);
                          String kontrol;
                          await FirebaseFirestore.instance
                              .collection("doktorlar")
                              .get()
                              .then((querySnapshot) {
                            querySnapshot.docs.forEach((result) {
                              if (userT.uid == result.id) {
                                kontrol = "doktor";
                              }
                            });
                          });
                          if (kontrol == "doktor") {
                            return Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RootPage()));
                          }
                        }
                      }
                    },
                    child: Text("Giriş"),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _registerFormWidget2(Size screenSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Form(
          key: selectedToggle == 0 ? _formKeyhasta : _formKeyDoktor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: screenSize.width / 1.3,
                  decoration: BoxDecoration(
                    color: Colors.indigo[100],
                    border: Border.all(color: Colors.indigo),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextFormField(
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
                    border: Border.all(color: Colors.indigo),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "soyisim",
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
                    border: Border.all(color: Colors.indigo),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextFormField(
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
                    border: Border.all(color: Colors.indigo),
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
                        colors: [Colors.blue[600], Colors.indigo[200]]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FlatButton(
                    onPressed: () {
                      if (selectedToggle == 0) {
                        if (_formKeyhasta.currentState.validate()) {
                          _formKeyhasta.currentState.save();

                          authServices
                              .createHasta(_name, _surName, _email, _password)
                              .then((value) {
                            return Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          });
                        }
                      } else {
                        if (_formKeyDoktor.currentState.validate()) {
                          _formKeyDoktor.currentState.save();

                          authServices
                              .createDoktor(_name, _surName, _email, _password)
                              .then((value) {
                            return Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          });
                        }
                      }
                    },
                    child: Text(
                      "Kayıt Ol",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
