import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  /// Null only in demo mode, where Firebase is never initialised.
  final FirebaseAuth? _firebaseAuth;

  AuthCubit({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super((firebaseAuth ?? FirebaseAuth.instance).currentUser != null
            ? Authenticated((firebaseAuth ?? FirebaseAuth.instance).currentUser!)
            : AuthInitial()) {
    _init();
  }

  /// Demo mode: no Firebase, nobody signed in, and sign-in is refused so no
  /// real credentials are ever sent from a demo build.
  AuthCubit.demo()
      : _firebaseAuth = null,
        super(Unauthenticated());

  bool get isDemo => _firebaseAuth == null;

  void _init() {
    _firebaseAuth?.authStateChanges().listen((User? user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      emit(const AuthError('Sign-in is turned off in demo mode.'));
      emit(Unauthenticated());
      return;
    }
    emit(AuthLoading());
    try {
      await auth.signInWithEmailAndPassword(
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
    await _firebaseAuth?.signOut();
  }
}
