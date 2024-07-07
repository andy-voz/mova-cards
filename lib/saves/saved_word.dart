class SavedWord {
  String id;
  DateTime timeOfAccess;
  bool inRotation;

  static const String separator = ',';

  SavedWord(this.id, this.timeOfAccess, this.inRotation);

  SavedWord.read(List<String> line)
      : id = line[0]
      , timeOfAccess = DateTime.fromMillisecondsSinceEpoch(int.parse(line[1]))
      , inRotation = line[2] == "1";

  String write() => '$id$separator${timeOfAccess.millisecondsSinceEpoch}${inRotation ? "1" : "0"}';

  @override
  String toString() {
    return id;
  }

  @override
  bool operator ==(other) => other is SavedWord && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
