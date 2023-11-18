class SavedWord {
  String id;
  DateTime timeOfAccess;

  SavedWord(this.id, this.timeOfAccess);

  SavedWord.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        timeOfAccess =
            DateTime.fromMillisecondsSinceEpoch(json['timeOfAccess']);

  Map<String, dynamic> toJson() =>
      {'id': id, 'timeOfAccess': timeOfAccess.millisecondsSinceEpoch};

  @override
  String toString() {
    return id;
  }

  @override
  bool operator ==(other) => other is SavedWord && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
