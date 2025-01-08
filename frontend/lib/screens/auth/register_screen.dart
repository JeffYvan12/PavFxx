import 'package:flutter/material.dart';
import 'package:PavFlix/services/auth_service.dart';
//import 'package:PavFlix/ui_settings/themes.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  void _register(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    var user = await _authService.registerWithEmailAndPassword(email, password);
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification email sent. Please check your inbox.")),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bac.jpg', // Replace with the path to your background image
              fit: BoxFit.cover,
            ),
          ),
          // Overlay with opacity for dimming effect
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6), // Adjust opacity to your preference
            ),
          ),
          // Registration Form
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Let\'s get started',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 245, 183, 183),
                    ),
                  ),
                  SizedBox(height: 40),
                  // Full Name Field
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter UserName',
                      hintStyle: TextStyle(color: const Color.fromARGB(255, 243, 242, 242)),
                      prefixIcon: Icon(Icons.person_outline, color: const Color.fromARGB(255, 243, 242, 242)),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 245, 241, 241).withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                     style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  // Email Field
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter Your Email',
                      hintStyle: TextStyle(color: const Color.fromARGB(255, 243, 242, 242)),
                      prefixIcon: Icon(Icons.email_outlined, color: const Color.fromARGB(255, 243, 242, 242)),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 245, 241, 241).withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                     style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  // Password Field
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Make Password',
                      hintStyle: TextStyle(color: const Color.fromARGB(255, 243, 242, 242)),
                      prefixIcon: Icon(Icons.lock_outline, color: const Color.fromARGB(255, 243, 242, 242)),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 245, 241, 241).withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                     style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  // Confirm Password Field
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      hintStyle: TextStyle(color: const Color.fromARGB(255, 243, 242, 242)),
                      prefixIcon: Icon(Icons.lock_outline, color: const Color.fromARGB(255, 243, 242, 242)),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 245, 241, 241).withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                     style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  // Terms and Conditions Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (bool? value) {},
                        activeColor: Colors.orange,
                      ),
                      Text(
                        'Agree to terms and conditions',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Sign Up Button
                  ElevatedButton(
                    onPressed: () => _register(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Sign up',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Or continue with Google
                  Center(
                    child: Text(
                      'or continue with',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle Google sign-up action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Image.asset(
                        'assets/images/google.png', // Add your Google icon here
                        width: 24,
                      ),
                      label: Text(
                        'Google',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Already have an account? Login
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?', style: TextStyle(color: Colors.white)),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text('Login', style: TextStyle(color: Colors.orange)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
