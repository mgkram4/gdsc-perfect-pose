import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:perfect_pose/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Indicates whether the user has agreed to the Terms and Conditions
  bool _isTermsChecked = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(BuildContext context) async {
    if (_nameController.text == "" ||
        _emailController.text == "" ||
        _passwordController.text == "" ||
        !_isTermsChecked) {
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
      await signUp(_emailController.text, _passwordController.text);
      getCurrentUser()?.updateProfile(displayName: _nameController.text);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) {
        return;
      }

      String errorMsg;
      switch (e.code) {
        case 'invalid-email':
          errorMsg = "Invalid email";
        case 'email-already-in-use':
          errorMsg = "This email is already in use by another account";
        case 'weak-password':
          errorMsg = e.message == null
              ? 'Password requirements are not met'
              : e.message!;
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
        _isTermsChecked = false;
        _isLoading = false;
      });
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('Images/register_bg_img.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Page Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Welcome Container
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Register Today',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Train a Lifetime',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Name Input Field
                  TextField(
                    controller: _nameController,
                    readOnly: _isLoading,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Email Input Field
                  TextField(
                    controller: _emailController,
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
                  const SizedBox(height: 10.0),

                  // Password Input Field
                  TextField(
                    controller: _passwordController,
                    readOnly: _isLoading,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),

                  // Terms and Conditions Checkbox
                  CheckboxListTile(
                    title: const Text(
                      'I agree to the Terms and Conditions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _isTermsChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isTermsChecked = value!;
                      });
                    },
                  ),

                  // Create Account Button
                  ElevatedButton(
                    onPressed:
                        _isLoading ? null : () => _handleRegister(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5F87D4),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Create Account',
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
                  const SizedBox(height: 20.0),

                  // Sign up with Google Button
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5FD469),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Sign Up with Google',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Already Have an Account Text
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/login");
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already Have an account? ',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        children: [
                          TextSpan(
                            text: 'Sign in',
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
