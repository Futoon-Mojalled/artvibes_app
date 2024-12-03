import 'package:flutter/material.dart';
import 'package:artvibes_app/colors.dart';
import 'bottom_nav_bar.dart';

class Tickets extends StatefulWidget {
  @override
  _TicketsState createState() => _TicketsState();
}

class _TicketsState extends State<Tickets> {
  int _currentIndex = 1;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/tickets');
        break;
      case 2:
        Navigator.pushNamed(context, '/orders');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24),

            // Title: "My Tickets"
            Center(
              child: Text(
                "My Tickets",
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray,
                ),
              ),
            ),

            // Centered message
            Expanded(
              child: Center(
                child: Text(
                  "My Tickets Will Appear here!",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Poppins",
                    color: AppColors.gray,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
