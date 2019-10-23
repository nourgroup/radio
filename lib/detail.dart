import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lab_app/radioStationClass.dart';
import 'package:lab_app/my_flutter_app_icons.dart' as costumIcon;
import 'package:lab_app/Statut.dart';

class radioStation extends StatefulWidget {
  radioStation({Key key, this.title, this.StationRadio,this.state}) : super(key: key);

  final String title;
  final radio StationRadio;
  final Statut state;

  @override
  _HomePageState createState() =>
      _HomePageState(title: title, StationRadio: StationRadio);
}

class _HomePageState extends State<radioStation>
    with SingleTickerProviderStateMixin {
  _HomePageState({this.title, this.StationRadio,this.state});

  final String title;
  radio StationRadio;
  final color = const Color(0xFF4C1F92);
  Statut state;

  @override
  void initState() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        actions: <Widget>[
          IconButton(
            onPressed: (){},
            icon: Icon(Icons.access_alarm),
          )
        ],
      ),
      body: Hero(
        tag: "hero${StationRadio.id_radio}",
        child: Column(
          children: <Widget>[
            Text(
              StationRadio.name,
              style: TextStyle(color: color,fontSize: 26,fontFamily: "Manjari"),
            ),
            Text(
              StationRadio.text_radio,
              style: TextStyle(color: color,fontSize: 16,fontFamily: "Manjari",fontStyle: FontStyle.italic),
            ),
            Center(
              child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                              "http://ng-plus.com/pandroid/radio/icon/${StationRadio.id_radio}.png")))),
            ),
            Center(
              child: Container(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: (state==Statut.play) ? Icon(costumIcon.MyFlutterApp.play_circled2,size: 80.0,color: color,) : Icon(costumIcon.MyFlutterApp.stop_circled2,size: 80.0,color: color,)//(state==Statut.pause) ? Icon(costumIcon.MyFlutterApp.pause_circled2,size: 80.0,color: color,):Icon(costumIcon.MyFlutterApp.stop_circled2,size: 80.0,color: color,),
                    ),
                  ],
                ),
              ),
            ),

            Center(
              child: Row(
                children: <Widget>[
                  Icon((StationRadio.note)>0 ?  Icons.star:Icons.star_border,color: (StationRadio.note)>0 ?  Colors.amber:Colors.grey),
                  Icon((StationRadio.note)>1 ?  Icons.star:Icons.star_border,color: (StationRadio.note)>1 ?  Colors.amber:Colors.grey),
                  Icon((StationRadio.note)>2 ?  Icons.star:Icons.star_border,color: (StationRadio.note)>2 ?  Colors.amber:Colors.grey),
                  Icon((StationRadio.note)>3 ?  Icons.star:Icons.star_border,color: (StationRadio.note)>3 ?  Colors.amber:Colors.grey),
                  Icon((StationRadio.note)>4 ?  Icons.star:Icons.star_border,color: (StationRadio.note)>4 ?  Colors.amber:Colors.grey),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
