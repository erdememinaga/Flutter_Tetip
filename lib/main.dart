import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tetip/screens/rootPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Uygulama açıldığında ilk bu sayfa çalışır ve RootPage e yönlendirir.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TeTip',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: RootPage(),
    );
  }
}
