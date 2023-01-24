import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:speed_arithmetic_game/const.dart';
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
   level 0 -> single digit addition
   level 1 -> double digit addition
   level 2 -> single digit subtraction , larger number -> smaller number
   level 3 -> single digit subtraction , smaller number -> larger number
   level 4 -> double digit subtraction
   level 5 -> 20 times tables
   */

  // player score
  int playerScore = 0;

  // current level
  int currenLevel = 0;

  // how many you need to get correct in a row to get to the next level
  int numberOfCorrectanswersrequired = 5;

  // number pad list
  List<String> numberPad = [
    '7',
    '8',
    '9',
    'CLEAR ALL',
    '4',
    '5',
    '6',
    'DELETE',
    '1',
    '2',
    '3',
    '=',
    '0',
  ];
  // number A, number B
  int numberA = 1;
  int numberB = 2;

  //user answer
  String userAnswer = '';

  // user tapped a button
  void buttonTapped(String button) {
    setState(() {
      if (button == '=') {
        // check the result
        checkResult();
      }
      //
      else if (button == 'CLEAR ALL') {
        // clear the input
        userAnswer = '';
      } else if (button == "DELETE") {
        // deleting the last number
        if (userAnswer.isNotEmpty) {
          userAnswer = userAnswer.substring(0, userAnswer.length - 1);
        }
      } else if (userAnswer.length < 3) {
        //maximum of 3 numbers can be inputted
        userAnswer += button;
      }
    });
  }

  // check if user answer is correct or not
  void checkResult() {
    if (numberA + numberB == int.parse(userAnswer)) {
      showDialog(
          context: context,
          builder: (context) {
            return ResultMessage(
                message: 'Correct!',
                onTap: goTONextQuestion,
                icon: Icons.arrow_forward);
          });
    } else {
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
  }

  // create random numbers
  var randomNumber = Random();

  void goTONextQuestion() {
    // dismiss alert dialog
    Navigator.of(context).pop();

    //reset question values
    setState(() {
      userAnswer = '';
    });

    //create a new question
    numberA = randomNumber.nextInt(10);
    numberB = randomNumber.nextInt(10);
  }

  // Go back to question
  void goBackToQuestion() {
    // dismiss the laert dialog
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
            height: 120, // cyan color ranges
            color: Color.fromARGB(255, 16, 67, 74),
          ),
          //question
          Expanded(
            child: Container(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      numberA.toString() + " + " + numberB.toString() + ' = ',
                      style: whiteTextStyle,
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
                          style: whiteTextStyle,
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
                  childAspectRatio: 1.2,
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
