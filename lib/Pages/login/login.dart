import 'package:empedu/pages/signup/signup.dart';
import 'package:empedu/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            mainAxisAlignment:
                MainAxisAlignment.center, // Center column vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center column horizontally
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
                        color: Color(0xFFF691FF), // "emp" color
                      ),
                    ),
                    TextSpan(
                      text: 'EDU',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins-SemiBold',
                        color: Color(0xFF7B88FF), // "EDU" color
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
              const SizedBox(
                  height: 40), // Adjusted to reduce excessive spacing
              _emailAddress(),
              const SizedBox(height: 16),
              _password(),
              const SizedBox(height: 40), // Adjusted spacing to fit better
              _signin(context),
            ],
          ),
        ),
      ),
    );
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
              labelText: 'Email',
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

  Widget _signin(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await AuthService().signin(
          email: _emailController.text,
          password: _passwordController.text,
          context: context,
        );
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
}
