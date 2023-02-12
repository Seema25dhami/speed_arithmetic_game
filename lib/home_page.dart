import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:speed_arithmetic_game/const.dart';
import 'package:speed_arithmetic_game/util/level.dart';
import 'package:speed_arithmetic_game/util/my_button.dart';
import 'package:speed_arithmetic_game/util/result_message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
   question position
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
  @override
  void initState() {
    super.initState();
    timeRemaining = durationForlevel();
    generateLevelNumbers();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      timeRemaining -= 1;
      if (timeRemaining <= 0) {
        timer.cancel();
        if (timeRemaining == 0 && correctAttempts < 5) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Game Over"),
                content: Text("Do you want to restart the game or quit?"),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text("Restart"),
                    onPressed: () {
                      // restart the game code
                      Navigator.pop(context);
                      currentLevels = Level.level1;
                      checkResult();
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
      setState(() {}); // displays the updated state of the remaining time
    });
  }

  @override
  void dispose() {
    //
    timer?.cancel();
    super.dispose();
  }

  // //--------Restart Function----
  // void showRestartQuitDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Game Over"),
  //         content: Text("Do you want to restart the game or quit?"),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             child: Text("Restart"),
  //             onPressed: () {
  //               // restart the game code
  //               generateLevelNumbers();
  //             },
  //           ),
  //           ElevatedButton(
  //             child: Text("Quit"),
  //             onPressed: () {
  //               // quit the game code
  //               setState(() {
  //                 SystemNavigator.pop();
  //               });
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  //-------GAME OVER--------
  // Future<void> gameOver() async {
  //   await Future.delayed(Duration(seconds: 1));
  //   showRestartQuitDialog(context);
  // }

  //-----------Generate Levels--------------

  int num1 = 0;
  int num2 = 0;
  int num3 = 0;

  generateLevelNumbers() {
    switch (currentLevels) {
      case Level.level1:
        num1 = randomNumber.nextInt(990);
        num2 = randomNumber.nextInt(999);
        break;
      // for level 2 - subtraction
      case Level.level2:
        num1 = randomNumber.nextInt(999);
        num2 = randomNumber.nextInt(99);
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
        oper1 = "+";
        return 45;
      case Level.level2:
        levelNo = 2;
        oper1 = "-";
        return 45;
      case Level.level3:
        levelNo = 3;
        oper1 = "X";
        return 60;
      case Level.level4:
        levelNo = 4;
        oper1 = "/";
        return 60;
      case Level.level5:
        levelNo = 5;
        oper1 = "X";
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

  showSuccessDialog() {
    showDialog(
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
        context: context,
        builder: (context) {
          return ResultMessage(
            message: 'Incorrect ! Try Again',
            onTap: goBackToQuestion,
            icon: Icons.rotate_left,
          );
        });
  }

  String oper1 = '+';

  // check if user answer is correct or not
  Future<void> checkResult() async {
    switch (currentLevels) {
      case Level.level1:
        if (num1 + num2 == int.parse(userAnswer)) {
          correctAttempts += 1;
          if (correctAttempts == 5) {
            currentLevels = Level.level2;
            correctAttempts = 0;
            timeRemaining = durationForlevel();
          }

          showSuccessDialog();
        } else {
          showIncorrectDialog();
        }
        break;
      case Level.level2:
        if (num1 - num2 == int.parse(userAnswer)) {
          correctAttempts += 1;
          if (correctAttempts == 5) {
            currentLevels = Level.level3;
            correctAttempts = 0;
            timeRemaining = durationForlevel();
          }
          showSuccessDialog();
        } else {
          showIncorrectDialog();
        }
        break;
      case Level.level3:
        if (num1 * num2 == int.parse(userAnswer)) {
          correctAttempts += 1;
          if (correctAttempts == 5) {
            currentLevels = Level.level4;
            correctAttempts = 0;
            timeRemaining = durationForlevel();
          }
          showSuccessDialog();
        } else {
          showIncorrectDialog();
        }
        break;
      case Level.level4:
        if (num1 ~/ num2 == int.parse(userAnswer)) {
          correctAttempts += 1;
          if (correctAttempts == 5) {
            currentLevels = Level.level5;
            correctAttempts = 0;
            timeRemaining = durationForlevel();
          }

          showSuccessDialog();
        } else {
          showIncorrectDialog();
        }
        break;
      case Level.level5:
        // operator2 = 'X';
        if (num1 * num2 == int.parse(userAnswer)) {
          correctAttempts += 1;
          if (correctAttempts == 5) {
            // restart thw whole game or quit game
            currentLevels = Level.level1;
            correctAttempts = 0;
            timeRemaining = durationForlevel();
          }

          showSuccessDialog();
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
              )
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
