import 'package:flutter/material.dart';
import 'package:artvibes_app/colors.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Logo
            Image.asset(
              "assets/images/logo.png",
              width: 240,
            ),

            // Welcome Sentence
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Welcome to ArtVibes",
                textAlign: TextAlign.center, // Center the text
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray, // Text color
                ),
              ),
            ),

            SizedBox(height: 6),

            // ArtVibes Sentence
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                '"where creativity thrives, and imagination comes alive!"',
                textAlign: TextAlign.center, // Center the text
                style: TextStyle(
                  fontSize: 18.5,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w400,
                  color: AppColors.gray, // Text color
                ),
              ),
            ),

            const Spacer(flex: 3),

            // Buttons Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, "/login"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tail,
                        elevation: 2,
                        shadowColor: AppColors.tail.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, "/signup"),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.tail, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                          color: AppColors.tail,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
