import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tetip/screens/dalDoktorlarPage.dart';

class BilimDallarPage extends StatefulWidget {
  User user;
  BilimDallarPage({this.user});
  @override
  State<BilimDallarPage> createState() => _BilimDallarPageState();
}

class _BilimDallarPageState extends State<BilimDallarPage> {
  //Bu sayfada hizmet al ekranından sonra anabilim dalları listelenmektedir.
  //bu dallardan arama yapılarakda seçim  yapılabilmektedir.
  //Seçilen dala göre o dal uzmanlık alanı olan doktorların göründüğü sayfaya gidilmektedir.
  String seciliDalId = "";
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<Widget> widgetList = List<Widget>();
  List<Widget> doktorWidgetList = List<Widget>();

  List<Dal> _dallar = List<Dal>();
  List<dynamic> _dallarForDisplay = List<Dal>();
  String _result;
  @override
  Widget build(BuildContext context) {
    doktorWidgetList.clear();
    widgetList.clear();
    Size screenSize = MediaQuery.of(context).size;
    return FutureBuilder<Object>(
        future: _getDallar(screenSize),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return spinkit();
          } else {
            if (snapshot.hasError) return Center(child: Text('hata'));
            return Scaffold(
              appBar: AppBar(
                title: Text('Anabilim Dalları'),
                backgroundColor: Colors.indigo[500],
                actions: [
                  TextButton(
                    onPressed: () async {
                      var result = await showSearch<String>(
                        context: context,
                        delegate:
                            CustomDelegate(dalList: _dallar, user: widget.user),
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
                    Center(
                      child: Column(children: widgetList),
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }

//Dallar çekilir
  _getDallar(Size screenSize) async {
    widgetList.clear();
    _dallar.clear();
    await _firebaseFirestore
        .collection("anabilimdallari")
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                Dal dal = Dal();
                dal.dal = element.data()["dal"];
                dal.seciliDalId = element.id;
                _dallar.add(dal);
                widgetList.add(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: screenSize.width,
                    height: screenSize.height / 10,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.indigoAccent,
                        border: Border.all()),
                    child: InkWell(
                      child: Center(
                          child: Text(
                        element.data()["dal"].toString().toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      )),
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DalDoktorlarPage(
                                    user: widget.user,
                                    seciliDalId: element.id)));
                      },
                    ),
                  ),
                ));
              })
            });
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

//Aşağı kısım yukarı ile aynı işleri yapmadtadır sadece arama kısmı buradan yönetilmektedir.
class Dal {
  String dal;
  String seciliDalId;
  Dal({this.dal, this.seciliDalId});
}

class CustomDelegate extends SearchDelegate<String> {
  List<String> data = ["asd", "naber", "be", "a", "s"];
  List<String> dataId = ["asd", "naber", "be", "a", "s"];

  List<Dal> dalList;
  User user;
  CustomDelegate({this.dalList, this.user});
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
    for (var i = 0; i < dalList.length; i++) {
      data.add(dalList[i].dal);
      dataId.add(dalList[i].seciliDalId);
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
                            builder: (context) => DalDoktorlarPage(
                                user: user, seciliDalId: dataId[i])));
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
