class Word {
  final String word;
  final String en;
  final String ru;
  final String? _imgOverride;
  final String _imgDir;
  final String collection;

  String imgPath() {
    String imgName = _imgOverride == null ? en : _imgOverride!;
    return '$_imgDir/$imgName.webp';
  }

  Word.fromJson(
      this.word, this.collection, this._imgDir, Map<String, dynamic> json)
      : en = json['en'],
        ru = json['ru'],
        _imgOverride =
            json.containsKey('imgOverride') ? json['imgOverride'] : null;
}
