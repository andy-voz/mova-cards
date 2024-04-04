class SavedWord {
  String id;
  DateTime timeOfAccess;

  static const String separator = ',';

  SavedWord(this.id, this.timeOfAccess);

  SavedWord.read(List<String> line)
      : id = line[0],
        timeOfAccess =
            DateTime.fromMillisecondsSinceEpoch(int.parse(line[1]));

  String write() => '$id$separator${timeOfAccess.millisecondsSinceEpoch}';

  @override
  String toString() {
    return id;
  }

  @override
  bool operator ==(other) => other is SavedWord && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
