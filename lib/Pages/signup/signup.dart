import 'package:empedu/pages/login/login.dart';
import 'package:empedu/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
                // here
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
                _emailAddress(),
                const SizedBox(height: 16),
                _password(),
                const SizedBox(height: 16),
                _confirmPassword(),
                const SizedBox(height: 40),
                _signup(context),
              ],
            ),
          ),
        ));
  }

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

  Widget _password() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Password',
        //   style: GoogleFonts.raleway(
        //     textStyle: const TextStyle(
        //       color: Colors.black,
        //       fontWeight: FontWeight.normal,
        //       fontSize: 16,
        //     ),
        //   ),
        // ),
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

  Widget _confirmPassword() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Confirm Password',
        //   style: GoogleFonts.raleway(
        //     textStyle: const TextStyle(
        //       color: Colors.black,
        //       fontWeight: FontWeight.normal,
        //       fontSize: 16,
        //     ),
        //   ),
        // ),
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

  Widget _signup(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Check if the passwords match
        if (_passwordController.text == _confirmPasswordController.text) {
          await AuthService().signup(
            email: _emailController.text,
            password: _passwordController.text,
            context: context,
          );
        } else {
          // Show error if passwords do not match
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
}
