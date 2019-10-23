import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:lab_app/radioStationClass.dart';
//import 'package:audio_stream_player/audio_stream_player.dart';
import 'package:fluttery_audio/fluttery_audio.dart';
import 'package:lab_app/my_flutter_app_icons.dart' as costumIcon;
import 'package:lab_app/Statut.dart';
import 'package:lab_app/detail.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: "Manjari",
        ),
        home: MyHomePage(
          title: "here",
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final color = const Color(0xFF4C1F92);
  Statut playAudio = Statut.stop;
  String url, name = "aucun", id_radio = "1", selectedCountry = "";
  final _formKey = GlobalKey<FormState>();
  final _scaff = GlobalKey<ScaffoldState>();
  final SnackBar snackBar = const SnackBar(content: Text('Showing Snackbar'));
  TabController tabC, playC;
  List<radio> listRadio = new List();
  List<radio> listRadioNochange = new List();
  List<radio> listRadioLand = new List();

  Map _radios = {"1": "France", "2": "U.K", "3": "Maroc", "4": "Allemand"};
  /*list for play pause stop*/
  Set<radio> _savedlistRadio = new Set<radio>();
  List<radio> _favoriteRadioStation = new List();
  final List<radio> listLand2 = new List();
  List<radio> _savedlistRadioFavorite = new List<radio>();

  AutoCompleteTextField searchTextField, searchTextFieldLand;

  /*variable for dropdownlist*/
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentRadio;

  GlobalKey<AutoCompleteTextFieldState<radio>> key = new GlobalKey();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    TextEditingController controller = new TextEditingController();
    tabC = TabController(length: 4, vsync: this, initialIndex: 0);
    //playC = TabController(length: 1, vsync: this);
    /*audio = new Audio(
      audioUrl: "http://broadcast.infomaniak.ch/alpes1gap-high.mp3",
      playerBuilder: (BuildContext context, AudioPlayer player, Widget child) {
        player.loadMedia(Uri.parse("http://broadcast.infomaniak.ch/alpes1gap-high.mp3"));
        player.play();
      },
    );*/

    _dropDownMenuItems = getDropDownMenuItems();
    _currentRadio = _dropDownMenuItems[0].value;
    dataFromSql();
  }

  void changedDropDownItem(String selectedCity) {
    setState(() {
      _currentRadio = selectedCity;
    });
  }

// here we are creating the list needed for the DropDownButton
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String oneradio in _radios.keys) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(new DropdownMenuItem(
          value: oneradio, child: Text(_radios[oneradio])));
    }
    return items;
  }

  /*get data's list from sqlite*/
  Future<List<radio>> getList() async {
    final List<radio> _favoriteRadio = new List<radio>();
    await radioDB().then((onValue) {
      for (int i = 0; i < onValue.length; i++) {
        _favoriteRadio.add(onValue.elementAt(i));
        print("Taille $i");
      }
    });
    _savedlistRadioFavorite = _favoriteRadio;
    return _favoriteRadio;
  }

  Future<List<radio>> getData() async {
    List<radio> listRadio1 = new List();
    if (listRadio.length == 0) {
      var url = 'http://www.ng-plus.com/pandroid/radio/allRadioStation.php';
      http.Response response = await http.get(url);
      List StationArray = jsonDecode(response.body);
      for (var i = 0; i < StationArray.length; i++) {
        radio st2 = radio.fromJson(StationArray[i]);
        listRadio1.add(new radio(
            id_radio: st2.id_radio,
            name: st2.name,
            note: st2.note,
            text_radio: st2.text_radio,
            url: st2.url,
            Sprache: st2.Sprache,
            Land: st2.Land,
            id_Land: st2.id_Land,
            id_Sprache: st2.id_Sprache));
      }
      listRadioNochange = listRadio;
      listRadio = listRadio1;
    }
    print("initState");
    return listRadio;
  }

  //* return a unique country */
  Future<List<radio>> getLand() async {
    if (listLand2.length == 0) {
      List<radio> listLand1 = await getData();
      bool isExist = false;
      for (radio a in listLand1) {
        for (radio b in listLand2) {
          if (b.Land == a.Land) {
            isExist = true;
            break;
          }
        }
        if (!isExist) listLand2.add(a);
        isExist = false;
      }
    }
    listRadioLand = listLand2;
    return listLand2;
  }

  /*List<Widget> _getListData() {
    List<Widget> widgets = [];
    for (int i = 0; i < listRadio.length; i++) {
      widgets.add(Padding(
          padding: EdgeInsets.all(10.0),
          child: Text("Row" + listRadio[i].name)));
    }

    return widgets;
  }*/

  @override
  void dispose() {
    // TODO: implement dispose
    tabC.dispose();
    //playC.dispose();
    playAudio = Statut.stop;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      key: _scaff,
      bottomSheet: Card(
        margin: EdgeInsets.all(0.0),
        elevation: 0,
        color: color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              backgroundImage: NetworkImage(
                  "http://www.ng-plus.com/pandroid/radio/icon/" +
                      id_radio +
                      ".png"),
            ),
            Padding(
              padding: EdgeInsets.all(0.0),
              child: Text(
                "$name",
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
            (playAudio == Statut.play)
                ? Icon(
                    costumIcon.MyFlutterApp.play,
                    size: 30,
                    color: Colors.white,
                  )
                : (playAudio == Statut.stop)
                    ? Icon(
                        costumIcon.MyFlutterApp.pause,
                        size: 30,
                        color: Colors.white,
                      )
                    : Icon(
                        costumIcon.MyFlutterApp.stop,
                        size: 30,
                        color: Colors.white,
                      ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: color,
        bottom: TabBar(
          controller: tabC,
          tabs: [
            Tab(icon: Icon(Icons.radio), text: "All radio"),
            Tab(icon: Icon(Icons.flag), text: "Country"),
            Tab(icon: Icon(Icons.favorite), text: "Favorite"),
            Tab(icon: Icon(Icons.add_comment), text: "Add other"),
          ],
        ),
        title: Text('Radio ng+'),
      ),
      body: Audio(
        audioUrl: url,
        playerBuilder:
            (BuildContext context, AudioPlayer player, Widget child) {
          if (playAudio == Statut.play) {
            player.loadMedia(Uri.parse(url));
            player.play();
            print("playing");
          } else {
            player.stop();
            print("stoping");
          }
          return TabBarView(
            controller: tabC,
            children: [
              /* block all radio */
              Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  searchTextField = AutoCompleteTextField<radio>(
                    style: new TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                    decoration: new InputDecoration(
                        suffixIcon: Container(
                          child: Icon(Icons.search),
                          //width: 85.0,
                          //height: 60.0,
                        ),
                        contentPadding:
                            EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                        filled: true,
                        hintText: 'Rechercher un radio',
                        hintStyle: TextStyle(color: Colors.black)),
                    itemBuilder: (context, item) {
                      return Container(
                        color: color,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              item.name,
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white),
                            ),
                            Padding(
                              padding: EdgeInsets.all(15.0),
                            ),
                            Text(
                              item.Sprache,
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white),
                            )
                          ],
                        ),
                      );
                    },
                    itemFilter: (item, query) {
                      return item.name
                          .toLowerCase()
                          .startsWith(query.toLowerCase());
                    },
                    itemSorter: (a, b) {
                      return a.name.compareTo(b.name);
                    },
                    itemSubmitted: (item) {
                      /*setState(
                              () => searchTextField.textField.controller.text =item.name
                      );*/
                      setState(() {
                        searchTextField.textField.controller.text = item.name;
                        listRadio = listRadioNochange
                            .where((x) => x.name == item.name)
                            .toList();
                      });
                    },
                    key: key,
                    suggestions: listRadio,
                    clearOnSubmit: false,
                    textChanged: (a) {
                      setState(() {
                        if (listRadio.length != listRadioNochange.length) {
                          listRadio = listRadioNochange;
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: FutureBuilder(
                        future: getData(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.data == null) {
                            return Container(
                                child: Center(
                              child: CircularProgressIndicator(
                                  backgroundColor: Colors.black54),
                            ));
                          } else {
                            return ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  final bool alreadySaved = _savedlistRadio
                                      .contains(snapshot.data[index]);
                                  final bool alreadyFavorite = checkIfContains(
                                      _savedlistRadioFavorite,
                                      snapshot.data[index]);
                                  print(
                                      "${_favoriteRadioStation.contains(snapshot.data[index])} <==> ${snapshot.data[index].name}");
                                  return ListTile(
                                    contentPadding: EdgeInsets.all(10),
                                    leading: Hero(
                                      tag:
                                          "hero${snapshot.data[index].id_radio}",
                                      child: GestureDetector(
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: color,
                                          backgroundImage: NetworkImage(
                                              "http://www.ng-plus.com/pandroid/radio/icon/" +
                                                  snapshot
                                                      .data[index].id_radio +
                                                  ".png"),
                                        ),
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return radioStation(
                                              StationRadio:
                                                  snapshot.data[index],
                                              state: playAudio,
                                            );
                                          }));
                                        },
                                      ),
                                    ),
                                    title: Column(
                                      children: <Widget>[
                                        Text(
                                          snapshot.data[index].name,
                                          style: TextStyle(
                                              fontFamily: 'AppFont1',
                                              fontSize: 16),
                                        ),
                                        Text(
                                          snapshot.data[index].text_radio,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: color,
                                          ),
                                        ),
                                        Text(
                                          snapshot.data[index].Sprache,
                                          style: TextStyle(fontSize: 14),
                                        )
                                      ],
                                    ),
                                    trailing: Column(
                                      children: <Widget>[
                                        Icon(
                                          alreadySaved
                                              ? costumIcon.MyFlutterApp.pause
                                              : costumIcon.MyFlutterApp.play,
                                          color: color,
                                        ),
                                        GestureDetector(
                                            onDoubleTap: () {
                                              print("is taped");
                                              setState(() {
                                                if (alreadyFavorite) {
                                                  /*garde this code for purpose*/
                                                  //_favoriteRadioStation.remove(
                                                  //  (snapshot.data[index]));
                                                  delete(snapshot
                                                          .data[index].id_radio)
                                                      .then((a) {
                                                    for (int i = 0;
                                                        i < a.length;
                                                        i++) {
                                                      _favoriteRadioStation
                                                          .add(a.elementAt(i));
                                                    }
                                                  });
                                                } else {
                                                  /*garde this code for purpose*/
                                                  //_favoriteRadioStation.add(
                                                  //  snapshot.data[index]);
                                                  insert(snapshot.data[index])
                                                      .then((a) {
                                                    for (int j = 0;
                                                        j < a.length;
                                                        j++) {
                                                      _favoriteRadioStation
                                                          .add(a.elementAt(j));
                                                    }
                                                  });
                                                }
                                                /*radioDB().then((onValue){
                                                  for(int i = 0 ; i<onValue.length;i++){
                                                    _favoriteRadioStation.add(onValue.elementAt(i));
                                                  }
                                                });*/
                                              });
                                            },
                                            child: Icon(
                                              alreadyFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: alreadyFavorite
                                                  ? Colors.amber
                                                  : null,
                                              size: 30,
                                            ))
                                      ],
                                    ),
                                    onTap: () {
                                      setState(() {
                                        if (alreadySaved) {
                                          //_savedlistRadio.remove(snapshot.data[index]);
                                          _savedlistRadio.clear();
                                          //print(_savedlistRadio.length);
                                          playAudio = Statut.pause;
                                        } else {
                                          /*elements are taking to the bottomsheet*/
                                          url = snapshot.data[index].url;
                                          name = snapshot.data[index].name;
                                          id_radio =
                                              snapshot.data[index].id_radio;
                                          playAudio = Statut.play;
                                          /* end elements are taking to the bottomsheet*/
                                          /* if clicked on : one element on the list */
                                          if (_savedlistRadio.length != 0) {
                                            _savedlistRadio.clear();
                                            print("f1");
                                          }
                                          /* if clicked on : no element on the list */
                                          else {
                                            playAudio = Statut.play;
                                            print("t");
                                            print("play(url " +
                                                snapshot.data[index].url);
                                          }
                                          /*  */
                                          _savedlistRadio
                                              .add(snapshot.data[index]);
                                        }
                                      });
                                      print("clicked");
                                    },
                                  );
                                });
                          }
                        }
                        //ListView(children: _getListData())
                        ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  )
                ],
              ),
              /*block Country*/
              Column(
                children: <Widget>[
                  searchTextFieldLand = AutoCompleteTextField<radio>(
                    style: new TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                    decoration: new InputDecoration(
                        suffixIcon: Container(
                          child: Icon(Icons.search),
                          //width: 85.0,
                          //height: 60.0,
                        ),
                        contentPadding:
                            EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                        filled: true,
                        hintText: 'Rechercher le pays',
                        hintStyle: TextStyle(color: Colors.black)),
                    itemBuilder: (context, item) {
                      return Container(
                        color: color,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              item.Land,
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                    itemFilter: (item, query) {
                      return item.Land.toLowerCase()
                          .startsWith(query.toLowerCase());
                    },
                    itemSorter: (a, b) {
                      return a.Land.compareTo(b.Land);
                    },
                    itemSubmitted: (item) {
                      setState(() {
                        searchTextFieldLand.textField.controller.text =
                            item.Land;
                        /*TODO*/
                        listRadio = listRadioLand
                            .where((x) => x.Land == item.Land)
                            .toList();
                      });
                    },
                    suggestions: listRadioLand,
                    clearOnSubmit: false,
                  ),
                  FutureBuilder(
                    future: getLand(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return (snapshot.data == null)
                          ? Center(
                              child: CircularProgressIndicator(
                                  backgroundColor: Colors.black54),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  final expand = snapshot.data[index].Land ==
                                      selectedCountry;
                                  return Column(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedCountry =
                                                (selectedCountry ==
                                                        snapshot
                                                            .data[index].Land)
                                                    ? ""
                                                    : snapshot.data[index].Land;
                                          });
                                        },
                                        child: ListTile(
                                          dense: true,
                                          title: Column(
                                            children: <Widget>[
                                              Text(
                                                snapshot.data[index].Land,
                                                style: TextStyle(
                                                    fontFamily: 'AppFont1',
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                snapshot.data[index].Sprache,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: color,
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: Column(
                                            children: <Widget>[
                                              Icon(
                                                !expand
                                                    ? Icons.arrow_forward_ios
                                                    : Icons.arrow_back_ios,
                                                color: color,
                                              ),
                                            ],
                                          ),
                                          leading: CircleAvatar(
                                            radius: 30,
                                            backgroundColor: color,
                                            backgroundImage: NetworkImage(
                                                "http://www.ng-plus.com/pandroid/radio/Land/" +
                                                    snapshot.data[index].id_Land
                                                        .toString() +
                                                    ".png"),
                                          ),
                                        ),
                                      ),
                                      !expand
                                          ? Text("")
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              physics: ScrollPhysics(),
                                              itemCount: listRadio
                                                  .where((x) =>
                                                      x.Land ==
                                                      snapshot.data[index].Land)
                                                  .toList()
                                                  .length,
                                              itemBuilder: (context, index1) {
                                                final List<radio> listNow =
                                                    listRadio
                                                        .where((x) =>
                                                            x.Land ==
                                                            snapshot
                                                                .data[index]
                                                                //for
                                                                .Land)
                                                        .toList();
                                                print("here");
                                                print(listRadio
                                                    .where((x) =>
                                                        x.Land ==
                                                        snapshot
                                                            .data[index].Land)
                                                    .length);
                                                final bool alreadySaved =
                                                    _savedlistRadio.contains(
                                                        listNow
                                                            .elementAt(index1));
                                                return Container(
                                                  color: Colors.black12,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        if (alreadySaved) {
                                                          _savedlistRadio
                                                              .clear();
                                                          playAudio =
                                                              Statut.pause;
                                                          //_savedlistRadio.remove(listNow.elementAt(index1));
                                                        } else {
                                                          url = listNow
                                                              .elementAt(index1)
                                                              .url;
                                                          name = listNow
                                                              .elementAt(index1)
                                                              .name;
                                                          id_radio = listNow
                                                              .elementAt(index1)
                                                              .id_radio;
                                                          playAudio =
                                                              Statut.play;
                                                          if (_savedlistRadio
                                                                  .length !=
                                                              0) {
                                                            _savedlistRadio
                                                                .clear();
                                                            print("f1");
                                                          } else {
                                                            playAudio =
                                                                Statut.play;
                                                            print("t");
                                                          }
                                                          /*TODO : Search on listRadio a spécifique radio Land*/
                                                          _savedlistRadio.add(
                                                              listNow.elementAt(
                                                                  index1));
                                                          print(
                                                              "verify ${listNow.elementAt(index1).name}");
                                                        }
                                                      });
                                                      print("clicked");
                                                    },
                                                    child: ListTile(
                                                      dense: true,
                                                      title: Text(
                                                        listNow
                                                            .elementAt(index1)
                                                            .name,
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                      trailing: alreadySaved
                                                          ? Icon(
                                                              Icons
                                                                  .pause_circle_outline,
                                                              color: color,
                                                            )
                                                          : Icon(
                                                              Icons
                                                                  .play_circle_outline,
                                                              color: color,
                                                            ),
                                                      leading: CircleAvatar(
                                                        radius: 20,
                                                        backgroundColor: color,
                                                        backgroundImage: NetworkImage(
                                                            "http://www.ng-plus.com/pandroid/radio/icon/" +
                                                                listNow
                                                                    .elementAt(
                                                                        index1)
                                                                    .id_radio +
                                                                ".png"),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                    ],
                                  );
                                },
                              ),
                            );
                    },
                  )
                ],
              ),
              /*block favorite*/
              FutureBuilder(
                  future: getList(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return (snapshot.data == null)
                        ? Center(
                            child: CircularProgressIndicator(
                                backgroundColor: Colors.black54),
                          )
                        : Container(
                            child: ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  final alreadySaved = _savedlistRadio.length ==
                                          0
                                      ? false
                                      : _savedlistRadio.elementAt(0).id_radio ==
                                          snapshot.data[index].id_radio;
                                  //print("length:${_savedlistRadio.length} played: $alreadySaved");
                                  //final bool alreadyFavorite = checkIfContains(snapshot.data,snapshot.data[index]);
                                  final bool alreadyFavorite = snapshot.data
                                      .contains(snapshot.data[index]);
                                  //final bool alreadyFavorite = true;
                                  print("object->$alreadyFavorite");
                                  return Dismissible(
                                    direction: DismissDirection.endToStart,
                                    dismissThresholds: {
                                      DismissDirection.startToEnd: 1,
                                      DismissDirection.endToStart: 0.7,
                                    },
                                    movementDuration:
                                        Duration(milliseconds: 1500),
                                    background: Container(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                            onDoubleTap: () {
                                              print("is taped");
                                              setState(() {
                                                if (alreadyFavorite) {
                                                  /*garde this code for purpose*/
                                                  //_favoriteRadioStation.remove(
                                                  //  (snapshot.data[index]));
                                                  delete(snapshot
                                                          .data[index].id_radio)
                                                      .then((a) {
                                                    for (int i = 0;
                                                        i < a.length;
                                                        i++) {
                                                      _favoriteRadioStation
                                                          .add(a.elementAt(i));
                                                    }
                                                  });
                                                  //AnimatedList.of(context).insertItem(index);
                                                } else {
                                                  /*garde this code for purpose*/
                                                  //_favoriteRadioStation.add(
                                                  //  snapshot.data[index]);
                                                  insert(snapshot.data[index])
                                                      .then((a) {
                                                    for (int j = 0;
                                                        j < a.length;
                                                        j++) {
                                                      _favoriteRadioStation
                                                          .add(a.elementAt(j));
                                                    }
                                                  });
                                                }
                                                /*radioDB().then((onValue){
                                                    for(int i = 0 ; i<onValue.length;i++){
                                                      _favoriteRadioStation.add(onValue.elementAt(i));
                                                    }
                                                  });*/
                                              });
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(
                                                alreadyFavorite
                                                    ? Icons.favorite_border
                                                    : Icons.favorite,
                                                color: alreadyFavorite
                                                    ? color
                                                    : null,
                                                size: 30,
                                              ),
                                            )),
                                      ),
                                    ),
                                    key: Key(snapshot.data[index].id_radio),
                                    // Provide a function that tells the app
                                    // what to do after an item has been swiped away.
                                    onDismissed: (direction) {
                                      // Remove the item from the data source.
                                      setState(() {
                                        delete(snapshot.data[index].id_radio)
                                            .then((a) {
                                          for (int i = 0; i < a.length; i++) {
                                            _favoriteRadioStation
                                                .add(a.elementAt(i));
                                          }
                                        });
                                        snapshot.data.removeAt(index);
                                      });
                                      if (_formKey.currentState.validate()) {
                                        // If the form is valid, display a snackbar. In the real world,
                                        // you'd often call a server or save the information in a database.
                                        _scaff.currentState
                                            .showSnackBar(snackBar);
                                      }
                                      // Show a snackbar. This snackbar could also contain "Undo" actions.
                                      //SnackBar dismiss = SnackBar(content: Text(snapshot.data[index].name+ "is deleted"));
                                    },
                                    child: ListTile(
                                      dense: true,
                                      title: Column(
                                        children: <Widget>[
                                          Text(
                                            snapshot.data[index].name,
                                            style: TextStyle(
                                                fontFamily: 'AppFont1',
                                                fontSize: 16),
                                          ),
                                          Text(
                                            snapshot.data[index].text_radio,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: color,
                                            ),
                                          ),
                                          Text(
                                            snapshot.data[index].Sprache,
                                            style: TextStyle(fontSize: 14),
                                          )
                                        ],
                                      ),
                                      trailing: Column(
                                        children: <Widget>[
                                          Icon(
                                            alreadySaved
                                                ? costumIcon.MyFlutterApp.play
                                                : costumIcon.MyFlutterApp.stop,
                                            color: color,
                                          ),
                                        ],
                                      ),
                                      leading: GestureDetector(
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: color,
                                          backgroundImage: NetworkImage(
                                              "http://www.ng-plus.com/pandroid/radio/icon/" +
                                                  snapshot
                                                      .data[index].id_radio +
                                                  ".png"),
                                        ),
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return radioStation(
                                              StationRadio:
                                                  snapshot.data[index],
                                              state: playAudio,
                                            );
                                          }));
                                        },
                                      ),
                                      onTap: () {
                                        setState(() {
                                          /*the same station (list's element) is clicked*/
                                          if (alreadySaved) {
                                            _savedlistRadio.clear();
                                            //print(_savedlistRadio.length);
                                            playAudio = Statut.pause;
                                            //print("f");
                                          } else {
                                            url = snapshot.data[index].url;
                                            name = snapshot.data[index].name;
                                            playAudio = Statut.play;
                                            /*station is already playing*/
                                            if (_savedlistRadio.length != 0) {
                                              _savedlistRadio.clear();
                                              //print("f1");
                                            }
                                            /* in case that user clicked on station and the list is empty (first run app and paused station)*/
                                            else {
                                              playAudio = Statut.play;
                                              //print("t");
                                              //print("play(url " +  snapshot.data[index].url);
                                            }
                                            _savedlistRadio
                                                .add(snapshot.data[index]);
                                            print(
                                                "--> ${_savedlistRadio.elementAt(0).name}");
                                          }
                                        });
                                      },
                                    ),
                                  );
                                }),
                          );
                  }),
              /*block insertion*/
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                      child: Text(
                        "inserer une autre station",
                        style: TextStyle(color: color, fontSize: 30),
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: // Build this out in the next steps.
                          SizedBox(
                        width: 340,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              obscureText: false,
                              decoration: InputDecoration(
                                  hintText: "nom",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  )),
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  hintText: "url"),
                              obscureText: false,
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  hintText: "langue"),
                              obscureText: false,
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  hintText: "description"),
                              obscureText: false,
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                            DropdownButton(
                              value: _currentRadio,
                              items: _dropDownMenuItems,
                              onChanged: changedDropDownItem,
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.2),
                      child: ButtonTheme(
                        minWidth: 300,
                        child: RaisedButton(
                          onPressed: () {
                            // Validate returns true if the form is valid, otherwise false.
                            if (_formKey.currentState.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              _scaff.currentState.showSnackBar(snackBar);
                            }
                          },
                          color: color,
                          elevation: 10,
                          shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            'Ajouter',
                            style: TextStyle(
                                color: Colors.white,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  dataFromSql() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'favoris.db');
    print(path);
    // Delete the database
    //await deleteDatabase(path);
    // open the database
    final Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE radio(id_radio INTEGER PRIMARY KEY, name TEXT,url TEXT, text_radio TEXT, note INTEGER ,Sprache TEXT ,Land TEXT)');
    });
    // Close the database
    //await database.close();
    return database;
  }

  Future<List<radio>> insert(radio RowStation) async {
    var database = await openDatabase('favoris.db');
    await database.transaction((txn) async {
      int id1 = await txn.rawInsert(
          //id_radio,name,text_radio,url,note,sprache,land
          'INSERT INTO radio(id_radio,name,text_radio,url,note,sprache,Land) VALUES("${RowStation.id_radio}","${RowStation.name}","${RowStation.text_radio}","${RowStation.url}","${RowStation.note}","${RowStation.Sprache}","${RowStation.Land}")');
      print('inserted1: $id1');
    });
    return await getList();
  }

  Future<List<radio>> radioDB() async {
    // Get a reference to the database.
    final Database db = await dataFromSql();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('radio');
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return radio(
          id_radio: maps[i]['id_radio'].toString(),
          name: maps[i]['name'],
          text_radio: maps[i]['text_radio'],
          url: maps[i]['url'],
          note: maps[i]['note'],
          Sprache: maps[i]['Sprache'],
          Land: maps[i]['Land']);
    });
  }

  Future<List<radio>> delete(String id_radio) async {
    // Get a reference to the database.
    final db = await dataFromSql();
    int id_radio_ = int.parse(id_radio);
    // Remove the Dog from the Database.
    await db.delete(
      'radio',
      // Use a `where` clause to delete a specific dog.
      where: "id_radio = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id_radio_],
    );
    return await getList();
  }

  Widget _radioInterface() {}
  /*check if the object is in the list , condition is id_radio*/
  bool checkIfContains(List<radio> checkedList, radio checkedRadio) {
    for (radio a in checkedList) {
      if (a.id_radio == checkedRadio.id_radio) {
        return true;
      }
    }
    return false;
  }
}
