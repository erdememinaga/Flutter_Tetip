import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tetip/screens/hastaDoktorFirstSohbetPage.dart';

class DalDoktorlarPage extends StatefulWidget {
  User user;
  String seciliDalId;
  DalDoktorlarPage({this.user, this.seciliDalId});
  @override
  State<DalDoktorlarPage> createState() => _DalDoktorlarPageState();
}

class _DalDoktorlarPageState extends State<DalDoktorlarPage> {
  //Bu sayfa hizmet al butonundan sonra seçilen dala göre uzmanlık alanı olan doktorları listelemektedir.
  //Bu sayfada gerekli arama işlemleri de yapılabilmektedir.
  //Seçilen doktara göre sohbet sayfasına gidilmektedir.
  String seciliDoktorId = "";
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<Widget> doktorWidgetList = List<Widget>();
  List<String> doktorIds = List<String>();
  List<Doktor> _doktorlar = List<Doktor>();
  String sohbetName = "", sohbetUrl = "null";
  @override
  Widget build(BuildContext context) {
    doktorWidgetList.clear();
    doktorIds.clear();
    _doktorlar.clear();
    String _result;

    Size screenSize = MediaQuery.of(context).size;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Doktorlar"),
        backgroundColor: Colors.indigo[500],
        actions: [
          TextButton(
            onPressed: () async {
              var result = await showSearch<String>(
                context: context,
                delegate: CustomDelegate(
                    doktorList: _doktorlar,
                    user: widget.user,
                    sohbetName: sohbetName,
                    sohbetUrl: sohbetUrl),
              );
              setState(() => _result = result);
            },
            child: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: _bodyWidget(screenSize),
    );
  }

  _bodyWidget(Size screenSize) {
    return FutureBuilder<Object>(
        future: _getDoktorlar(screenSize),
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
                        gradient: LinearGradient(
                            colors: [Colors.orange[300], Colors.cyan[300]])),
                  ),
                  Column(
                    children: doktorWidgetList,
                  ),
                ],
              ),
            );
          }
        });
  }

//Doktorlar çekilmektedir.
  _getDoktorlar(Size screenSize) async {
    doktorWidgetList.clear();
    doktorIds.clear();
    _doktorlar.clear();
    await _firebaseFirestore
        .collection("anabilimdallari")
        .doc(widget.seciliDalId)
        .collection("doktorlar")
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                Doktor doktor = Doktor();
                doktorIds.add(element.data()["doktorid"]);
              })
            });

    for (var i = 0; i < doktorIds.length; i++) {
      Doktor doktor = Doktor();
      await _firebaseFirestore
          .collection("doktorlar")
          .doc(doktorIds[i])
          .get()
          .then((value) => {
                doktor.doktor = value.data()["name"],
                doktor.seciliDoktorId = doktorIds[i],
                doktor.sohbetName = value.data()["name"].toString(),
                doktor.sohbetUrl = value.data()["photoUrl"].toString(),
                doktor.userToken = value.data()["userToken"].toString(),
                _doktorlar.add(doktor),
                doktorWidgetList.add(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: screenSize.width,
                    height: screenSize.height / 18,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.indigoAccent,
                        border: Border.all()),
                    child: InkWell(
                      child: Center(
                          child: Text(
                        value.data()["name"].toString().toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      )),
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HastaDoktorFirstSohbetPage(
                                        user: widget.user,
                                        seciliDoktorId: doktorIds[i],
                                        sohbetName: value.data()["name"],
                                        sohbetUrl:
                                            value.data()["photoUrl"].toString(),
                                        userToken: value
                                            .data()["userToken"]
                                            .toString())));
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
//Aşağı kısım yukarı ile aynı işleri yapmaktadır sadece arama kısmı buradan yönetilmektedir.

class Doktor {
  String doktor;
  String seciliDoktorId, sohbetName, sohbetUrl, userToken;
  Doktor(
      {this.doktor,
      this.seciliDoktorId,
      this.sohbetName,
      this.sohbetUrl,
      this.userToken});
}

class CustomDelegate extends SearchDelegate<String> {
  List<String> data = ["asd", "naber", "be", "a", "s"];
  List<String> dataId = ["asd", "naber", "be", "a", "s"];
  List<String> dataPhotoUrls = ["asd", "naber", "be", "a", "s"];
  List<String> dataUserTokens = ["asd", "naber", "be", "a", "s"];

  List<Doktor> doktorList;
  User user;
  String sohbetName, sohbetUrl;
  CustomDelegate({this.doktorList, this.user, this.sohbetName, this.sohbetUrl});
  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
      icon: Icon(Icons.chevron_left), onPressed: () => close(context, ''));

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    data.clear();
    dataId.clear();
    dataPhotoUrls.clear();
    dataUserTokens.clear();
    for (var i = 0; i < doktorList.length; i++) {
      data.add(doktorList[i].doktor);
      dataId.add(doktorList[i].seciliDoktorId);
      dataPhotoUrls.add(doktorList[i].sohbetUrl);
      dataUserTokens.add(doktorList[i].userToken);
    }

    var listToShow;
    if (query.isNotEmpty)
      listToShow =
          data.where((e) => e.contains(query) && e.startsWith(query)).toList();
    else
      listToShow = data;

    return Stack(
      children: [
        Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.orange[300], Colors.cyan[300]])),
        ),
        ListView.builder(
          itemCount: listToShow.length,
          itemBuilder: (_, i) {
            var noun = listToShow[i];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: screenSize.width,
                height: screenSize.height / 20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue,
                    border: Border.all()),
                child: InkWell(
                  child: Center(
                      child: Text(
                    noun.toString().toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  )),
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HastaDoktorFirstSohbetPage(
                                  user: user,
                                  seciliDoktorId: dataId[i],
                                  sohbetName: sohbetName,
                                  sohbetUrl: dataPhotoUrls[i].toString(),
                                  userToken: dataUserTokens[i].toString(),
                                )));
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
