import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:g2048/models/game_state.dart';

final gameControllerProvider = StateNotifierProvider<GameController, GameState>((ref) {
  return GameController();
});

class GameController extends StateNotifier<GameState> {
  GameController() : super(GameState.initial()) {
    _initializeGame();
  }

  void _initializeGame() {
    state = GameState.initial();
    _addRandomTile();
    _addRandomTile();
  }

  void _addRandomTile() {
    List<List<int>> emptyCells = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (state.board[i][j] == 0) {
          emptyCells.add([i, j]);
        }
      }
    }

    if (emptyCells.isEmpty) return;

    final random = emptyCells[DateTime.now().millisecondsSinceEpoch % emptyCells.length];
    final value = DateTime.now().millisecondsSinceEpoch % 10 < 9 ? 2 : 4;

    List<List<int>> newBoard = List.from(
      state.board.map((row) => List.from(row)),
    );
    newBoard[random[0]][random[1]] = value;

    state = state.copyWith(board: newBoard);
  }

  void move(Direction direction) {
    if (state.status != GameStatus.playing) return;

    final List<List<int>> newBoard = List.from(
      state.board.map((row) => List.from(row)),
    );
    int newScore = state.score;
    bool moved = false;

    switch (direction) {
      case Direction.left:
        moved = _moveLeft(newBoard, newScore);
        break;
      case Direction.right:
        moved = _moveRight(newBoard, newScore);
        break;
      case Direction.up:
        moved = _moveUp(newBoard, newScore);
        break;
      case Direction.down:
        moved = _moveDown(newBoard, newScore);
        break;
    }

    if (moved) {
      state = state.copyWith(
        board: newBoard,
        score: newScore,
      );
      _addRandomTile();
      _checkGameStatus();
      _checkAchievements();
    }
  }

  bool _moveLeft(List<List<int>> board, int score) {
    bool moved = false;
    for (int i = 0; i < 4; i++) {
      List<int> row = List.from(board[i]);
      List<int> newRow = List.filled(4, 0);
      int index = 0;

      // Merge tiles
      for (int j = 0; j < 4; j++) {
        if (row[j] != 0) {
          if (index > 0 && newRow[index - 1] == row[j]) {
            newRow[index - 1] *= 2;
            score += newRow[index - 1];
          } else {
            newRow[index] = row[j];
            index++;
          }
        }
      }

      if (row.join() != newRow.join()) {
        moved = true;
        board[i] = newRow;
      }
    }
    return moved;
  }

  bool _moveRight(List<List<int>> board, int score) {
    bool moved = false;
    for (int i = 0; i < 4; i++) {
      List<int> row = List.from(board[i].reversed);
      List<int> newRow = List.filled(4, 0);
      int index = 0;

      for (int j = 0; j < 4; j++) {
        if (row[j] != 0) {
          if (index > 0 && newRow[index - 1] == row[j]) {
            newRow[index - 1] *= 2;
            score += newRow[index - 1];
          } else {
            newRow[index] = row[j];
            index++;
          }
        }
      }

      newRow = newRow.reversed.toList();
      if (board[i].join() != newRow.join()) {
        moved = true;
        board[i] = newRow;
      }
    }
    return moved;
  }

  bool _moveUp(List<List<int>> board, int score) {
    bool moved = false;
    for (int j = 0; j < 4; j++) {
      List<int> column = [board[0][j], board[1][j], board[2][j], board[3][j]];
      List<int> newColumn = List.filled(4, 0);
      int index = 0;

      for (int i = 0; i < 4; i++) {
        if (column[i] != 0) {
          if (index > 0 && newColumn[index - 1] == column[i]) {
            newColumn[index - 1] *= 2;
            score += newColumn[index - 1];
          } else {
            newColumn[index] = column[i];
            index++;
          }
        }
      }

      if (column.join() != newColumn.join()) {
        moved = true;
        for (int i = 0; i < 4; i++) {
          board[i][j] = newColumn[i];
        }
      }
    }
    return moved;
  }

  bool _moveDown(List<List<int>> board, int score) {
    bool moved = false;
    for (int j = 0; j < 4; j++) {
      List<int> column = [board[3][j], board[2][j], board[1][j], board[0][j]];
      List<int> newColumn = List.filled(4, 0);
      int index = 0;

      for (int i = 0; i < 4; i++) {
        if (column[i] != 0) {
          if (index > 0 && newColumn[index - 1] == column[i]) {
            newColumn[index - 1] *= 2;
            score += newColumn[index - 1];
          } else {
            newColumn[index] = column[i];
            index++;
          }
        }
      }

      newColumn = newColumn.reversed.toList();
      if ([board[3][j], board[2][j], board[1][j], board[0][j]].join() != newColumn.join()) {
        moved = true;
        for (int i = 0; i < 4; i++) {
          board[i][j] = newColumn[i];
        }
      }
    }
    return moved;
  }

  void _checkGameStatus() {
    bool hasWon = false;
    bool hasEmpty = false;
    bool canMove = false;

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (state.board[i][j] == 2048) {
          hasWon = true;
        }
        if (state.board[i][j] == 0) {
          hasEmpty = true;
        }
      }
    }

    if (!hasEmpty) {
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          if (i < 3 && state.board[i][j] == state.board[i + 1][j] ||
              j < 3 && state.board[i][j] == state.board[i][j + 1]) {
            canMove = true;
            break;
          }
        }
        if (canMove) break;
      }
    }

    if (hasWon) {
      state = state.copyWith(status: GameStatus.won);
    } else if (!hasEmpty && !canMove) {
      state = state.copyWith(status: GameStatus.lost);
    }
  }

  void _checkAchievements() {
    Map<String, bool> newAchievements = Map.from(state.achievements);
    
    if (state.score >= 1000 && !state.achievements['Beginner']!) {
      newAchievements['Beginner'] = true;
    }
    if (state.score >= 10000 && !state.achievements['Pro']!) {
      newAchievements['Pro'] = true;
    }
    if (state.status == GameStatus.won && !state.achievements['Master']!) {
      newAchievements['Master'] = true;
    }

    if (state.score > state.highScore) {
      state = state.copyWith(
        achievements: newAchievements,
        highScore: state.score,
      );
    } else {
      state = state.copyWith(achievements: newAchievements);
    }
  }

  void resetGame() {
    _initializeGame();
  }
}
