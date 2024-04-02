import 'package:flutter/material.dart';

void main() => runApp(SuperTicTacToeApp());

class SuperTicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
            .copyWith(secondary: Colors.teal),
      ),
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late List<List<String>> board;
  bool xTurn = true; // X starts first
  int xWins = 0; // To track small wins for 'X'
  int oWins = 0; // To track small wins for 'O'

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(9, (_) => List.generate(9, (_) => ''));
    xWins = 0;
    oWins = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: 81,
        itemBuilder: (context, index) {
          int row = index ~/ 9;
          int col = index % 9;
          return GestureDetector(
            onTap: () => _markCell(row, col),
            child: Card(
              color: Theme.of(context).primaryColorLight,
              elevation: 4,
              child: Center(
                child: _getIconForPosition(row, col),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getIconForPosition(int row, int col) {
    var value = board[row][col];
    switch (value) {
      case 'X':
        return Icon(Icons.close, size: 24, color: Colors.white);
      case 'O':
        return Icon(Icons.panorama_fish_eye, size: 24, color: Colors.white);
      default:
        return SizedBox.shrink();
    }
  }

  void _markCell(int row, int col) {
    if (board[row][col] == '' && xTurn) {
      setState(() {
        board[row][col] = 'X';
        if (_checkWinner(row, col, 'X')) {
          xWins++;
          if (xWins >= 3) {
            _showWinnerDialog('X');
            return;
          }
        }
        xTurn = !xTurn;
        // Bot makes a move after a short delay
        Future.delayed(Duration(milliseconds: 500), _botMove);
      });
    }
  }

  bool _checkWinner(int row, int col, String player) {
  // Check horizontal lines
  for (int r = 0; r < 9; r++) {
    for (int c = 0; c < 7; c++) {
      if (board[r][c] == player && board[r][c + 1] == player && board[r][c + 2] == player) {
        return true;
      }
    }
  }

  // Check vertical lines
  for (int c = 0; c < 9; c++) {
    for (int r = 0; r < 7; r++) {
      if (board[r][c] == player && board[r + 1][c] == player && board[r + 2][c] == player) {
        return true;
      }
    }
  }

  // Check diagonal (top-left to bottom-right)
  for (int r = 0; r < 7; r++) {
    for (int c = 0; c < 7; c++) {
      if (board[r][c] == player && board[r + 1][c + 1] == player && board[r + 2][c + 2] == player) {
        return true;
      }
    }
  }

  // Check diagonal (bottom-left to top-right)
  for (int r = 8; r >= 2; r--) {
    for (int c = 0; c < 7; c++) {
      if (board[r][c] == player && board[r - 1][c + 1] == player && board[r - 2][c + 2] == player) {
        return true;
      }
    }
  }

  return false;
}


  void _botMove() {
  // Ensure it's 'O's turn and there are available moves
  if (!xTurn && board.any((row) => row.any((cell) => cell == ''))) {
    // Check for a winning move or a move to block 'X' from winning
    var move = _findWinningMove('O') ?? _findWinningMove('X');
    if (move == null) {
      // No immediate winning or blocking move found, choose randomly
      move = _findRandomMove();
    }

    // Perform the chosen move
    if (move != null) {
      int row = move[0];
      int col = move[1];

      setState(() {
        board[row][col] = 'O';
        if (_checkWinner(row, col, 'O')) {
          oWins++;
          if (oWins >= 3) {
            _showWinnerDialog('O');
            return;
          }
        }
        xTurn = true;
      });
    }
  }
}

List<int>? _findWinningMove(String player) {
  for (int row = 0; row < board.length; row++) {
    for (int col = 0; col < board[row].length; col++) {
      if (board[row][col] == '') {
        // Temporarily make the move
        board[row][col] = player;
        bool wins = _checkWinner(row, col, player);
        // Undo the move
        board[row][col] = '';
        if (wins) {
          return [row, col];
        }
      }
    }
  }
  return null; // No winning move found
}

List<int>? _findRandomMove() {
  List<List<int>> availableMoves = [];
  for (int row = 0; row < board.length; row++) {
    for (int col = 0; col < board[row].length; col++) {
      if (board[row][col] == '') {
        availableMoves.add([row, col]);
      }
    }
  }

  if (availableMoves.isNotEmpty) {
    return (availableMoves..shuffle()).first;
  }
  return null; // No available moves
}

  void _showWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("$winner wins!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeBoard();
                setState(() {});
              },
              child: Text('Restart'),
            ),
          ],
        );
      },
    );
  }
}
