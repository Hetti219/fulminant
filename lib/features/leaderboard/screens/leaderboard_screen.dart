import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
        automaticallyImplyLeading: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('points', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];

          if (users.isEmpty) {
            return const Center(child: Text("No users yet."));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unnamed';
              final points = data['points'] ?? 0;
              final userId = users[index].id;

              final isCurrentUser = userId == currentUser?.uid;

              return Container(
                color: isCurrentUser ? Color(0xFF818CF8) : null,
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(
                    isCurrentUser ? "$name (You)" : name,
                    style: TextStyle(
                      fontWeight:
                          isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: Text("$points pts"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
