import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/course_bloc.dart';
import '../../data/models/course_model.dart';
import 'module_list_screen.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourseBloc()..add(LoadCourses()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Available Courses"),
        ),
        body: BlocBuilder<CourseBloc, CourseState>(
          builder: (context, state) {
            if (state is CourseLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CourseLoaded) {
              final courses = state.courses;

              if (courses.isEmpty) {
                return const Center(child: Text("No courses found."));
              }

              return ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return ListTile(
                    title: Text(course.title),
                    subtitle: Text(course.description),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ModuleListScreen(
                              courseId: course.id, courseTitle: course.title),
                        ),
                      );
                    },
                  );
                },
              );
            } else if (state is CourseError) {
              return Center(child: Text(state.message));
            }

            return const Center(child: Text("Something went wrong."));
          },
        ),
      ),
    );
  }
}
