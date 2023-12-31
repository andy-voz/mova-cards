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
        words = (json['words'] as Map).map((wordId, data) =>
            MapEntry<String, Word>(wordId,
                Word.fromJson(wordId, json['name'], json['imgDir'], data)));
}
