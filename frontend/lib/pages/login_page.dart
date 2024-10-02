import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:perfect_pose/services/auth_service.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    if (emailController.text == "" || passwordController.text == "") {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Missing required fields"),
          );
        },
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      await signIn(emailController.text, passwordController.text);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) {
        return;
      }

      String errorMsg;
      switch (e.code) {
        case 'invalid-email':
          errorMsg = "Invalid email";
        case 'user-not-found' || 'wrong-password':
          errorMsg = "Invalid credentials";
        default:
          errorMsg = "Server error";
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(errorMsg),
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'Images/login_bg_img.png'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Page Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Welcome Container
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 80.0),
                    child: const Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Left-aligns the text
                      children: [
                        Text(
                          'Welcome Back,',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Practice Perfectly',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Email Input Field
                  TextField(
                    controller: emailController,
                    readOnly: _isLoading,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Input Field
                  TextField(
                    controller: passwordController,
                    readOnly: _isLoading,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5F87D4),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Horizontal Divider with 'or'
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'or',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sign up with Google Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add your sign-up with Google functionality here
                    },
                    label: const Text(
                      'Log In with Google',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: const Color(0xFF5FD469),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Not a Registered User Text
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: 'Not a Registered User? ',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
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
