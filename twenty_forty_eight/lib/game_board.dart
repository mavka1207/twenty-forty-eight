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

enum MoveDirection { left, right, up, down }

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

    final startTiles = 3 + _random.nextInt(2); // 3 or 4
    for (int i = 0; i < startTiles; i++) {
      _addRandomTile();
    }
  }

  bool moveLeft() => _move(MoveDirection.left);
  bool moveRight() => _move(MoveDirection.right);
  bool moveUp() => _move(MoveDirection.up);
  bool moveDown() => _move(MoveDirection.down);

  bool _move(MoveDirection direction) {
    _clearFlags();
    final newTiles = <Tile>[];
    bool moved = false;

    for (int line = 0; line < size; line++) {
      final lineTiles = _tilesForLine(line, direction);

      lineTiles.sort((a, b) {
        final aPos = _positionAlongDirection(a, direction);
        final bPos = _positionAlongDirection(b, direction);
        return aPos.compareTo(bPos);
      });

      int writeIndex = 0;
      int i = 0;

      while (i < lineTiles.length) {
        final current = lineTiles[i];
        final canMerge =
            i + 1 < lineTiles.length && lineTiles[i + 1].value == current.value;

        final target = _targetPosition(line, writeIndex, direction);

        if (canMerge) {
          final mergedValue = current.value * 2;
          score += mergedValue;
          moved = true;

          if (current.row != target.$1 || current.col != target.$2) {
            moved = true;
          }

          current
            ..row = target.$1
            ..col = target.$2
            ..value = mergedValue
            ..justMerged = true
            ..justSpawned = false;

          // Consumed tile disappears after merge (lineTiles[i + 1]).
          newTiles.add(current);
          i += 2;
        } else {
          if (current.row != target.$1 || current.col != target.$2) {
            moved = true;
          }

          current
            ..row = target.$1
            ..col = target.$2
            ..justMerged = false
            ..justSpawned = false;

          newTiles.add(current);
          i += 1;
        }
        writeIndex += 1;
      }
    }
    if (!moved) {
      return false;
    }
    tiles = newTiles;
    _syncBoardFromTiles();
    _addRandomTile();
    return true;
  }

  bool isGameOver() {
    for (var row in board) {
      if (row.contains(0)) return false;
    }

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final v = board[r][c];
        if (c + 1 < size && board[r][c + 1] == v) return false;
        if (r + 1 < size && board[r + 1][c] == v) return false;
      }
    }
    return true;
  }

  List<Tile> _tilesForLine(int line, MoveDirection direction) {
    switch (direction) {
      case MoveDirection.left:
      case MoveDirection.right:
        return tiles.where((t) => t.row == line).toList();
      case MoveDirection.up:
      case MoveDirection.down:
        return tiles.where((t) => t.col == line).toList();
    }
  }

  int _positionAlongDirection(Tile tile, MoveDirection direction) {
    switch (direction) {
      case MoveDirection.left:
        return tile.col;
      case MoveDirection.right:
        return size - 1 - tile.col;
      case MoveDirection.up:
        return tile.row;
      case MoveDirection.down:
        return size - 1 - tile.row;
    }
  }

  (int, int) _targetPosition(
    int line,
    int writeIndex,
    MoveDirection direction,
  ) {
    switch (direction) {
      case MoveDirection.left:
        return (line, writeIndex);
      case MoveDirection.right:
        return (line, size - 1 - writeIndex);
      case MoveDirection.up:
        return (writeIndex, line);
      case MoveDirection.down:
        return (size - 1 - writeIndex, line);
    }
  }

  void _syncBoardFromTiles() {
    board = List.generate(size, (_) => List.generate(size, (_) => 0));
    for (final tile in tiles) {
      board[tile.row][tile.col] = tile.value;
    }
  }

  void _clearFlags() {
    for (final t in tiles) {
      t.justMerged = false;
      t.justSpawned = false;
    }
  }

  void _addRandomTile() {
    _syncBoardFromTiles();
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
    final tile = Tile(
      id: _nextId++,
      value: value,
      row: pos.x,
      col: pos.y,
      justSpawned: true,
      justMerged: false,
    );
    tiles.add(tile);
    board[pos.x][pos.y] = value;
  }
}

