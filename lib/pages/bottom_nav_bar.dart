// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:artvibes_app/colors.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const BottomNavBar({
    Key? key,
    this.currentIndex = 0,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: widget.currentIndex,
      selectedItemColor: AppColors.gray,
      unselectedItemColor: Colors.black54,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 2), // Center vertically
            child: ImageIcon(
              AssetImage("assets/navbar/home_page.png"),
              size: 23.5,
            ),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(top: 2),
            child: ImageIcon(
              AssetImage("assets/navbar/home_page_bold.png"),
              size: 24,
            ),
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 3),
            child: ImageIcon(
              AssetImage("assets/navbar/ticket_page.png"),
              size: 26,
            ),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(top: 3),
            child: ImageIcon(
              AssetImage("assets/navbar/ticket_page_bold.png"),
              size: 26,
            ),
          ),
          label: "Tickets",
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 2),
            child: ImageIcon(
              AssetImage("assets/navbar/order_page.png"),
              size: 21,
            ),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(top: 2),
            child: ImageIcon(
              AssetImage("assets/navbar/order_page_bold.png"),
              size: 21,
            ),
          ),
          label: "Orders",
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 3),
            child: ImageIcon(
              AssetImage("assets/navbar/profile_page.png"),
              size: 25,
            ),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(top: 3),
            child: ImageIcon(
              AssetImage("assets/navbar/profile_page_bold.png"),
              size: 25,
            ),
          ),
          label: "Profile",
        ),
      ],
    );
  }

  // Method to handle item tap
  void _onItemTapped(int index) {
    widget.onTabSelected(index);
  }
}
