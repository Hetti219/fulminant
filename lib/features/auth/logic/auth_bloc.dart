import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_repo.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepo;

  AuthBloc(this._authRepo) : super(AuthInitial()) {
    on<AuthSignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepo.signUp(email: event.email, password: event.password);
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepo.logIn(email: event.email, password: event.password);
        emit(AuthSuccess());

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userDoc =
              FirebaseFirestore.instance.collection('users').doc(user.uid);

          // This will create the document if it doesn’t exist and keep existing data (merge)
          await userDoc.set({
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'points': FieldValue.increment(0),
            // This ensures 'points' field exists
          }, SetOptions(merge: true));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepo.logOut();
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
