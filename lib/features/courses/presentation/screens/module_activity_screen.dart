import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModuleActivityScreen extends StatefulWidget {
  final String courseId;
  final String moduleId;
  final String moduleTitle;

  const ModuleActivityScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<ModuleActivityScreen> createState() => _ModuleActivityScreenState();
}

class _ModuleActivityScreenState extends State<ModuleActivityScreen> {
  late Future<DocumentSnapshot> _moduleFuture;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  bool _isFinished = false; // Prevent double completion
  bool _isProcessing = false; // Prevent multiple submissions
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _moduleFuture = FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('modules')
        .doc(widget.moduleId)
        .get();
  }

  void _submitAnswer(int correctIndex) {
    if (_selectedIndex == null || _isAnswered || _isProcessing) return;

    setState(() {
      _isAnswered = true;
      if (_selectedIndex == correctIndex) {
        _score += 10;
      }
    });
  }

  void _goToNextQuestion(int totalQuestions) {
    if (_currentQuestionIndex + 1 >= totalQuestions) {
      _finishAndAwardPoints();
    } else {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedIndex = null;
      });
    }
  }

  Future<void> _finishAndAwardPoints() async {
    // Prevent double execution
    if (_isFinished || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Update points
        await userDoc.update({'points': FieldValue.increment(_score)});

        // Mark module as completed
        await userDoc.collection('completedModules').doc(widget.moduleId).set({
          'courseId': widget.courseId,
          'moduleId': widget.moduleId,
          'title': widget.moduleTitle,
          'pointsEarned': _score,
          'completedAt': DateTime.now().toUtc().toIso8601String(),
        });

        setState(() {
          _isFinished = true;
        });

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false, // Force them to click OK
            builder: (_) => AlertDialog(
              title: const Text("Well done!"),
              content: Text("You earned $_score points."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to course list
                  },
                  child: const Text("OK"),
                )
              ],
            ),
          );
        }
      }
    } catch (e) {
      // Handle errors gracefully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving progress: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleTitle),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _moduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Module not found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final content = data['content'] ?? 'No content';
          final questions =
              List<Map<String, dynamic>>.from(data['questions'] ?? []);

          if (_currentQuestionIndex >= questions.length) {
            return Center(
              child: ElevatedButton(
                onPressed:
                    _isFinished || _isProcessing ? null : _finishAndAwardPoints,
                child: _isProcessing
                    ? const CircularProgressIndicator()
                    : Text(_isFinished
                        ? "Module Completed!"
                        : "Finish Module & Earn $_score Points"),
              ),
            );
          }

          final q = questions[_currentQuestionIndex];
          final correctIndex = q['answer'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Content: $content",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  Text("Q${_currentQuestionIndex + 1}: ${q['question']}",
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  ...(q['options'] as List<dynamic>)
                      .asMap()
                      .entries
                      .map((entry) {
                    final idx = entry.key;
                    final option = entry.value;

                    return RadioListTile<int>(
                      title: Text(option),
                      value: idx,
                      groupValue: _selectedIndex,
                      onChanged: _isAnswered || _isProcessing
                          ? null
                          : (val) {
                              setState(() {
                                _selectedIndex = val;
                              });
                            },
                    );
                  }),
                  const SizedBox(height: 20),
                  if (!_isAnswered && !_isFinished)
                    ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _submitAnswer(correctIndex),
                      child: const Text("Submit Answer"),
                    ),
                  if (_isAnswered && !_isFinished)
                    ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _goToNextQuestion(questions.length),
                      child: Text(
                        _currentQuestionIndex + 1 == questions.length
                            ? "Finish Module"
                            : "Next Question",
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
