import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:empedu/pages/dashboard/dashboard.dart';
import 'package:empedu/pages/login/login.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AuthService {
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

      // Pastikan konteks masih valid sebelum melakukan navigasi
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

      // Tampilkan dialog kesalahan
      if (context.mounted) {
        _showErrorDialog(context, message);
      }
    } catch (e) {
      // Tampilkan dialog kesalahan
      if (context.mounted) {
        _showErrorDialog(context, "An unexpected error occurred.");
      }
      print("Error: $e");
    }
  }

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

      await Future.delayed(const Duration(seconds: 1));

      // Pastikan konteks masih valid sebelum melakukan navigasi
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

      // Tampilkan dialog kesalahan
      if (context.mounted) {
        _showErrorDialog(context, message);
      }
    } catch (e) {
      // Tampilkan dialog kesalahan
      if (context.mounted) {
        _showErrorDialog(context, "An unexpected error occurred.");
      }
      print("Error: $e");
    }
  }

  Future<void> signout({required BuildContext context}) async {
    // Show confirmation dialog before signing out
    bool shouldLogout = await _showLogoutConfirmationDialog(context);
    if (shouldLogout) {
      await FirebaseAuth.instance.signOut();
      await Future.delayed(const Duration(seconds: 1));

      // Pastikan konteks masih valid sebelum melakukan navigasi
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
        false; // If null is returned, treat as false
  }

  // Function to pick image for profile
  Future<void> pickImage({required BuildContext context}) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      // Handle image upload or save it in the user's profile
      // For example, save the image to Firebase storage
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

  // Function to upload the selected profile image (you can customize this)
  Future<void> _uploadProfileImage(File image, BuildContext context) async {
    // Upload the image to Firebase storage or any other service
    // After successful upload, update the user's profile with the new image URL.
    // Example: Saving image URL to Firestore

    try {
      // Code for uploading image to Firebase Storage or any other server
      // For example:
      // String downloadUrl = await uploadImageToFirebase(image);

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
