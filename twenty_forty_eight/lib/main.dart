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

  @override
  void initState() {
    super.initState();
    _board = GameBoard();
    _loadBestScore();
    // GameBoard creates a new board with random tiles in its constructor, so we don't need to call reset() here.
    // but if we wanted to start with an empty board and then add tiles, we could do:
    // _board.reset();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = math.min(size.width, size.height);
    final boardSize = math.max(shortestSide * 0.9, 200.0);

    return Scaffold(
      appBar: AppBar(title: const Text('2048'), centerTitle: true),
      body: GestureDetector(
        // horizontal swipes
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 0) {
            // swipe right
            _handleSwipeRight();
          } else if (velocity < 0) {
            // swipe left
            _handleSwipeLeft();
          }
        },
        // vertical swipes
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 0) {
            // swipe down
            _handleSwipeDown();
          } else if (velocity < 0) {
            // swipe up
            _handleSwipeUp();
          }
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Score
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

              // Game Board
              SizedBox(
                width: boardSize,
                height: boardSize,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: GameBoard.size, // 4
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: GameBoard.size * GameBoard.size,
                    itemBuilder: (context, index) {
                      final row = index ~/ GameBoard.size;
                      final col = index % GameBoard.size;
                      final value = _board.board[row][col];

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

                      return Container(
                        decoration: BoxDecoration(
                          color: tileColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            value == 0 ? '' : value.toString(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Restart
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
