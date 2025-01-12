import 'package:empedu/pages/signup/signup.dart';
import 'package:empedu/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _signup(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 30,
        leading: Container(), // Remove back button with an empty container
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
              const SizedBox(height: 40),
              _emailAddress(),
              const SizedBox(height: 16),
              _password(),
              const SizedBox(height: 40),
              _signin(context),
            ],
          ),
        ),
      ),
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
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
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

  // Tombol untuk login
  Widget _signin(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
          _showErrorDialog(context, "Please enter both email and password.");
          return;
        }

        try {
          await AuthService().signin(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            context: context,
          );
        } catch (e) {
          _showErrorDialog(context, e.toString());
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
        'Login',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontFamily: 'Poppins-Bold',
        ),
      ),
    );
  }

  // Widget untuk navigasi ke halaman signup
  Widget _signup(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(children: [
          const TextSpan(
            text: "New User? ",
            style: TextStyle(
              color: Color(0xff6A6A6A),
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
          ),
          TextSpan(
            text: "Create Account",
            style: const TextStyle(
              color: Color(0xff1A1D1E),
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Signup()),
                );
              },
          ),
        ]),
      ),
    );
  }

  // Dialog untuk menampilkan pesan kesalahan
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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
