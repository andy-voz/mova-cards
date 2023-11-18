class Word {
  final String id;
  final String by;
  final String en;
  final String ru;
  final String _imgDir;
  final String collection;

  String imgPath() {
    return '$_imgDir/$id.webp';
  }

  Word.fromJson(this.id, this.collection, this._imgDir, Map<String, dynamic> json)
      : by = json['by'], 
        en = json['en'],
        ru = json['ru'];
}
