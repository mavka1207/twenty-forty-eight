import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_board.dart';

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
  bool _isGameOverDialogVisible = false;

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
    _isGameOverDialogVisible = false;
    setState(() {
      _board.reset();
    });
  }
Future<void> _afterMove() async {
    await _saveBestScoreIfNeeded();
    if (!mounted) return;
    setState(() {});
    _checkGameOver();
  }

  Future<void> _handleMove(bool Function() move) async {
    final moved = move();
    if (moved) {
      await _afterMove();
      return;
    }
  _checkGameOver();
  }

  Future<void> _handleSwipeLeft() => _handleMove(_board.moveLeft);
Future<void> _handleSwipeRight() => _handleMove(_board.moveRight);

  Future<void> _handleSwipeUp() => _handleMove(_board.moveUp);

  Future<void> _handleSwipeDown() => _handleMove(_board.moveDown);

  void _checkGameOver() {
    if (_isGameOverDialogVisible || !_board.isGameOver()) return;

    _isGameOverDialogVisible = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.orange.shade700,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Game Over',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try one more time and beat your best!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text('Score'),
                            const SizedBox(height: 4),
                            Text(
                              '${_board.score}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text('Best'),
                            const SizedBox(height: 4),
                            Text(
                              '$_bestScore',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _restartGame();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Play Again'),
                  ),
                ),
              ],
          ),
         ),
        );
      },
    ).then((_) {
      _isGameOverDialogVisible = false;
    });
  }

  Widget _buildBoardBackground(double boardSize, double tileSize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(_tileSpacing),
      child: Column(
        children: List.generate(GameBoard.size, (_) {
          return Expanded(
            child: Row(
              children: List.generate(GameBoard.size, (_) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(_tileSpacing / 2),
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

       final pop = tile.justMerged || tile.justSpawned;
     

      widgets.add(
        AnimatedPositioned(
          key: ValueKey(tile.id),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          left: left,
          top: top,
          width: tileSize,
          height: tileSize,
          child: TweenAnimationBuilder<Offset>(
            key: ValueKey(
              'merge-shift-${tile.id}-${tile.mergeOffsetRow}-${tile.mergeOffsetCol}-${tile.justMerged}',
            ),
            tween: Tween<Offset>(
              begin: Offset(tile.mergeOffsetCol, tile.mergeOffsetRow),
              end: Offset.zero,
            ),
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            builder: (context, shift, child) {
              return Transform.translate(
                offset: Offset(
                  shift.dx * (tileSize + _tileSpacing),
                  shift.dy * (tileSize + _tileSpacing),
                ),
                child: child,
              );
            },
            child: TweenAnimationBuilder<double>(
              key: ValueKey('scale-${tile.id}-${tile.justMerged}-${tile.justSpawned}'),
              tween: Tween<double>(begin: pop ? 0.85 : 1.0, end: 1.0),
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
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
      ),
      );
    }

    return widgets;
  }
Widget _buildControlButtons() {
    return Column(
      children: [
        IconButton.filled(
          onPressed: _handleSwipeUp,
          icon: const Icon(Icons.keyboard_arrow_up),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filled(
              onPressed: _handleSwipeLeft,
              icon: const Icon(Icons.keyboard_arrow_left),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: _handleSwipeRight,
              icon: const Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
        IconButton.filled(
          onPressed: _handleSwipeDown,
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
      ],
   
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = math.min(size.width, size.height);
    final boardSize = math.min(shortestSide * 0.9, 500.0);
    final tileSize = _tileSize(boardSize);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.grid_4x4_rounded),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '2048',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Combine tiles to reach 2048',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.filledTonal(
              tooltip: 'Restart',
              onPressed: _restartGame,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: boardSize,
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
                ),
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
                _buildControlButtons(),
        
              ],
            ),
          ),
        ),
      ),
    
  );
  }
}
