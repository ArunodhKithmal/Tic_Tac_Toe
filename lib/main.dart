import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(NoughtsAndCrosses());
}

class NoughtsAndCrosses extends StatelessWidget {
  const NoughtsAndCrosses({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LandingScreen(), // Show landing screen first
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'PlayfairDisplay',
      ),
    );
  }
}

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Future.delayed(Duration(seconds: 5), () {
      Navigator.of(
        // ignore: use_build_context_synchronously
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => GameScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 162, 189, 240),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.grid_3x3,
                size: 300,
                color: const Color.fromARGB(255, 59, 83, 128),
              ),
              SizedBox(height: 20),
              Text(
                'Tic Tac Toe',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 59, 83, 128),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int wins = 0;
  int losses = 0;
  int draws = 0;
  bool useRandomNext = true;
  List<Map<String, dynamic>> moveHistory = [];
  List<List<dynamic>> board = [];
  bool gameOver = false;
  bool hasFirstMove = false;
  bool gameStarted = false;
  String resultText = '';
  String currentPlayer = 'X';
  String gameMode = "Easy";
  String firstPlayerName = '';
  String secondPlayerName = '';

  @override
  void initState() {
    super.initState();
    resetBoard();
    loadStats(); // Load saved stats
  }

  void loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      wins = prefs.getInt('wins') ?? 0;
      losses = prefs.getInt('losses') ?? 0;
      draws = prefs.getInt('draws') ?? 0;
    });
  }

  void saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('wins', wins);
    prefs.setInt('losses', losses);
    prefs.setInt('draws', draws);
  }

  void resetBoard() {
    setState(() {
      board = List.generate(9, (_) => [0, null]);
      moveHistory.clear();
      gameOver = false;
      hasFirstMove = false;
      gameStarted = false;
      resultText = '';
      currentPlayer = 'X';
      firstPlayerName = '';
      secondPlayerName = '';
    });
  }

  void displayMove(String symbol, int cell) {
    setState(() {
      board[cell][0] = symbol;
      moveHistory.add({'player': symbol, 'cell': cell});
    });
  }

  void undoLastMove() {
    if (gameMode == 'multiplayer') {
      if (moveHistory.isNotEmpty) {
        setState(() {
          var lastMove = moveHistory.removeLast();
          board[lastMove['cell']][0] = 0;
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
          gameOver = false;
        });
      }
    } else {
      if (moveHistory.length >= 2) {
        setState(() {
          var lastComputerMove = moveHistory.removeLast();
          board[lastComputerMove['cell']][0] = 0;
          var lastPlayerMove = moveHistory.removeLast();
          board[lastPlayerMove['cell']][0] = 0;
          gameOver = false;
        });
      }
    }
  }

  List<int> getEmptyCells() {
    List<int> emptyCells = [];
    for (int i = 0; i < 9; i++) {
      if (board[i][0] == 0) {
        emptyCells.add(i);
      }
    }
    return emptyCells;
  }

  void checkWinner() {
    List<List<int>> winningCombos = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combo in winningCombos) {
      if (board[combo[0]][0] == 'X' &&
          board[combo[1]][0] == 'X' &&
          board[combo[2]][0] == 'X') {
        setState(() {
          resultText = 'Player $firstPlayerName (X) wins!';
          gameOver = true;
          if (gameMode != 'multiplayer') {
            wins++;
            saveStats();
          }
        });
        return;
      } else if (board[combo[0]][0] == 'O' &&
          board[combo[1]][0] == 'O' &&
          board[combo[2]][0] == 'O') {
        setState(() {
          resultText = gameMode == 'multiplayer'
              ? 'Player $secondPlayerName (O) wins!'
              : 'Computer (O) wins!';
          gameOver = true;
          if (gameMode != 'multiplayer') {
            losses++;
            saveStats();
          }
        });
        return;
      }
    }

    if (getEmptyCells().isEmpty) {
      setState(() {
        resultText = "It's a tie!";
        gameOver = true;
        if (gameMode != 'multiplayer') {
          draws++;
          saveStats();
        }
      });
    }
  }

  void easyPcMove() {
    List<int> emptyCells = getEmptyCells();
    if (emptyCells.isNotEmpty) {
      int randomIndex = Random().nextInt(emptyCells.length);
      int cell = emptyCells[randomIndex];
      displayMove('O', cell);
      checkWinner();
    }
  }

  int checkWin(String player) {
    List<List<int>> winningCombos = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var combo in winningCombos) {
      if (board[combo[0]][0] == player &&
          board[combo[1]][0] == player &&
          board[combo[2]][0] == 0) {
        return combo[2];
      } else if (board[combo[0]][0] == player &&
          board[combo[2]][0] == player &&
          board[combo[1]][0] == 0) {
        return combo[1];
      } else if (board[combo[1]][0] == player &&
          board[combo[2]][0] == player &&
          board[combo[0]][0] == 0) {
        return combo[0];
      }
    }
    return -1;
  }

  void hardPcMove() {
    int winMove = checkWin('O');
    if (winMove != -1) {
      displayMove('O', winMove);
      checkWinner();
      return;
    }

    int blockMove = checkWin('X');
    if (blockMove != -1) {
      displayMove('O', blockMove);
      checkWinner();
      return;
    }

    easyPcMove();
  }

  void mediumPcMove() {
    if (useRandomNext) {
      easyPcMove();
    } else {
      hardPcMove();
    }
    useRandomNext = !useRandomNext;
  }

  void fillCell(int index) {
    if (!gameStarted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please start the game and select a game mode to start playing.',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!gameOver && board[index][0] == 0) {
      displayMove(currentPlayer, index);
      hasFirstMove = true;
      checkWinner();
      if (!gameOver) {
        if (gameMode == 'multiplayer') {
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        } else {
          if (gameMode == 'Easy') {
            easyPcMove();
          } else if (gameMode == 'Hard') {
            hardPcMove();
          } else if (gameMode == 'Medium') {
            mediumPcMove(); // NEW
          }
        }
      }
    }
  }

  void startGame(String mode, String firstPlayer) {
    setState(() {
      resetBoard();
      gameStarted = true;
      gameMode = mode;
      if (firstPlayer == 'computer') {
        if (mode == 'Easy') {
          easyPcMove();
        } else {
          hardPcMove();
        }
      }
    });
  }

  void startMultiplayerGame(
    String firstPlayer,
    String secondPlayer,
    String firstPlayerTurn,
  ) {
    setState(() {
      resetBoard();
      gameStarted = true;
      gameMode = 'multiplayer';
      firstPlayerName = firstPlayer;
      secondPlayerName = secondPlayer;
      currentPlayer = firstPlayerTurn == firstPlayer ? 'X' : 'O';
    });
  }

  void chooseGameMode() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose a game mode'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        chooseDifficultyMode();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          217,
                          228,
                          240,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        'Single Player',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        enterPlayerNames();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          217,
                          228,
                          240,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        'Multiplayer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void chooseDifficultyMode() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Difficulty'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose Easy, Medium or Hard mode'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        chooseFirstPlayer('Easy');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          217,
                          228,
                          240,
                        ),
                      ),
                      child: Text('Easy'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        chooseFirstPlayer('Medium');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          217,
                          228,
                          240,
                        ),
                      ),
                      child: Text('Medium'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        chooseFirstPlayer('Hard');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          217,
                          228,
                          240,
                        ),
                      ),
                      child: Text('Hard'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void chooseFirstPlayer(String mode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Who Goes First?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        startGame(mode, 'player');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          217,
                          228,
                          240,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        'Player First',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        startGame(mode, 'computer');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          217,
                          228,
                          240,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        'Computer First',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void enterPlayerNames() {
    String firstPlayerName = '';
    String secondPlayerName = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Player Names'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  firstPlayerName = value;
                },
                decoration: InputDecoration(hintText: 'First Player Name'),
              ),
              TextField(
                onChanged: (value) {
                  secondPlayerName = value;
                },
                decoration: InputDecoration(hintText: 'Second Player Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (firstPlayerName.isNotEmpty && secondPlayerName.isNotEmpty) {
                  chooseFirstPlayerMultiplayer(
                    firstPlayerName,
                    secondPlayerName,
                  );
                }
              },
              child: Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void chooseFirstPlayerMultiplayer(
    String firstPlayerName,
    String secondPlayerName,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Who Goes First?'),
          content: Text('$firstPlayerName or $secondPlayerName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                startMultiplayerGame(
                  firstPlayerName,
                  secondPlayerName,
                  firstPlayerName,
                );
              },
              child: Text('$firstPlayerName First'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                startMultiplayerGame(
                  firstPlayerName,
                  secondPlayerName,
                  secondPlayerName,
                );
              },
              child: Text('$secondPlayerName First'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: const Color.fromARGB(255, 59, 83, 128),
        centerTitle: true,
        title: Text(
          'Tic Tac Toe',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 35,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Background.jpg',

            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(), // Adjust blur here
            child: Container(
              color: Colors.black.withOpacity(0.2), // Transparent overlay
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (gameStarted && !gameOver)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 1,
                        ), // Add margin
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ), // Add padding
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 54, 71, 104),
                          border: Border.all(
                            color: Colors.white, // Border color
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Optional rounded corners
                        ),
                        child: Text(
                          gameMode == 'multiplayer'
                              ? '$firstPlayerName (X)  VS  $secondPlayerName (O)'
                              : 'Single Player - $gameMode Mode',
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (gameStarted && !gameOver && gameMode != 'multiplayer')
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          40,
                          60,
                          90,
                        ), // background color
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.white, width: 2.0),
                      ),
                      child: Text(
                        'Wins: $wins   |   Losses: $losses   |   Draws: $draws',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  Container(
                    margin: EdgeInsets.all(40.0), // Reduced from 50
                    padding: EdgeInsets.all(6.0), // Reduced from 10
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color.fromARGB(255, 59, 83, 128),
                        width: 4.0,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => fillCell(index),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              margin: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  board[index][0] == 0
                                      ? ''
                                      : board[index][0].toString(),
                                  style: TextStyle(
                                    fontSize: 36, // Reduced from 48
                                    fontWeight: FontWeight.bold,
                                    color: board[index][0] == 'X'
                                        ? Colors.teal
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (gameOver)
                    Text(
                      resultText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellowAccent,
                      ),
                    ),
                  Visibility(
                    visible: hasFirstMove && !gameOver,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 30,
                      ),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 185, 201, 231),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color.fromARGB(255, 59, 83, 128),
                          width: 2,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () => undoLastMove(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            59,
                            83,
                            128,
                          ),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          'Undo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Visibility(
                    visible: gameOver && hasFirstMove,
                    child: ElevatedButton(
                      onPressed: () => resetBoard(),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Play Again'),
                    ),
                  ),
                  Visibility(
                    visible: !gameStarted,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 30,
                      ),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 185, 201, 231),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color.fromARGB(255, 59, 83, 128),
                          width: 2,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () => chooseGameMode(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            59,
                            83,
                            128,
                          ),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          'Start Game',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
