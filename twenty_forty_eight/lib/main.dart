import 'package:flutter/material.dart';
import 'game_board.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TwentyFortyEightApp());
}

class TwentyFortyEightApp extends StatelessWidget {
  const TwentyFortyEightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameBoard _board;
  int _bestScore = 0;

  static const double _tileSpacing = 8.0;

  double _tileSize(double boardSize) {
    final totalSpacing = _tileSpacing * (GameBoard.size + 1);
    return (boardSize - totalSpacing) / GameBoard.size;
  }

  (Color, Color) _tileColors(int value) {
    Color tileColor;
    Color textColor = Colors.white;

    if (value == 0) {
      tileColor = Colors.grey.shade700;
      textColor = Colors.transparent;
    } else if (value == 2) {
      tileColor = Colors.orange.shade100;
      textColor = Colors.black87;
    } else if (value == 4) {
      tileColor = Colors.orange.shade200;
      textColor = Colors.black87;
    } else if (value <= 16) {
      tileColor = Colors.orange.shade300;
    } else if (value <= 64) {
      tileColor = Colors.orange.shade400;
    } else {
      tileColor = Colors.orange.shade600;
    }

    return (tileColor, textColor);
  }

  @override
  void initState() {
    super.initState();
    _board = GameBoard();
    _loadBestScore();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bestScore = prefs.getInt('best_score') ?? 0;
    });
  }

  Future<void> _saveBestScoreIfNeeded() async {
    if (_board.score <= _bestScore) return;
    _bestScore = _board.score;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('best_score', _bestScore);
  }

  void _restartGame() {
    setState(() {
      _board.reset();
    });
  }

  void _handleSwipeLeft() {
    final moved = _board.moveLeft();
    if (moved) {
      setState(() {});
      _checkGameOver();
    }
  }

  void _handleSwipeRight() {
    final moved = _board.moveRight();
    if (moved) {
      setState(() {});
      _checkGameOver();
    }
  }

  void _handleSwipeUp() {
    final moved = _board.moveUp();
    if (moved) {
      setState(() {});
      _checkGameOver();
    }
  }

  void _handleSwipeDown() {
    final moved = _board.moveDown();
    if (moved) {
      setState(() {});
      _checkGameOver();
    }
  }

  void _checkGameOver() async {
    if (_board.isGameOver()) {
      await _saveBestScoreIfNeeded();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Game over'),
          content: Text('Score: ${_board.score}\nBest: $_bestScore'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },
              child: const Text('Restart'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBoardBackground(double boardSize, double tileSize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(_tileSpacing),
      child: Column(
        children: List.generate(GameBoard.size, (row) {
          return Expanded(
            child: Row(
              children: List.generate(GameBoard.size, (col) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.all(_tileSpacing / 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildAnimatedTiles(double boardSize, double tileSize) {
    final widgets = <Widget>[];

    for (final tile in _board.tiles) {
      final value = tile.value;
      final left = _tileSpacing + tile.col * (tileSize + _tileSpacing);
      final top = _tileSpacing + tile.row * (tileSize + _tileSpacing);

      final colors = _tileColors(value);
      final tileColor = colors.$1;
      final textColor = colors.$2;

       final bool pop = tile.justMerged || tile.justSpawned;
     

      widgets.add(
        AnimatedPositioned(
          key: ValueKey(tile.id),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          left: left,
          top: top,
          width: tileSize,
          height: tileSize,
          child: TweenAnimationBuilder<double>(
            key: ValueKey('scale-${tile.id}-${tile.justMerged}-${tile.justSpawned}'),
            tween: Tween<double>(begin: pop ? 0.85 : 1.0, end: 1.0),
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = math.min(size.width, size.height);
    final boardSize = math.max(shortestSide * 0.9, 200.0);
    final tileSize = _tileSize(boardSize);

    return Scaffold(
      appBar: AppBar(title: const Text('2048'), centerTitle: true),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 0) {
            _handleSwipeRight();
          } else if (velocity < 0) {
            _handleSwipeLeft();
          }
        },
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 0) {
            _handleSwipeDown();
          } else if (velocity < 0) {
            _handleSwipeUp();
          }
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Score + Best
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Score', style: TextStyle(fontSize: 16)),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _board.score.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Best', style: TextStyle(fontSize: 16)),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _bestScore.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Board
              SizedBox(
                width: boardSize,
                height: boardSize,
                child: Stack(
                  children: [
                    _buildBoardBackground(boardSize, tileSize),
                    ..._buildAnimatedTiles(boardSize, tileSize),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _restartGame,
                child: const Text('Restart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
