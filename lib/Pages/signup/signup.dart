import 'package:empedu/pages/login/login.dart';
import 'package:empedu/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? profileImageUrl; // URL untuk gambar profil pengguna

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _signin(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 30,
        leading: Container(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'emp',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins-SemiBold',
                        color: Color(0xFFF691FF),
                      ),
                    ),
                    TextSpan(
                      text: 'EDU',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins-SemiBold',
                        color: Color(0xFF7B88FF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Empowering\n',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins-Regular',
                        color: Color(0xFFF691FF),
                      ),
                    ),
                    TextSpan(
                      text: 'Education for Development and Understanding',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins-Regular',
                        color: Color(0xFF7B88FF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Image.asset(
                'assets/ImageLogin.png',
                height: 150,
              ),
              const SizedBox(height: 25),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Create your account',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins-semibold',
                          color: Color(
                            0xFF7B88FF,
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _nameField(),
              const SizedBox(height: 16),
              _emailAddress(),
              const SizedBox(height: 16),
              _password(),
              const SizedBox(height: 16),
              _confirmPassword(),
              const SizedBox(height: 16),
              _profileImagePicker(context),
              const SizedBox(height: 40),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk nama pengguna
  Widget _nameField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        SizedBox(
          width: 320,
          child: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              fillColor: const Color(0xffF7F7F9),
              filled: true,
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk input email
  Widget _emailAddress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        SizedBox(
          width: 320,
          child: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              fillColor: const Color(0xffF7F7F9),
              filled: true,
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk input password
  Widget _password() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        SizedBox(
          width: 320,
          child: TextField(
            obscureText: true,
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              fillColor: const Color(0xffF7F7F9),
              filled: true,
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk konfirmasi password
  Widget _confirmPassword() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        SizedBox(
          width: 320,
          child: TextField(
            obscureText: true,
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              fillColor: const Color(0xffF7F7F9),
              filled: true,
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk memilih gambar profil
  Widget _profileImagePicker(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Pick a profile picture (optional)',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.image),
          label: const Text('Choose Image'),
          onPressed: () async {
            String? imageUrl = await AuthService().pickImage(context: context);
            if (imageUrl != null) {
              profileImageUrl = imageUrl;
              Fluttertoast.showToast(
                msg: "Profile image selected.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            }
          },
        ),
      ],
    );
  }

  // Widget untuk tombol signup
  Widget _signup(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_passwordController.text == _confirmPasswordController.text) {
          await AuthService().signup(
            email: _emailController.text,
            password: _passwordController.text,
            name: _nameController.text,
            profileImageUrl: profileImageUrl ?? '', // Gunakan URL jika ada
            context: context,
          );
        } else {
          _showPasswordMismatchDialog(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff898de8),
        minimumSize: const Size(147, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Sign Up',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontFamily: 'Poppins-Bold',
        ),
      ),
    );
  }

  Widget _signin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(children: [
          const TextSpan(
            text: "Already have an account? ",
            style: TextStyle(
              color: Color(0xff6A6A6A),
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
          ),
          TextSpan(
            text: "Log In",
            style: const TextStyle(
              color: Color(0xff1A1D1E),
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
          ),
        ]),
      ),
    );
  }

  void _showPasswordMismatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Password Mismatch'),
          content: const Text(
              'The passwords you entered do not match. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
