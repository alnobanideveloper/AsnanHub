import 'package:asnan_hub/extensions/snackbar_extension.dart';
import 'package:asnan_hub/pages/patient/patient_main.dart';
import 'package:asnan_hub/pages/auth/signup.dart';
import 'package:asnan_hub/services/auth_serrvice.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var authService = AuthService();
  bool _isLoading = false;

  void handleLogin() async {
    if (_isLoading) return; // Prevent multiple clicks

    setState(() {
      _isLoading = true;
    });

    try {
      var userCredentials = await authService.signIn(
        emailController.text.trim(),
        passwordController.text,
      );
      
      if (!mounted) return; // Check if widget is still mounted
      
      print("Login successful: ${userCredentials.user?.email}");

      context.showErrorSnackBar("Login successful", Colors.green);

      // Navigate to main page immediately (AuthGate will also handle this, but this provides immediate feedback)
      // Using pushReplacement so user can't go back to login page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } catch (ex) {
      if (!mounted) return; // Check if widget is still mounted
      
      String errorMessage = 'Login failed. Please try again.';
      if (ex is String) {
        errorMessage = ex;
      } else if (ex.toString().isNotEmpty) {
        errorMessage = ex.toString();
      }

      context.showErrorSnackBar(errorMessage, Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //logo section
              SizedBox(height: 20),
              Center(
                child: Container(
                  width: 200, // slightly bigger than image
                  height: 200,
                  decoration: BoxDecoration(
                    color: scheme.secondary.withOpacity(
                      0.3,
                    ), // outer circle color
                    borderRadius: BorderRadius.circular(300),
                  ),
                  alignment: Alignment.center, // center the image inside
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
          
              SizedBox(height: 20),
              Text(
                "AsnanHub",
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Text(
                "connecting patients with students...",
                style: Theme.of(context).textTheme.labelLarge,
              ),
          
              SizedBox(height: 50),
              Text("Login", style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 20),
              //Signup section
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "email"),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
              ),
          
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isLoading ? null : handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text("Login"),
                ),
              ),
          
              SizedBox(height: 8),
              Row(
                children: [
                  Text("dont have an account ? "),
                  InkWell(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (builder) => Signup()));
                    },
                    child: Text(
                      "Register",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
