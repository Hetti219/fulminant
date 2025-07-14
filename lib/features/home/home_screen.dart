import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/logic/auth_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName =
        user?.displayName ?? user?.email?.split('@')[0] ?? 'Student';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Welcome back, $userName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'logout') {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Main Content with StreamBuilder
            SliverToBoxAdapter(
              child: StreamBuilder<DocumentSnapshot>(
                stream: user != null
                    ? FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .snapshots()
                    : null,
                builder: (context, userSnapshot) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('courses')
                        .snapshots(),
                    builder: (context, coursesSnapshot) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stats Cards
                            _buildStatsSection(
                                context, userSnapshot, coursesSnapshot),

                            const SizedBox(height: 32),

                            // Quick Actions Section
                            Text(
                              'Quick Actions',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 16),

                            _buildQuickActionGrid(context),

                            const SizedBox(height: 32),

                            // Recent Activity
                            Text(
                              'Continue Learning',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 16),

                            _buildCoursesSection(context, coursesSnapshot),

                            const SizedBox(height: 32),

                            // Achievements Section
                            Text(
                              'Recent Achievements',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 16),

                            _buildAchievementBanner(context, userSnapshot),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(
      BuildContext context,
      AsyncSnapshot<DocumentSnapshot> userSnapshot,
      AsyncSnapshot<QuerySnapshot> coursesSnapshot) {
    final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
    final userPoints = userData?['points'] ?? 0;
    final totalCourses = coursesSnapshot.data?.docs.length ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Points',
                userPoints.toString(),
                Icons.stars,
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Courses',
                '$totalCourses Available',
                Icons.school,
                Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FutureBuilder<int>(
                future: _getCurrentUserRank(),
                builder: (context, snapshot) {
                  String rankText = '#--';
                  if (snapshot.hasData && snapshot.data! > 0) {
                    rankText = '#${snapshot.data}';
                  }

                  return _buildStatCard(
                    context,
                    'Rank',
                    rankText,
                    Icons.emoji_events,
                    Colors.amber,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoursesSection(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData) {
      return const CircularProgressIndicator();
    }

    final courses = snapshot.data!.docs;

    if (courses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No courses available yet.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return Column(
      children: courses.take(3).map((course) {
        final data = course.data() as Map<String, dynamic>;
        final title = data['title'] ?? 'Untitled Course';
        final description = data['description'] ?? 'No description';

        // You'll need to implement progress tracking
        final progress = 0.0; // Placeholder
        final color = _getCourseColor(courses.indexOf(course));

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCourseCard(
            context,
            title,
            description,
            progress,
            color,
            () => _navigateToCourse(context, course.id),
          ),
        );
      }).toList(),
    );
  }

  Color _getCourseColor(int index) {
    final colors = [Colors.blue, Colors.green, Colors.purple, Colors.orange];
    return colors[index % colors.length];
  }

  void _navigateToCourse(BuildContext context, String courseId) {
    Navigator.pushNamed(context, '/course', arguments: courseId);
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildQuickActionCard(
          context,
          'Browse Courses',
          Icons.library_books,
          Theme.of(context).colorScheme.primary,
          () => Navigator.pushNamed(context, '/course'),
        ),
        _buildQuickActionCard(
          context,
          'Leaderboard',
          Icons.leaderboard,
          Colors.orange,
          () => Navigator.pushNamed(context, '/leaderboard'),
        ),
        _buildQuickActionCard(
          context,
          'My Profile',
          Icons.person,
          Theme.of(context).colorScheme.secondary,
          () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title,
      IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.2)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, String title, String subtitle,
      double progress, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toInt()}% complete',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_circle_fill,
              color: color,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBanner(
      BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
    final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
    final points = userData?['points'] ?? 0;

    // Simple achievement logic - you can make this more sophisticated
    String achievementTitle = 'Getting Started!';
    String achievementDesc = 'Welcome to your learning journey!';

    if (points >= 100) {
      achievementTitle = 'Century Club!';
      achievementDesc = 'You\'ve earned over 100 points!';
    } else if (points >= 50) {
      achievementTitle = 'Half Century!';
      achievementDesc = 'You\'ve earned 50+ points!';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withAlpha(8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievementTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievementDesc,
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }

  Future<int> _getCurrentUserRank() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return 0;

    try {
      // Get current user's points first
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) return 0;

      final currentUserPoints = userDoc.data()?['points'] ?? 0;

      // Count users with higher points
      final higherPointsQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('points', isGreaterThan: currentUserPoints)
          .get();

      return higherPointsQuery.docs.length + 1; // +1 because rank starts at 1
    } catch (e) {
      print('Error getting user rank: $e');
      return 0;
    }
  }
}
