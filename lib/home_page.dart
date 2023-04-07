import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:speed_arithmetic_game/const.dart';

import 'package:speed_arithmetic_game/util/level.dart';
import 'package:speed_arithmetic_game/util/my_button.dart';
import 'package:speed_arithmetic_game/util/result_message.dart';

import 'homescreen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const HomePage(resume: null,));
// }

class HomePage extends StatefulWidget {
  final bool resume;
  const HomePage({Key? key, required this.resume}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /*
   G A M E   R U L E S 
   1. Player need to get 5 i correct in a row to get to next level
   L E V E L S
   level 1 -> double digit addition--- 45 seconds(5 questions)
   level 2 -> single digit subtraction , 2 digit number - 1 digit number--45 seconds(5 questions)
   level 3 -> Multiplication of 2 digits and 1 digit number- 60 seconds(5 questions)
   level 4 -> Division of 3 digit number by a single digit- 60 seconds (5 questions)
   level 5 -> 3 digit and 1 digit multiplication   ---60 seconds (5 questions)
   Delete (Backspace) and Clear all and colors swap
   Submit and = 
   2 alert box for leveling up and restarting
   firebase storage of player's current score
    add feature to dialog box to not shut on tapping on screen

   
   */

  // player score
  int playerScore = 0;
  // correcct attempts
  int correctAttempts = 0;

  // current level
  int currenLevel = 0;
  Level currentLevels = Level.level1;

  // timer
  int timeRemaining = 0;

  bool Stop = false;

  // Future<void> loadGameState() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     playerScore = prefs.getInt('playerScore') ?? 0;
  //     levelNo = prefs.getInt('levelNo') ?? 1;
  //     correctAttempts = prefs.getInt('correctAttempts') ?? 0;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    if (widget.resume) {
      resumeGame();
    } else {
      initGame();
    }
  }

  initGame() {
    playerScore = 0;
    userAnswer = '';
    correctAttempts = 0;
    currentLevels = Level.level1;
    timeRemaining = durationForlevel();
    generateLevelNumbers();
    initializeTimer();
  }

  initializeTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      onTimerTick();
      // displays the updated state of the remaining time
    });
  }

  void stopGame() async {
    // Save game state to shared preferences
    setCurrentLevel(currentLevels);

    // Navigate to home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void setCurrentLevel(Level level) {
    currentLevels = level;
    savedGame();
  }

  void savedGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentLevels', currentLevels.index);
    await prefs.setInt('score', playerScore);
    await prefs.setInt('correctAttempts', correctAttempts);
  }

  void resumeGame() async {
    // Load game state from shared preferences
    final prefs = await SharedPreferences.getInstance();
    int index = prefs.getInt('currentLevels') ?? 0;
    currentLevels = Level.values[index];
    playerScore = prefs.getInt('score') ?? 0;
    correctAttempts = prefs.getInt('correctAttempts') ?? 0;

    // Start timer
    initializeTimer();
    timeRemaining = durationForlevel();
    generateLevelNumbers();
  }

  onTimerTick() {
    timeRemaining -= 1;
    if (timeRemaining <= 0) {
      timer?.cancel();
      if (timeRemaining == 0 && correctAttempts < 5) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.cyan[200],
              title: Text("Game Over"),
              content: Text("Do you want to restart the game or quit?"),
              actions: <Widget>[
                ElevatedButton(
                  child: Text("Restart"),
                  onPressed: () {
                    // restart the game code
                    Navigator.pop(context);
                    initGame();
                  },
                ),
                ElevatedButton(
                  child: Text("Quit"),
                  onPressed: () {
                    // quit the game code
                    setState(() {
                      SystemNavigator.pop();
                    });
                  },
                ),
              ],
            );
          },
        );
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    //
    timer?.cancel();
    super.dispose();
  }

  //-----------Generate Levels--------------

  int num1 = 0;
  int num2 = 0;
  int num3 = 0;

  generateLevelNumbers() {
    switch (currentLevels) {
      case Level.level1:
        num1 = randomNumber.nextInt(9);
        num2 = randomNumber.nextInt(9);
        break;
      // for level 2 - subtraction
      case Level.level2:
        num1 = randomNumber.nextInt(100);
        num2 = randomNumber.nextInt(100);
        // do {
        while (num2 > num1) {
          num2 = randomNumber.nextInt(100);
        } // ensure result is a single digit number
        break;
      // level 3 - 2 digit multiplication with a single digit
      case Level.level3:
        num1 = randomNumber.nextInt(99);
        num2 = randomNumber.nextInt(9);
        break;
      // level 4 - 3 digit division by a  1 digit number
      case Level.level4:
        num1 = randomNumber.nextInt(999);
        num2 = randomNumber.nextInt(9);
        break;
      // level 5 - mix addition and subtraction of 2 digit number (3 operands)
      case Level.level5:
        num1 = randomNumber.nextInt(999);
        num2 = randomNumber.nextInt(9);
        //num3 = randomNumber.nextInt(9);
        break;
      default:
    }
  }

  // how many question you need to get correct in a row to get to the next level
  int numberOfCorrectanswersrequired = 5;
  int? levelNo;
  // -------timer duration------
  Timer? timer;

  int durationForlevel() {
    switch (currentLevels) {
      case Level.level1:
        levelNo = 1;
        oper1 = " + ";
        return 45;
      case Level.level2:
        levelNo = 2;
        oper1 = " - ";
        return 45;
      case Level.level3:
        levelNo = 3;
        oper1 = " X ";
        return 60;
      case Level.level4:
        levelNo = 4;
        oper1 = " / ";
        return 60;
      case Level.level5:
        levelNo = 5;
        oper1 = " X ";
        return 60;
      default:
        return 1;
    }
  }

  // ------number pad list-------
  List<String> numberPad = [
    '7',
    '8',
    '9',
    'BACKSPACE',
    '4',
    '5',
    '6',
    'CLEAR ALL',
    '1',
    '2',
    '3',
    'SUBMIT',
    '00',
    '0'
  ];

  //user answer
  String userAnswer = '';

  // -----user tapped a button------
  void buttonTapped(String button) {
    setState(() {
      if (button == 'SUBMIT') {
        // check the result
        checkResult();
      } else if (button == 'CLEAR ALL') {
        // clear the input
        userAnswer = '';
      } else if (button == "BACKSPACE") {
        // deleting the last number
        if (userAnswer.isNotEmpty) {
          userAnswer = userAnswer.substring(0, userAnswer.length - 1);
        }
      } else if (userAnswer.length < 10) {
        //maximum of 10 digits can be inputted
        userAnswer += button;
      } else if (button == "00") {
        userAnswer += '00';
      }
    });
  }

//-----Dialog boxes--------
  showSuccessDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return ResultMessage(
              message: 'Correct!',
              onTap: goTONextQuestion,
              icon: Icons.arrow_forward);
        });
  }

  showIncorrectDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return ResultMessage(
            message: 'Incorrect ! Try Again',
            onTap: goBackToQuestion,
            icon: Icons.rotate_left,
          );
        });
  }

  showNextLevelDialog() {
    timer?.cancel();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.cyan[200],
          title: Text("Hurray! You cleared the level"),
          content: Text("Continue  or quit?"),
          actions: <Widget>[
            ElevatedButton(
              child: Text("Continue"),
              onPressed: () {
                // restart the game code
                Navigator.pop(context);
                initializeTimer();
                // Continue to the next level after the pop up  message
              },
            ),
            ElevatedButton(
              child: Text("Quit"),
              onPressed: () {
                savedGame();
                // quit the game code
                setState(() {
                  SystemNavigator.pop();
                }); // need to save the state of the game which will help to come back and continue the game
              },
            ),
          ],
        );
      },
    );
  }

  showRestartGameDialog() {
    timer?.cancel();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.cyan[200],
          title: Text("Hurray! You've scored a full 25/25"),
          content: Text("Restart Again  or quit?"),
          actions: <Widget>[
            ElevatedButton(
              child: Text("Restart"),
              onPressed: () {
                // restart the game code
                Navigator.pop(context);
                initializeTimer();
                // Continue to the next level after the pop up  message
              },
            ),
            ElevatedButton(
              child: Text("Quit"),
              onPressed: () {
                // quit the game code
                setState(() {
                  SystemNavigator.pop();
                }); // need to save the state of the game which will help to come back and continue the game
              },
            ),
          ],
        );
      },
    );
  }

  String oper1 = '+';

  // check if user answer is correct or not
  Future<void> checkResult() async {
    switch (currentLevels) {
      case Level.level1:
        if (num1 + num2 == int.parse(userAnswer)) {
          correctAttempts += 1;
          playerScore += 1;
          if (correctAttempts == 5) {
            showNextLevelDialog();
            userAnswer = '';
            currentLevels = Level.level2;
            generateLevelNumbers();
            correctAttempts = 0;
            timeRemaining = durationForlevel();
          } else {
            showSuccessDialog();
          }
        } else {
          showIncorrectDialog();
        }
        break;
      case Level.level2:
        if ((num1 - num2).abs() == int.parse(userAnswer)) {
          correctAttempts += 1;
          playerScore += 1;
          if (correctAttempts == 5) {
            showNextLevelDialog();
            userAnswer = '';
            currentLevels = Level.level3;
            generateLevelNumbers();
            correctAttempts = 0;
            timeRemaining = durationForlevel();
          }
          if (correctAttempts < 5) {
            showSuccessDialog();
          }
        } else {
          showIncorrectDialog();
        }
        break;
      case Level.level3:
        if (num1 * num2 == int.parse(userAnswer)) {
          correctAttempts += 1;
          playerScore += 1;
          if (correctAttempts == 5) {
            showNextLevelDialog();
            userAnswer = '';
            currentLevels = Level.level4;
            generateLevelNumbers();
            correctAttempts = 0;
            timeRemaining = durationForlevel();
          }
          if (correctAttempts < 5) {
            showSuccessDialog();
          }
        } else {
          showIncorrectDialog();
        }
        break;
      case Level.level4:
        if (num1 ~/ num2 == int.parse(userAnswer)) {
          correctAttempts += 1;
          playerScore += 1;
          if (correctAttempts == 5) {
            showNextLevelDialog();
            userAnswer = '';
            currentLevels = Level.level5;
            generateLevelNumbers();
            correctAttempts = 0;
            timeRemaining = durationForlevel();
          }

          if (correctAttempts < 5) {
            showSuccessDialog();
          }
        } else {
          showIncorrectDialog();
        }
        break;
      case Level.level5:
        // operator2 = 'X';
        if (num1 * num2 == int.parse(userAnswer)) {
          correctAttempts += 1;
          playerScore += 1;
          if (correctAttempts == 5) {
            // restart the whole game or quit game
            showRestartGameDialog();
            userAnswer = '';
            currentLevels = Level.level1;
            generateLevelNumbers();
            correctAttempts = 0;
            timeRemaining = durationForlevel();
          }

          if (correctAttempts < 5) {
            showSuccessDialog();
          }
        } else {
          showIncorrectDialog();
        }
        break;

      default:
    }
  }

  // create random numbers
  var randomNumber = Random();

  void goTONextQuestion() {
    // dismiss alert dialog
    Navigator.of(context).pop();
    generateLevelNumbers();

    //reset question values
    setState(() {
      userAnswer = '';
    });

    //create a new question
  }

  // Go back to question
  void goBackToQuestion() {
    // dismiss the alert dialog
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[400],
      body: Column(
        children: [
          //level progress , player need to level up after 5 correct answers

          Container(
            height: 100, // cyan color ranges
            color: Color.fromARGB(255, 16, 67, 74),
            child: Row(children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    "$timeRemaining",
                    style: whiteTextStyle,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: timeRemaining / durationForlevel(),
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Level $levelNo :",
                  style: newTextStyle,
                ),
              ),
              Text(
                "$correctAttempts / 5",
                style: TextStyle(color: Colors.greenAccent, fontSize: 25),
              ),
              SizedBox(
                width: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Score :",
                  style: newTextStyle,
                ),
              ),
              Text(
                "$playerScore / 25",
                style: TextStyle(color: Colors.greenAccent, fontSize: 25),
              ),
            ]),
          ),
          //question
          Expanded(
            child: Container(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      num1.toString() + '$oper1' + num2.toString() + " = ",
                      style: newTextStyle,
                    ),
                    // answer box
                    Container(
                      height: 50,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 39, 141, 155),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          userAnswer,
                          style: newTextStyle,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 100,
                    ),
                    IconButton(
                      onPressed: stopGame,
                      icon: Icon(Icons.stop_circle),
                      iconSize: 50,
                    )
                  ],
                ),
              ),

              //color: Color.fromARGB(255, 71, 207, 214),
            ),
          ),
          // number pad
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: GridView.builder(
                itemCount: numberPad.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  return MyButton(
                    child: numberPad[index],
                    onTap: () => buttonTapped(numberPad[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
