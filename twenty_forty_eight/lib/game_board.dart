import 'dart:math';

class Tile {
  final int id;
  int value;
  int row;
  int col;
  bool justMerged;
  bool justSpawned;

  Tile({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
    this.justMerged = false,
    this.justSpawned = false,
  });
}

class GameBoard {
  static const int size = 4;

  final Random _random = Random();

  // 4x4 matrix for tile values, 0 means empty
  late List<List<int>> board;

  int score = 0;

  List<Tile> tiles = [];
  int _nextId = 0;

  GameBoard() {
    reset();
  }

  void reset() {
    score = 0;
    tiles = [];
    _nextId = 0;
    board = List.generate(size, (_) => List.generate(size, (_) => 0));

    // 3 or 4 starting tiles (can be changed)
    final startTiles = 3 + _random.nextInt(2); // 3 or 4
    for (int i = 0; i < startTiles; i++) {
      _addRandomTile();
    }
    rebuildTilesFromBoard();
  }

  bool moveLeft() {
    _clearFlags();
    bool moved = false;

    final previous = board.map((row) => List<int>.from(row)).toList();

    for (int row = 0; row < size; row++) {
      final original = List<int>.from(board[row]);
      final mergedRow = _mergeLine(board[row]);
      board[row] = mergedRow;
      if (!_listEquals(original, mergedRow)) {
        moved = true;
      }
    }
    if (moved) {
      _addRandomTile();
      rebuildTilesFromBoard(previousBoard: previous);
    }
    return moved;
  }

  bool moveRight() {
    _clearFlags();
    bool moved = false;

    final previous = board.map((row) => List<int>.from(row)).toList();

    for (int row = 0; row < size; row++) {
      final original = List<int>.from(board[row]);
      final reversed = board[row].reversed.toList();
      final mergedReversed = _mergeLine(reversed);
      final merged = mergedReversed.reversed.toList();
      board[row] = merged;
      if (!_listEquals(original, merged)) {
        moved = true;
      }
    }
    if (moved) {
      _addRandomTile();
      rebuildTilesFromBoard(previousBoard: previous);
    }
    return moved;
  }

  bool moveUp() {
    _clearFlags();
    bool moved = false;

    final previous = board.map((row) => List<int>.from(row)).toList();

    board = _transpose(board);
    for (int row = 0; row < size; row++) {
      final original = List<int>.from(board[row]);
      final mergedRow = _mergeLine(board[row]);
      board[row] = mergedRow;
      if (!_listEquals(original, mergedRow)) {
        moved = true;
      }
    }
    board = _transpose(board);
    if (moved) {
      _addRandomTile();
      rebuildTilesFromBoard(previousBoard: previous);
    }
    return moved;
  }

  bool moveDown() {
    _clearFlags();
    bool moved = false;

    final previous = board.map((row) => List<int>.from(row)).toList();

    board = _transpose(board);
    for (int row = 0; row < size; row++) {
      final original = List<int>.from(board[row]);
      final reversed = board[row].reversed.toList();
      final mergedReversed = _mergeLine(reversed);
      final merged = mergedReversed.reversed.toList();
      board[row] = merged;
      if (!_listEquals(original, merged)) {
        moved = true;
      }
    }
    board = _transpose(board);
    if (moved) {
      _addRandomTile();
      rebuildTilesFromBoard(previousBoard: previous);
    }
    return moved;
  }

  bool isGameOver() {
    // if there's an empty cell — not game over
    for (var row in board) {
      if (row.contains(0)) return false;
    }

    // if there's a possible merge — not game over
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final v = board[r][c];
        if (c + 1 < size && board[r][c + 1] == v) return false;
        if (r + 1 < size && board[r + 1][c] == v) return false;
      }
    }
    return true;
  }

  // ===== Internal Helpers =====

  // only merges to the left, for moveRight we reverse before and after
  List<int> _mergeLine(List<int> line) {
    final compressed = _compress(line);
    final merged = List<int>.from(compressed);

    for (int i = 0; i < merged.length - 1; i++) {
      if (merged[i] != 0 && merged[i] == merged[i + 1]) {
        merged[i] = merged[i] * 2;
        score += merged[i]; // update score
        merged[i + 1] = 0;
      }
    }

    return _compress(merged);
  }

  // compresses the line by moving all non-zero values to the left
  List<int> _compress(List<int> line) {
    final nonZero = line.where((v) => v != 0).toList();
    final zeros = List<int>.filled(size - nonZero.length, 0);
    return [...nonZero, ...zeros];
  }

  void rebuildTilesFromBoard({List<List<int>>? previousBoard}) {
    tiles = [];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final value = board[r][c];
        if (value == 0) continue;

        // Detect if tile just spawned (didn't exist at this position before)
        // If previousBoard is null (reset), all tiles are new
        final justSpawned = previousBoard == null || previousBoard[r][c] == 0;

        tiles.add(
          Tile(
            id: _nextId++,
            value: value,
            row: r,
            col: c,
            justSpawned: justSpawned,
            justMerged: false,
          ),
        );
      }
    }
  }

  void _clearFlags() {
    for (final t in tiles) {
      t.justMerged = false;
      t.justSpawned = false;
    }
  }

  void _addRandomTile() {
    final empty = <Point<int>>[];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (board[r][c] == 0) {
          empty.add(Point(r, c));
        }
      }
    }
    if (empty.isEmpty) return;

    final pos = empty[_random.nextInt(empty.length)];
    final value = _random.nextDouble() < 0.9 ? 2 : 4;
    board[pos.x][pos.y] = value;
    // tiles НЕ трогаем — rebuildTilesFromBoard() сделает это сам
  }

  List<List<int>> _transpose(List<List<int>> matrix) {
    final result = List.generate(size, (_) => List<int>.filled(size, 0));
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        result[c][r] = matrix[r][c];
      }
    }
    return result;
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
