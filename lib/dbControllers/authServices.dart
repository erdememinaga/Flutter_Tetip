import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//Firebase hasta ve doktor kayıt ve giriş yapma fonksiyonları burada tanımlanmıştır.
  Future<User> signIn(String email, String password) async {
    var user = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    print(user.user.email);
    return user.user;
  }

  signOut() async {
    return await _auth.signOut();
  }

  Future<User> createHasta(
      String name, String surName, String email, String password) async {
    var user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    await _firestore.collection("hastalar").doc(user.user.uid).set({
      'name': name,
      'surName': surName,
      'email': email,
      'password': password,
    });

    return user.user;
  }

  Future<User> createDoktor(
      String name, String surName, String email, String password) async {
    var user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    await _firestore.collection("doktorlar").doc(user.user.uid).set({
      'name': name,
      'surName': surName,
      'email': email,
      'password': password,
    });

    return user.user;
  }
}
