
import 'dart:core';

class radiosList {
  final List<radio> radios;

  radiosList({
    this.radios,
  });

  factory radiosList.fromJson(List<dynamic> parsedJson) {

    List<radio> radios = new List<radio>();
    radios = parsedJson.map((i)=>radio.fromJson(i)).toList();

    return new radiosList(
        radios:radios
    );
  }
}
class radio implements Iterable<radio>{
  String id_radio;
  String name;
  String text_radio;
  String url;
  int note;
  String Land;
  String Sprache;
  int id_Land;
  int id_Sprache;

  radio({this.id_radio, this.name, this.text_radio, this.url, this.note, this.Land, this.Sprache,this.id_Land,this.id_Sprache});

  factory radio.fromJson(Map<String, dynamic> parsedJson){
    return radio(
        id_radio: parsedJson['id_radio'],
        name : parsedJson['name'],
        text_radio : parsedJson ['text_radio'],
        url : parsedJson ['url'],
        note : int.parse(parsedJson ['note']),
        Land : parsedJson ['Land'],
        Sprache : parsedJson ['Sprache'],
        id_Land : int.parse(parsedJson ['id_Land']),
        id_Sprache : int.parse(parsedJson ['id_Sprache'])
    );
  }



  Map<String,dynamic> toMap(){
    return {
    'id_radio' : id_radio,
    'name': name,
    'text_radio': text_radio,
      'url': url,
      'note': note,
      'Land': Land,
      'Sprache': Sprache,
      'id_Sprache': id_Sprache,
      'id_Land': id_Land
    };
  }

  @override
  bool any(bool Function(radio element) test) {
    // TODO: implement any
    return null;
  }

  @override
  Iterable<R> cast<R>() {
    // TODO: implement cast
    return null;
  }

  @override
  bool contains(Object element) {
      /*for (radio e in this) {
        if (e == element) return true;
      }*/
      print("contains");
      return true;
  }

  @override
  radio elementAt(int index) {
    // TODO: implement elementAt
    return null;
  }

  @override
  bool every(bool Function(radio element) test) {
    // TODO: implement every
    return null;
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(radio element) f) {
    // TODO: implement expand
    return null;
  }

  @override
  // TODO: implement first
  radio get first => null;

  @override
  radio firstWhere(bool Function(radio element) test, {radio Function() orElse}) {
    // TODO: implement firstWhere
    return null;
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, radio element) combine) {
    // TODO: implement fold
    return null;
  }

  @override
  Iterable<radio> followedBy(Iterable<radio> other) {
    // TODO: implement followedBy
    return null;
  }

  @override
  void forEach(void Function(radio element) f) {
    // TODO: implement forEach
  }

  @override
  // TODO: implement isEmpty
  bool get isEmpty => null;

  @override
  // TODO: implement isNotEmpty
  bool get isNotEmpty => null;

  @override
  // TODO: implement iterator
  Iterator<radio> get iterator => null;

  @override
  String join([String separator = ""]) {
    // TODO: implement join
    return null;
  }

  @override
  // TODO: implement last
  radio get last => null;

  @override
  radio lastWhere(bool Function(radio element) test, {radio Function() orElse}) {
    // TODO: implement lastWhere
    return null;
  }

  @override
  // TODO: implement length
  int get length => null;

  @override
  Iterable<T> map<T>(T Function(radio e) f) {
    // TODO: implement map
    return null;
  }

  @override
  radio reduce(radio Function(radio value, radio element) combine) {
    // TODO: implement reduce
    return null;
  }

  @override
  // TODO: implement single
  radio get single => null;

  @override
  radio singleWhere(bool Function(radio element) test, {radio Function() orElse}) {
    // TODO: implement singleWhere
    return null;
  }

  @override
  Iterable<radio> skip(int count) {
    // TODO: implement skip
    return null;
  }

  @override
  Iterable<radio> skipWhile(bool Function(radio value) test) {
    // TODO: implement skipWhile
    return null;
  }

  @override
  Iterable<radio> take(int count) {
    // TODO: implement take
    return null;
  }

  @override
  Iterable<radio> takeWhile(bool Function(radio value) test) {
    // TODO: implement takeWhile
    return null;
  }

  @override
  List<radio> toList({bool growable = true}) {
    // TODO: implement toList
    return null;
  }

  @override
  Set<radio> toSet() {
    // TODO: implement toSet
    return null;
  }

  @override
  Iterable<radio> where(bool Function(radio element) test) {
    // TODO: implement where
    return null;
  }

  @override
  Iterable<T> whereType<T>() {
    // TODO: implement whereType
    return null;
  }



}