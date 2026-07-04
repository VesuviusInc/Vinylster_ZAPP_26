class GameHistoryPlayer {
  final String gameID;
  final String name;
  final int tokenAmount;
  final int trackAmount;

  const GameHistoryPlayer({required this.gameID, required this.name, required this.tokenAmount, required this.trackAmount});

  Map<String, Object?> toMap() {
    return {'gameID': gameID, 'name': name, 'tokenAmount': tokenAmount, 'trackAmount': trackAmount};
  }

  @override
  String toString() {
    return 'gameHistoryPlayer{gameID: $gameID, name: $name, tokenAmount: $tokenAmount, trackAmount: $trackAmount}';
  }
}
