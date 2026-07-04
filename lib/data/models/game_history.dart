class GameHistory {
  final String gameID;
  final String time;
  final int playerAmount;

  const GameHistory({required this.gameID, required this.time, required this.playerAmount});

  Map<String, Object?> toMap() {
    return {'gameID': gameID, 'time': time, 'playerAmount': playerAmount};
  }

  @override
  String toString() {
    return 'gameHistory{gameID: $gameID, time: $time, playerAmount: $playerAmount}';
  }
}
