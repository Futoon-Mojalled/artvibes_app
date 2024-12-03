import 'package:flutter/material.dart';
import 'package:artvibes_app/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Main signup screen widget
// StatefulWidget is used because we need to manage form inputs and loading states
class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // ====== Controllers & Variables ======
  // Controllers handle user input in text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State variables for the form
  String selectedRole = 'Client';    // Tracks selected user role
  bool _isLoading = false;           // Shows loading spinner when true
  final List<String> roles = ['Client', 'Artist', 'Admin'];

  // Firebase services for authentication and database
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ====== Styling Configurations ======
  // Reusable text styles for consistent appearance
  final _styles = {
    'label': TextStyle(
      fontSize: 14,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w600,
      color: AppColors.gray,
    ),
    'title': TextStyle(
      fontSize: 26,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w700,
      color: AppColors.gray,
    ),
    'button': TextStyle(
      fontSize: 17,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    ),
    'link': TextStyle(
      fontSize: 15,
      fontFamily: "Poppins",
      color: AppColors.gray,
    ),
  };

  // ====== Helper Methods ======
  
  // Creates consistent input field decoration
  InputDecoration _getInputDecoration() {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: AppColors.lightgray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: AppColors.tail),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    );
  }

  // ====== Authentication Methods ======
  
  // Handles the entire signup process
  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true); // Show loading spinner

    try {
      // Check if all fields are filled
      if ([nameController, emailController, passwordController]
          .any((controller) => controller.text.isEmpty)) {
        throw 'Please fill all fields';
      }

      // Create user account in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (userCredential.user != null) {
        // Save additional user data in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'role': selectedRole,
          'createdAt': Timestamp.now(),
          'uid': userCredential.user!.uid,
        });

        // Update user's display name
        await userCredential.user!.updateDisplayName(nameController.text.trim());

        if (mounted) {
          _showMessage('Account created successfully!', isError: false);
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      _handleError(e);
    }

    if (mounted) setState(() => _isLoading = false); // Hide loading spinner
  }

  // Handles different types of authentication errors
  void _handleError(dynamic error) {
    if (!mounted) return;

    final errorMessages = {
      'weak-password': 'The password provided is too weak.',
      'email-already-in-use': 'An account already exists for this email.',
      'invalid-email': 'Please enter a valid email address.',
    };

    String message = error is FirebaseAuthException
        ? errorMessages[error.code] ?? 'An error occurred. Please try again.'
        : error is String
            ? error
            : 'An error occurred. Please try again.';

    _showMessage(message, isError: true);
  }

  // Shows feedback messages to the user
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // ====== UI Building Methods ======
  
  // Creates a labeled input field
  Widget _buildField(String label, TextEditingController controller,
      {bool isPassword = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _styles['label']),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          cursorColor: AppColors.tail,
          style: TextStyle(fontSize: 14),
          decoration: _getInputDecoration(),
          obscureText: isPassword,
          keyboardType: keyboardType,
        ),
        SizedBox(height: 15),
      ],
    );
  }

  // Creates the role selection dropdown
  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Role", style: _styles['label']),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedRole,
          items: roles
              .map((role) => DropdownMenuItem(value: role, child: Text(role)))
              .toList(),
          onChanged: (value) => setState(() => selectedRole = value ?? 'Client'),
          decoration: _getInputDecoration(),
          icon: Icon(Icons.arrow_drop_down, color: AppColors.gray),
          dropdownColor: AppColors.white,
        ),
        SizedBox(height: 15),
      ],
    );
  }

  // ====== Main Build Method ======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Back Navigation Button
          Positioned(
            top: 24,
            left: 16,
            child: IconButton(
              icon: Image.asset("assets/icons/previous.png", width: 30),
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            ),
          ),

          // Signup Form Content
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 83),
                Center(child: Text("Sign Up", style: _styles['title'])),
                SizedBox(height: 46),

                // Input Fields Section
                _buildField("Name", nameController),
                _buildField("Email", emailController,
                    keyboardType: TextInputType.emailAddress),
                _buildRoleDropdown(),
                _buildField("Password", passwordController, isPassword: true),
                SizedBox(height: 38),

                // Signup Button
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tail,
                      padding: EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text("Sign Up", style: _styles['button']),
                  ),
                ),
                SizedBox(height: 20),

                // Login Link Section
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ", style: _styles['link']),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: Text(
                          "Log In",
                          style: _styles['link']!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.tail,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Clean up controllers when widget is disposed
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}