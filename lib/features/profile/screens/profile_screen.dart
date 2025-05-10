import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in.")),
      );
    }

    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      appBar: AppBar(title: const Text("Your Profile")),
      body: FutureBuilder<DocumentSnapshot>(
        future: userDocRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No profile data found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'Unnamed';
          final email = data['email'] ?? 'No email';
          final points = data['points'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Account Info",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("👤 Name: $name"),
                Text("📧 Email: $email"),
                const SizedBox(height: 20),
                const Text("Progress",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("⭐ Points: $points"),
                const SizedBox(height: 30),
                // Placeholder for future: completed modules list
                const Text("📚 Completed Modules",
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        userDocRef.collection('completedModules').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final modules = snapshot.data?.docs ?? [];

                      if (modules.isEmpty) {
                        return const Text("No modules completed yet.");
                      }

                      return ListView.builder(
                        itemCount: modules.length,
                        itemBuilder: (context, index) {
                          final data =
                              modules[index].data() as Map<String, dynamic>;
                          final title = data['title'] ?? 'Module';
                          final points = data['pointsEarned'] ?? 0;
                          final date = data['completedAt'] != null
                              ? DateTime.parse(data['completedAt']).toLocal()
                              : null;

                          return ListTile(
                            leading: const Icon(Icons.check_circle_outline),
                            title: Text(title),
                            subtitle: Text(
                              date != null
                                  ? 'Completed on ${date.toLocal().toString().split(' ')[0]}'
                                  : '',
                            ),
                            trailing: Text("+$points pts"),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
