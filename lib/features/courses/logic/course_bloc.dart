import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../data/models/course_model.dart';

part 'course_event.dart';

part 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CourseBloc() : super(CourseInitial()) {
    on<LoadCourses>(_onLoadCourses);
  }

  Future<void> _onLoadCourses(
      LoadCourses event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final querySnapshot = await _firestore.collection('courses').get();
      final courses = querySnapshot.docs
          .map((doc) => Course.fromMap(doc.data(), doc.id))
          .toList();
      emit(CourseLoaded(courses));
    } catch (e) {
      emit(CourseError('Failed to load courses: ${e.toString()}'));
    }
  }
}
