import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _board = GameBoard();
    // GameBoard creates a new board with random tiles in its constructor, so we don't need to call reset() here.
    // but if we wanted to start with an empty board and then add tiles, we could do:
    // _board.reset();
  }

  void _restartGame() {
    setState(() {
      _board.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boardSize = size.width < size.height ? size.width - 32 : size.height - 160;

    return Scaffold(
      appBar: AppBar(
        title: const Text('2048'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Score
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Score',
                    style: TextStyle(fontSize: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _board.score.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
    );
  }
}
