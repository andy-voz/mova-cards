import '../word.dart';

class Collection {
  late String name;
  final String _backImg;
  final String _imgDir;
  Map<String, Word> words;

  String get backImg => '$_imgDir/$_backImg';

  Collection.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        _backImg = json['backImg'],
        _imgDir = json['imgDir'],
        words = (json['words'] as Map).map((wordName, data) =>
            MapEntry<String, Word>(wordName,
                Word.fromJson(wordName, json['name'], json['imgDir'], data)));
}
