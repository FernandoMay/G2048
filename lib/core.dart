import 'dart:math';

enum GameStatus {
  playing,
  won,
  lost,
}

class Game2048 {
  final int gridSize;
  late List<List<int>> grid;
  late Random random;
  int score = 0;
  late GameStatus status;

  Game2048({this.gridSize = 4}) {
    grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    random = Random();
    score = 0;
    status = GameStatus.playing;

    // Inicializar dos celdas con números aleatorios al inicio del juego
    generateRandomNumber();
    generateRandomNumber();
  }

  void generateRandomNumber() {
    // Encontrar una celda vacía para generar el número aleatorio
    List<int> emptyCells = [];
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] == 0) {
          emptyCells.add(row * gridSize + col);
        }
      }
    }

    if (emptyCells.isEmpty)
      return; // No hay celdas vacías, el juego ha terminado

    // Generar un número aleatorio (2 o 4) en una celda vacía al azar
    int randomCellIndex = emptyCells[random.nextInt(emptyCells.length)];
    int row = randomCellIndex ~/ gridSize;
    int col = randomCellIndex % gridSize;
    grid[row][col] = random.nextInt(10) < 9 ? 2 : 4;
  }

  void swipeLeft() {
    if (status != GameStatus.playing) return;

    bool hasMoved = false;

    for (int row = 0; row < gridSize; row++) {
      List<int> mergedRow = mergeCells(grid[row]);
      if (grid[row] != mergedRow) hasMoved = true;
      grid[row] = mergedRow;
    }

    if (hasMoved) {
      generateRandomNumber();
      checkGameStatus();
    }
  }

  void swipeRight() {
    if (status != GameStatus.playing) return;

    bool hasMoved = false;

    for (int row = 0; row < gridSize; row++) {
      List<int> mergedRow = mergeCells(grid[row].reversed.toList());
      if (grid[row] != mergedRow) hasMoved = true;
      grid[row] = mergedRow.reversed.toList();
    }

    if (hasMoved) {
      generateRandomNumber();
      checkGameStatus();
    }
  }

  void swipeUp() {
    if (status != GameStatus.playing) return;

    bool hasMoved = false;

    for (int col = 0; col < gridSize; col++) {
      List<int> column = [];
      for (int row = 0; row < gridSize; row++) {
        column.add(grid[row][col]);
      }
      List<int> mergedColumn = mergeCells(column);
      if (column != mergedColumn) hasMoved = true;
      for (int row = 0; row < gridSize; row++) {
        grid[row][col] = mergedColumn[row];
      }
    }

    if (hasMoved) {
      generateRandomNumber();
      checkGameStatus();
    }
  }

  void swipeDown() {
    if (status != GameStatus.playing) return;

    bool hasMoved = false;

    for (int col = 0; col < gridSize; col++) {
      List<int> column = [];
      for (int row = gridSize - 1; row >= 0; row--) {
        column.add(grid[row][col]);
      }
      List<int> mergedColumn = mergeCells(column);
      if (column != mergedColumn) hasMoved = true;
      for (int row = gridSize - 1; row >= 0; row--) {
        grid[row][col] = mergedColumn[gridSize - 1 - row];
      }
    }

    if (hasMoved) {
      generateRandomNumber();
      checkGameStatus();
    }
  }

  List<int> mergeCells(List<int> cells) {
    List<int> mergedCells = List.filled(gridSize, 0);
    int index = 0;

    for (int i = 0; i < gridSize; i++) {
      if (cells[i] != 0) {
        if (index > 0 && mergedCells[index - 1] == cells[i]) {
          mergedCells[index - 1] *= 2;
          score += mergedCells[index - 1];
        } else {
          mergedCells[index] = cells[i];
          index++;
        }
      }
    }

    return mergedCells;
  }

  void checkGameStatus() {
    // Comprueba si el jugador ha ganado (un número alcanza 2048)
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] == 2048) {
          status = GameStatus.won;
          return;
        }
      }
    }

    // Comprueba si el jugador ha perdido (no hay movimientos posibles)
    List<int> directions = [-1, 1, -gridSize, gridSize];
    bool canMove = false;

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] == 0) {
          canMove = true;
        } else {
          for (int direction in directions) {
            int newRow = row + direction ~/ gridSize;
            int newCol = col + direction % gridSize;

            if (newRow >= 0 &&
                newRow < gridSize &&
                newCol >= 0 &&
                newCol < gridSize &&
                (grid[row][col] == grid[newRow][newCol] ||
                    grid[newRow][newCol] == 0)) {
              canMove = true;
              break;
            }
          }
        }
      }
    }

    status = canMove ? GameStatus.playing : GameStatus.lost;
  }
}
