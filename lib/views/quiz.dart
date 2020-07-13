import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quiz_app/models/quiz_model.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/views/result_screen.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String apiURL =
      "https://opentdb.com/api.php?amount=10&category=18&type=multiple";

  QuizModel quizModel;

  int currentQuestion = 0;

  int totalSeconds = 30;
  int elapsedSeconds = 0;

  Timer timer;

  int score = 0;

  @override
  void initState() {
    fetchQuiz();
    super.initState();
  }

  fetchQuiz() async {
    var response = await http.get(apiURL);
    var body = response.body;

    var json = jsonDecode(body);

    // print(body);

    setState(() {
      quizModel = QuizModel.fromJson(json);
      quizModel.results[currentQuestion].incorrectAnswers
          .add(quizModel.results[currentQuestion].correctAnswer);

      quizModel.results[currentQuestion].incorrectAnswers.shuffle();
      initTimer();
    });
  }

  initTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (t.tick == totalSeconds) {
        print("Time Completed");
        t.cancel();
        changeQuestion();
      } else {
        setState(() {
          elapsedSeconds = t.tick;
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  checkAnswer(answer) {
    String correctAnswer = quizModel.results[currentQuestion].correctAnswer;
    if (correctAnswer == answer) {
      score += 1;
    } else {
      print("Wrong");
    }
    changeQuestion();
  }

  changeQuestion() {
    timer.cancel();

    // check if it is last question
    if (currentQuestion == quizModel.results.length - 1) {
      print("Quiz Completed");
      print("Score: $score");

      //navigate to result screeen
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => ResultScreen(score: score)));
    } else {
      setState(() {
        currentQuestion += 1;
      });
      quizModel.results[currentQuestion].incorrectAnswers
          .add(quizModel.results[currentQuestion].correctAnswer);

      quizModel.results[currentQuestion].incorrectAnswers.shuffle();
      initTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (quizModel != null) {
      return Scaffold(
        backgroundColor: Color(0xFF2D046E),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Image(
                        image: AssetImage("assets/icon-circle.png"),
                        width: 70,
                        height: 70,
                      ),
                      Text(
                        "$elapsedSeconds s",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      )
                    ],
                  ),
                ),

                //question
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Q. ${quizModel.results[currentQuestion].question}",
                    style: TextStyle(fontSize: 35, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),

                //options
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: Column(
                      children: quizModel
                          .results[currentQuestion].incorrectAnswers
                          .map((option) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: RaisedButton(
                          color: Color(0xFF511AA8),
                          colorBrightness: Brightness.dark,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            option,
                            style: TextStyle(fontSize: 18),
                          ),
                          onPressed: () {
                            print(score);
                            checkAnswer(option);
                          }),
                    );
                  }).toList()),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Color(0xFF2D046E),
        body: Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
  }
}
