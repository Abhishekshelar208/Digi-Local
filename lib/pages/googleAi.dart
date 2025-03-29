import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:digilocal/pages/profile.dart';

import 'home_pageforStudent.dart';

const apiKey = "AIzaSyCQktw7dH6hdRn0PMF1xd2vg238yh9KgPU";

class MCQGeneratorScreen extends StatefulWidget {
  final List<String> skillsList;
  final Function onTestComplete;

  const MCQGeneratorScreen({required this.skillsList, required this.onTestComplete});

  @override
  _MCQGeneratorScreenState createState() => _MCQGeneratorScreenState();
}

class _MCQGeneratorScreenState extends State<MCQGeneratorScreen> {
  bool isLoading = false;
  bool isTestStarted = false;
  List<Map<String, dynamic>> questions = [];
  Map<int, String> userAnswers = {};
  int timeLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Future.microtask(showTestRules);
  }

  void showTestRules() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("MCQ Test Rules",style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("1. You will have 90 seconds to complete the test.",style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black54),),
            Text("2. Passing is for 4 marks.",style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black54),),
            Text("3. Once the timer ends, the test will automatically submit.",style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black54),),
            Text("4. Click 'I am ready' to start the test.",style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black54),),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startTest();
            },
            child: Text("I am ready",style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
          ),
        ],
      ),
    );
  }

  void startTest() {
    setState(() {
      isTestStarted = true;
    });
    generateMCQs();
  }

  Future<void> generateMCQs() async {
    setState(() {
      isLoading = true;
      questions.clear();
      userAnswers.clear();
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
      );

      final prompt = """
    Generate 10 multiple-choice questions (MCQs) based on the following skills: ${widget.skillsList.join(", ")}. 
    Format each question as follows:
    Question: <question text>
    a) <option1>
    b) <option2>
    c) <option3>
    d) <option4>
    Answer: <correct option letter>
    Ensure exactly 10 questions with four options each.
    """;

      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        final lines = response.text!.split("\n").map((line) => line.trim()).toList();
        final parsedQuestions = <Map<String, dynamic>>[];

        for (int i = 0; i < lines.length; i++) {
          if (lines[i].startsWith("Question:")) {
            String questionText = lines[i].replaceFirst("Question:", "").trim();
            List<String> options = [];
            String correctAnswer = "";

            int optionCount = 0;
            for (int j = i + 1; j < lines.length; j++) {
              if (lines[j].startsWith(RegExp(r'[a-d]\)'))) {
                options.add(lines[j]);
                optionCount++;
              }
              if (optionCount == 4 && j + 1 < lines.length && lines[j + 1].startsWith("Answer:")) {
                correctAnswer = lines[j + 1].replaceFirst("Answer:", "").trim();
                break;
              }
            }

            if (options.length == 4 && correctAnswer.isNotEmpty) {
              parsedQuestions.add({
                "question": questionText,
                "options": options,
                "correctAnswer": correctAnswer,
              });
            }
          }
        }

        setState(() {
          questions = parsedQuestions.take(10).toList();
        });

        if (questions.isNotEmpty) {
          startTimer();
        }
      }
    } catch (e) {
      setState(() {
        questions = [];
      });
      print("Error generating MCQs: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        checkAnswers(); // Auto-submit test when timer ends
      }
    });
  }

  void checkAnswers() {
    _timer?.cancel(); // Stop the timer

    int correctCount = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] != null && userAnswers[i]!.startsWith(questions[i]["correctAnswer"])) {
        correctCount++;
      }
    }

    // Navigate to the result screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: correctCount,
          onTestComplete: correctCount >= 4 ? widget.onTestComplete : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop timer when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF), //off white,
      appBar: AppBar(
        title: Text(
          "MCQ Test",
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isTestStarted && questions.isNotEmpty)
              Text("Time Left: $timeLeft seconds", style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator(color: Colors.black,)
                : questions.isEmpty
                ? ElevatedButton(
                onPressed: generateMCQs,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Background color changed to red
                foregroundColor: Colors.white, // Text color white for contrast
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10), // Increased size
                minimumSize: Size(200, 0), // Explicitly setting width and height
              ),
              child: Text(
                "Re-Generate",
                style: GoogleFonts.blinker(
                  color: Colors.white, // Set color to white to ensure the gradient is visible
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text("Q${index + 1}: ${question["question"]}", style: GoogleFonts.blinker(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),),
                        ),
                        Column(
                          children: (question["options"] as List<String>).map((option) {
                            return RadioListTile<String>(
                              activeColor: Colors.black,
                              title: Text(option,style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),),
                              value: option[0],
                              groupValue: userAnswers[index],
                              onChanged: (value) {
                                setState(() {
                                  userAnswers[index] = value!;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (questions.isNotEmpty)
              ElevatedButton(onPressed: checkAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent, // Background color changed to red
                  foregroundColor: Colors.white, // Text color white for contrast
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10), // Increased size
                  minimumSize: Size(200, 0), // Explicitly setting width and height
                ),
                child: Text(
                  "Submit Test",
                  style: GoogleFonts.blinker(
                    color: Colors.white, // Set color to white to ensure the gradient is visible
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}



class ResultScreen extends StatelessWidget {
  final int score;
  final Function? onTestComplete;

  const ResultScreen({required this.score, this.onTestComplete});

  @override
  Widget build(BuildContext context) {
    // Use a post-frame callback to execute onTestComplete after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (onTestComplete != null) {
        onTestComplete!();
      }
    });

    return Scaffold(
      backgroundColor: Color(0xffF2F0EF), //off white,
      appBar: AppBar(
        title: Text(
          "Test Result",
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Your Score: $score/10", style: GoogleFonts.blinker(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.black),),
            const SizedBox(height: 20),
            if (score >= 4)
              Text("Congratulations! You passed the test.\nGo Back to Profile Page Wait for 1 minute\nto Create Your Account", style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.green.shade400),)
            else
              Text("You did not pass the test. Try again!", style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.red.shade400),),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreenForStdudent()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent, // Background color changed to red
                foregroundColor: Colors.white, // Text color white for contrast
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10), // Increased size
                minimumSize: Size(200, 0), // Explicitly setting width and height
              ),
              child: Text(
                "Back to Profile",
                style: GoogleFonts.blinker(
                  color: Colors.white, // Set color to white to ensure the gradient is visible
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}