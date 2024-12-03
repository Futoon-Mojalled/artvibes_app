import 'package:flutter/material.dart';

void main() {
  runApp(ArtVibesApp());
}

class ArtVibesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFADADA), // Light pink background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.person_outline, size: 40, color: Colors.black54),
                  Image.asset('assets/artvibes_logo.png', height: 40), // Logo placeholder
                  Icon(Icons.notifications_none, size: 28, color: Colors.black54),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Hello, User Name',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'What Do You Want To Do Today?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
              // Menu Buttons
              Expanded(
                child: ListView(
                  children: [
                    _buildMenuItem('Events Calendar', 'assets/events_calendar.jpg'),
                    _buildMenuItem('Galleries and Museums', 'assets/galleries.jpg'),
                    _buildMenuItem('Artwork Marketplace', 'assets/marketplace.jpg'),
                    _buildMenuItem('Communities', 'assets/communities.jpg'),
                    _buildMenuItem('Artists', 'assets/artists.jpg'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }

  // Helper Widget for Menu Item
  Widget _buildMenuItem(String title, String imagePath) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
