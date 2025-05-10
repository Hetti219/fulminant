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

  void _checkAnswer(int selectedIndex, int correctIndex) {
    if (_isAnswered) return;
    setState(() {
      _isAnswered = true;
    });

    if (selectedIndex == correctIndex) {
      _score += 10;
    }

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
      });
    });
  }

  Future<void> _finishAndAwardPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // 1. Update points
      await userDoc.update({
        'points': FieldValue.increment(_score),
      });

      // 2. Add to completed modules subcollection
      final completedModulesRef =
          userDoc.collection('completedModules').doc(widget.moduleId);

      await completedModulesRef.set({
        'courseId': widget.courseId,
        'moduleId': widget.moduleId,
        'title': widget.moduleTitle,
        'pointsEarned': _score,
        'completedAt': DateTime.now().toUtc().toIso8601String(),
      });
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Well done!"),
          content: Text("You earned $_score points."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
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
                onPressed: _finishAndAwardPoints,
                child: Text("Finish Module & Earn $_score Points"),
              ),
            );
          }

          final q = questions[_currentQuestionIndex];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Content: $content", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                Text("Q${_currentQuestionIndex + 1}: ${q['question']}",
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                ...(q['options'] as List<dynamic>).asMap().entries.map((entry) {
                  final idx = entry.key;
                  final option = entry.value;

                  return ListTile(
                    title: Text(option),
                    leading: Radio<int>(
                      value: idx,
                      groupValue: _isAnswered ? q['answer'] : null,
                      onChanged: (_) => _checkAnswer(idx, q['answer']),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
