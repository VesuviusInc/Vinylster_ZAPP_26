class GameHistoryPlayer {
  final String gameID;
  final String name;

  const GameHistoryPlayer({required this.gameID, required this.name});

  Map<String, Object?> toMap() {
    return {'gameID': gameID, 'name': name};
  }

  @override
  String toString() {
    return 'gameHistoryPlayer{gameID: $gameID, name: $name}';
  }
}
