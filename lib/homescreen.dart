import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:speed_arithmetic_game/const.dart';
import 'package:speed_arithmetic_game/home_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 16, 47, 102),
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "Choose an option",
                      style: whiteTextStyle,
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Start a new game for first-time users
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(resume: false),
                                    settings: RouteSettings(
                                        arguments: {'resume : false'})));
                          },
                          child: Text("Start a new game"),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Resume the previous game for returning users
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(resume: true),
                                settings: RouteSettings(
                                  arguments: {'resume': true},
                                ),
                              ),
                            );
                          },
                          child: Text("Resume the game"),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Text("Tap to start the game"),
          ),
        ),
      ),
    );
  }
}
