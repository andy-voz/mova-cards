class SavedWord {
  String word;
  DateTime timeOfAccess;

  SavedWord(this.word, this.timeOfAccess);

  SavedWord.fromJson(Map<String, dynamic> json)
      : word = json['word'],
        timeOfAccess =
            DateTime.fromMillisecondsSinceEpoch(json['timeOfAccess']);

  Map<String, dynamic> toJson() =>
      {'word': word, 'timeOfAccess': timeOfAccess.millisecondsSinceEpoch};

  @override
  String toString() {
    return word;
  }

  @override
  bool operator ==(other) => other is SavedWord && other.word == word;

  @override
  int get hashCode => word.hashCode;
}
