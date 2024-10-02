import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> signUp(String email, String password) async {
  try {
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential;
  } catch (e) {
    rethrow;
  }
}

Future<UserCredential> signIn(String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return credential;
  } catch (e) {
    rethrow;
  }
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

// AUTH STATE
Stream<User?> authStateChanges() {
  return FirebaseAuth.instance.authStateChanges();
}

User? getCurrentUser() {
  return FirebaseAuth.instance.currentUser;
}

// TODO update user data

// TODO stream user data
