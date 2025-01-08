import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:empedu/pages/dashboard/dashboard.dart';
import 'package:empedu/pages/login/login.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AuthService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Function to save user login status
  Future<void> _saveUserLogin() async {
    await _secureStorage.write(key: 'isLoggedIn', value: 'true');
  }

  // Function to check if the user is logged in
  Future<bool> checkUserLoggedIn() async {
    String? isLoggedIn = await _secureStorage.read(key: 'isLoggedIn');
    return isLoggedIn == 'true';
  }

  // Signup function
  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        Fluttertoast.showToast(
          msg: "Email and password cannot be empty.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return;
      }

      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await Future.delayed(const Duration(seconds: 1));

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => Login()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      } else {
        message = 'An unexpected error occurred: ${e.message}';
      }

      if (context.mounted) {
        _showErrorDialog(context, message);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, "An unexpected error occurred.");
      }
      print("Error: $e");
    }
  }

  // Signin function
  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        Fluttertoast.showToast(
          msg: "Email and password cannot be empty.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return;
      }

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await _saveUserLogin(); // Save login status

      await Future.delayed(const Duration(seconds: 1));

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const DashboardPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else {
        message = 'An unexpected error occurred: ${e.message}';
      }

      if (context.mounted) {
        _showErrorDialog(context, message);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, "An unexpected error occurred.");
      }
      print("Error: $e");
    }
  }

  // Signout function
  Future<void> signout({required BuildContext context}) async {
    bool shouldLogout = await _showLogoutConfirmationDialog(context);
    if (shouldLogout) {
      await FirebaseAuth.instance.signOut();
      await _secureStorage.delete(key: 'isLoggedIn'); // Clear login status

      await Future.delayed(const Duration(seconds: 1));

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => Login()),
        );
      }
    }
  }

  // Function to show logout confirmation dialog
  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Logout'),
              content: const Text('Are you sure you want to log out?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Don't log out
                  },
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Proceed with logout
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // Function to pick image for profile
  Future<void> pickImage({required BuildContext context}) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      _uploadProfileImage(image, context);
    } else {
      Fluttertoast.showToast(
        msg: "No image selected.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  // Function to upload profile image
  Future<void> _uploadProfileImage(File image, BuildContext context) async {
    try {
      Fluttertoast.showToast(
        msg: "Profile picture updated successfully.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to upload image.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  // Existing error dialog function
  void _showErrorDialog(BuildContext context, String errorMessage) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(errorMessage),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
