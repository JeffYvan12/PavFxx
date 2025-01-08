import 'package:flutter/material.dart';
import 'package:PavFlix/services/auth_service.dart';
//import 'package:PavFlix/ui_settings/themes.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool visible = false;

  final AuthService _authService = AuthService();

  void _login(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    var user = await _authService.signInWithEmailAndPassword(email, password);

    if (user != null) {
      if (user.emailVerified) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please verify your email to continue.")),
        );
        await _authService.sendEmailVerification();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed. Please check your credentials.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bac.jpg'), // Use your background image here
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView( // Add scroll functionality
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60),
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Hey,\nWelcome Back',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 245, 183, 183),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),
                  // Email input
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  // Password input
                  TextField(
                    controller: passwordController,
                    obscureText: visible,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(
                          visible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            visible = !visible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {}, // Forgot password action
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Login button
                  ElevatedButton(
                    onPressed: () => _login(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // "Or continue with" text
                  Center(
                    child: Text(
                      'or continue with',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Google sign-in button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {}, // Google sign-in action
                      icon: Image.asset('assets/images/google.png',
                          width: 24), // Use your Google icon here
                      label: Text(
                        'Google',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Sign up prompt
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?",
                            style: TextStyle(color: Colors.white70)),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text('Sign Up',
                              style: TextStyle(color: Colors.orangeAccent)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
