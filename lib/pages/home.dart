import 'package:flutter/material.dart';
import 'package:artvibes_app/colors.dart';
import 'package:artvibes_app/services/auth_service.dart';
import 'bottom_nav_bar.dart';
import 'dart:typed_data';

// Main home screen widget
// StatefulWidget is used because we need to manage user data and navigation state
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // ====== Services & Controllers ======
  final AuthService _authService = AuthService();

  // ====== State Variables ======
  int _currentIndex = 0; // Tracks which bottom nav tab is selected
  String userName = "User"; // Stores the user's name
  bool _isLoading = true; // Shows loading state
  dynamic userProfileImage; // Stores user's profile picture data
  bool isFileImage = false; // Indicates if profile picture is from file

  // ====== Navigation Sections ======
  // List of main sections in the home page with their images and routes
  final List<Map<String, String>> _sections = [
    {
      "title": "Events Calendar",
      "image": "assets/images/events_calendar.jpg",
      "route": "/events_calendar",
    },
    {
      "title": "Artwork Marketplace",
      "image": "assets/images/artwork_marketplace.jpg",
      "route": "/artwork_marketplace",
    },
    {
      "title": "Galleries and Museums",
      "image": "assets/images/galleries_and_museums.jpg",
      "route": "/galleries_and_museums",
    },
    {
      "title": "Communities",
      "image": "assets/images/communities.jpg",
      "route": "/communities",
    },
    {
      "title": "Artists",
      "image": "assets/images/artists.jpg",
      "route": "/artists",
    },
  ];

  // ====== Styling Configurations ======
  // Reusable text styles for consistent appearance
  final _titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.gray,
    fontFamily: "Poppins",
  );

  final _subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.gray,
    fontFamily: "Poppins",
  );

  final _sectionTitleStyle = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: AppColors.yellow,
    fontFamily: "Poppins",
  );

  // ====== Lifecycle Methods ======

  // Initialize the screen by loading user data
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ====== Data Loading Methods ======

  // Fetches user data from authentication service
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final userData = await _authService.getUserData();
    if (userData != null && mounted) {
      setState(() {
        userName = userData['name'] ?? "User";
        userProfileImage = userData['webImageBytes'];
        isFileImage = userData['isFileImage'] ?? false;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  // ====== UI Building Methods ======

  // Creates the profile image widget
  Widget _buildProfileImage() {
    if (_isLoading) {
      return SizedBox(
        height: 33,
        width: 33,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (userProfileImage != null && isFileImage) {
      return ClipOval(
        child: Image.memory(
          Uint8List.fromList(List<int>.from(userProfileImage)),
          height: 37,
          width: 37,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset("assets/icons/user.png", height: 32);
  }

  // Creates a section tile with image and title
  Widget _buildSectionTile(String title, String imagePath, String route) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.5),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background image with overlay
              Image.asset(
                imagePath,
                width: double.infinity,
                height: 107,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.5),
                colorBlendMode: BlendMode.darken,
              ),
              // Section title
              Text(title, style: _sectionTitleStyle),
            ],
          ),
        ),
      ),
    );
  }

  // Creates the top header with profile, logo, and notification
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Profile Picture
        Padding(
          padding: EdgeInsets.only(top: 5),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: _buildProfileImage(),
          ),
        ),
        // App Logo
        Image.asset("assets/images/logo.png", height: 76),
        // Notification Icon
        Padding(
          padding: EdgeInsets.only(top: 2),
          child: Image.asset("assets/icons/notification.png", height: 32),
        ),
      ],
    );
  }

  // ====== Navigation Methods ======

  // Handles bottom navigation bar tab selection
  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);

    // Map tab indices to their routes
    final routes = {
      0: '/home',
      1: '/tickets',
      2: '/orders',
      3: '/profile',
    };

    if (routes.containsKey(index)) {
      Navigator.pushNamed(context, routes[index]!);
    }
  }

  // ====== Main Build Method ======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Section
              _buildHeader(),
              SizedBox(height: 3),

              // Welcome Message Section
              _isLoading
                  ? CircularProgressIndicator()
                  : Text("Hello, $userName", style: _titleStyle),
              SizedBox(height: 1),
              Text("What Do You Want To Do Today?", style: _subtitleStyle),
              SizedBox(height: 8),

              // Main Sections List
              Expanded(
                child: ListView(
                  children: _sections
                      .map((section) => _buildSectionTile(
                            section["title"]!,
                            section["image"]!,
                            section["route"]!,
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
