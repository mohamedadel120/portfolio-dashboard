import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthCubit({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super((firebaseAuth ?? FirebaseAuth.instance).currentUser != null
            ? Authenticated((firebaseAuth ?? FirebaseAuth.instance).currentUser!)
            : AuthInitial()) {
    _init();
  }

  void _init() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // The authStateChanges listener will handle the success emission
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Authentication failed'));
      emit(Unauthenticated()); // Reset back to unauthenticated so user can try again
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
