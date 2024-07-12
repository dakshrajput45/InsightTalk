import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ITUserAuthSDK {
  User? getUser() => FirebaseAuth.instance.currentUser;

  // *** FIREBASE FUNCTIONS FOR GOOGLE SIGN IN *** //
  /// Sign in with google popup for web
  ///

// Remeber to update print lint in analysis_options.yaml

  Future<User?> googleSignUp() async {
    try {
      // SignIn implementation
      final GoogleSignInAccount? googleSignInAccount =
          await GoogleSignIn().signIn();

      if (googleSignInAccount != null) {
        // Obtain the authentication details from the Google SignInAccount
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        // Create a new credential
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // Sign in to Firebase with the Google Auth credential
        final UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);

        final User? user = authResult.user;
        return user;
      } else {
        // User canceled the sign-in process
        return null;
      }
    } catch (error) {
      // Handle the error
      print("Error signing in with Google: $error");
      rethrow;
    }
    // print("Function chal raha hai");
    // return null;
  }

  Future<User?> emailandPasswordSignUp() async {
    try {
      final UserCredential authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword( email: "Yash123450@gmail.com" ,  password: "Yash123450"   )
      print(authResult);
      final User? user = authResult.user;
      return user;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future signOut() async {
    try {
      // Sign Out out of GoogleSignIn
      await GoogleSignIn().signOut();
      // Sign Out out of Firebase Instance
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
