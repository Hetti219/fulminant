import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ModuleListScreen extends StatelessWidget {
  final String courseId;
  final String courseTitle;

  const ModuleListScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    final modulesRef = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('modules');

    return Scaffold(
      appBar: AppBar(
        title: Text('$courseTitle Modules'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: modulesRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No modules available."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'No Title';
              final content = data['content'] ?? 'No Content';

              return ListTile(
                title: Text(title),
                subtitle: Text(content),
                onTap: () {
                  // Later: Navigate to module activity/questions
                },
              );
            },
          );
        },
      ),
    );
  }
}
