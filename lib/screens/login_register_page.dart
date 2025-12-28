import 'package:flutter/material.dart';
import 'package:flutter_application_gameshub/forgot_password_page.dart';
import '../auth_service.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  bool isLogin = true;
  bool loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // Email validator
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Password validator
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Username validator
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  // Parse Firebase error messages to user-friendly messages
  String parseErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (error.contains('email-already-in-use')) {
      return 'This email is already registered';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Check your connection';
    } else if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later';
    } else if (error.contains('invalid-credential')) {
      return 'Invalid email or password';
    } else {
      return 'An error occurred. Please try again';
    }
  }

  // Show error snackbar
  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Show success snackbar
  void showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ---------------- LOGIN / REGISTER ----------------
  void handleSubmit() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => loading = true);

    try {
      if (isLogin) {
        // Login
        String? result = await AuthService().loginUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (result != "Success") {
          showErrorSnackbar(parseErrorMessage(result!));
        } else {
          showSuccessSnackbar('Login successful!');
        }
      } else {
        // Register
        String? result = await AuthService().registerUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          username: _usernameController.text.trim(),
        );

        if (result != "Success") {
          showErrorSnackbar(parseErrorMessage(result!));
        } else {
          showSuccessSnackbar('Account created successfully!');
        }
      }
    } catch (e) {
      showErrorSnackbar('An unexpected error occurred');
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001F46), Color(0xFF032D7C), Color(0xFF091C44)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 330,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0x12FFFFFF),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white30, width: .7),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x3300B0FF),
                    blurRadius: 18,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      isLogin ? "Welcome Back!" : "Create Account",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: .6,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Username field (only for registration)
                    if (!isLogin)
                      _inputField(
                        "Username",
                        Icons.person,
                        _usernameController,
                        validator: validateUsername,
                      ),

                    // Email field
                    _inputField(
                      "Email",
                      Icons.email,
                      _emailController,
                      validator: validateEmail,
                    ),

                    // Password field
                    _inputField(
                      "Password",
                      Icons.lock,
                      _passwordController,
                      isPassword: true,
                      validator: validatePassword,
                    ),

                    const SizedBox(height: 14),

                    // Login/Register button
                    loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : ElevatedButton(
                            onPressed: handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: const Size(double.infinity, 48),
                              shadowColor: Colors.blueAccent,
                              elevation: 8,
                            ),
                            child: Text(
                              isLogin ? "Login" : "Register",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),

                    // Forgot Password link
                    if (isLogin)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 15),
                    const Divider(color: Colors.white30, thickness: .7),
                    const Text(
                      "Or Continue With",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 15),

                    // Google Sign-In button
                    InkWell(
                      onTap: () async {
                        setState(() => loading = true);
                        String? result = await AuthService().signInWithGoogle();
                        setState(() => loading = false);

                        if (result != "Success") {
                          showErrorSnackbar(parseErrorMessage(result!));
                        } else {
                          showSuccessSnackbar('Signed in with Google!');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Sign in with Google",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Toggle between Login and Register
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                          // Clear form when switching
                          _formKey.currentState?.reset();
                        });
                      },
                      child: Text(
                        isLogin
                            ? "Don't have an account? Register"
                            : "Already have an account? Login",
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==== INPUT FIELD TEMPLATE ====
  Widget _inputField(
    String hint,
    IconData icon,
    TextEditingController ctrl, {
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0x14FFFFFF),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white30, width: 0.7),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.6),
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
