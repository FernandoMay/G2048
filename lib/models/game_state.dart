enum GameStatus {
  playing,
  won,
  lost,
}

enum Direction {
  up,
  right,
  down,
  left,
}

class GameState {
  final List<List<int>> board;
  final int score;
  final GameStatus status;
  final bool isConnectedToBlockchain;
  final Map<String, bool> achievements;
  final int highScore;

  GameState({
    required this.board,
    required this.score,
    required this.status,
    required this.isConnectedToBlockchain,
    required this.achievements,
    required this.highScore,
  });

  GameState.initial()
      : board = List.generate(4, (_) => List.filled(4, 0)),
        score = 0,
        status = GameStatus.playing,
        isConnectedToBlockchain = false,
        achievements = {
          'Beginner': false,
          'Pro': false,
          'Master': false,
        },
        highScore = 0;

  GameState copyWith({
    List<List<int>>? board,
    int? score,
    GameStatus? status,
    bool? isConnectedToBlockchain,
    Map<String, bool>? achievements,
    int? highScore,
  }) {
    return GameState(
      board: board ?? this.board,
      score: score ?? this.score,
      status: status ?? this.status,
      isConnectedToBlockchain: isConnectedToBlockchain ?? this.isConnectedToBlockchain,
      achievements: achievements ?? this.achievements,
      highScore: highScore ?? this.highScore,
    );
  }
}
