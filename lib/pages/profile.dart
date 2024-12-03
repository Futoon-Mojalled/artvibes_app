// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:artvibes_app/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile.dart';
import 'bottom_nav_bar.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

// Main Profile widget that creates the profile screen
class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

// The state class that contains all the logic and UI for the profile screen
class _ProfileState extends State<Profile> {
  // Track which tab is selected in the bottom navigation bar
  int _currentIndex = 3;

  // Initialize Firebase authentication and database instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Loading state to show loading indicator when fetching data
  bool _isLoading = true;

  // Controllers for the text fields in the add artwork dialog
  final TextEditingController _artworkNameController = TextEditingController();
  final TextEditingController _artworkPriceController = TextEditingController();
  final TextEditingController _artworkDescriptionController =
      TextEditingController();

  // Default user data structure with initial values
  Map<String, dynamic> userData = {
    "name": "",
    "email": "",
    "profileImage": "assets/icons/user.png",
    "isFileImage": false,
    "webImageBytes": null,
    "role": "User",
    "artworkLicense": null,
    "eventsLicense": null,
    "artworks": [],
  };

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when screen opens
  }

  @override
  void dispose() {
    // Clean up text controllers
    _artworkNameController.dispose();
    _artworkPriceController.dispose();
    _artworkDescriptionController.dispose();
    super.dispose();
  }

  // Function to load user data from Firebase
  Future<void> _loadUserData() async {
    try {
      print("Starting to load user data");
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print("No current user found");
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      print("Fetching user document");
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists) {
        print("User document exists");
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        print("Image data from Firestore: ${data['webImageBytes']}");

        if (data['webImageBytes'] != null) {
          print("Converting web image bytes");
          try {
            data['webImageBytes'] =
                Uint8List.fromList(List<int>.from(data['webImageBytes']));
            print("Successfully converted web image bytes");
          } catch (e) {
            print("Error converting web image bytes: $e");
          }
        }

        setState(() {
          userData = {
            ...userData,
            ...data,
            'email': currentUser.email ?? "",
          };
          _isLoading = false;
        });
        print("State updated successfully");
      } else {
        print("Creating new user document");
        await _createUserDocument(currentUser);
      }
    } catch (e) {
      print('Detailed error in loading user data: $e');
      _showErrorSnackBar('Error loading profile data');
      setState(() => _isLoading = false);
    }
  }

  // Create new user document in Firebase
  Future<void> _createUserDocument(User user) async {
    final userDoc = {
      'name': user.displayName ?? "User",
      'email': user.email,
      'profileImage': "assets/icons/user.png",
      'isFileImage': false,
      'webImageBytes': null,
      'role': "User",
      'artworkLicense': null,
      'eventsLicense': null,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(user.uid).set(userDoc);
    setState(() {
      userData = {...userDoc, 'artworks': []};
      _isLoading = false;
    });
  }

  // Update user profile data
  Future<void> _updateProfile(Map<String, dynamic> newData) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      print("Starting profile update");
      Map<String, dynamic> firestoreData = {...newData};

      // Handle image data
      if (firestoreData['webImageBytes'] != null) {
        if (firestoreData['webImageBytes'] is Uint8List) {
          firestoreData['webImageBytes'] =
              List<int>.from(firestoreData['webImageBytes']);
        }
      }

      // Handle license data
      if (firestoreData['artworkLicense'] != null) {
        if (firestoreData['artworkLicense'] is Uint8List) {
          firestoreData['artworkLicense'] =
              List<int>.from(firestoreData['artworkLicense']);
        }
      }
      if (firestoreData['eventsLicense'] != null) {
        if (firestoreData['eventsLicense'] is Uint8List) {
          firestoreData['eventsLicense'] =
              List<int>.from(firestoreData['eventsLicense']);
        }
      }

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update(firestoreData);

      setState(() {
        userData = {...userData, ...newData};
      });

      print("Profile update successful");
    } catch (e) {
      print('Detailed error in updating profile: $e');
      _showErrorSnackBar('Error updating profile');
    }
  }

  // Handle edit profile screen result
  void _handleEditProfileResult(Map<String, dynamic> result) async {
    if (result != null) {
      print("Received edit profile result: $result");

      Map<String, dynamic> updateData = {};

      if (result['webImageBytes'] != null) {
        updateData['webImageBytes'] = result['webImageBytes'];
        updateData['isFileImage'] = true;
      }

      if (result['name'] != null) updateData['name'] = result['name'];
      if (result['role'] != null) updateData['role'] = result['role'];

      if (result['artworkLicense'] != null) {
        if (result['artworkLicense'] is Uint8List) {
          updateData['artworkLicense'] =
              List<int>.from(result['artworkLicense']);
        } else {
          updateData['artworkLicense'] = result['artworkLicense'];
        }
      }
      if (result['eventsLicense'] != null) {
        if (result['eventsLicense'] is Uint8List) {
          updateData['eventsLicense'] = List<int>.from(result['eventsLicense']);
        } else {
          updateData['eventsLicense'] = result['eventsLicense'];
        }
      }

      await _updateProfile(updateData);
      await _loadUserData();
    }
  }

  // Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: "Poppins"),
        ),
        backgroundColor: AppColors.orange,
      ),
    );
  }

  // Build profile image widget
  Widget _buildProfileImage() {
    print("Building profile image with data: ${userData['webImageBytes']}");

    if (userData['webImageBytes'] != null) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.lightgray,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Image.memory(
            userData['webImageBytes'] is Uint8List
                ? userData['webImageBytes']
                : Uint8List.fromList(List<int>.from(userData['webImageBytes'])),
            fit: BoxFit.cover,
            width: 80,
            height: 80,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.lightgray,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          userData['profileImage'] ?? 'assets/icons/user.png',
          fit: BoxFit.cover,
          width: 80,
          height: 80,
        ),
      ),
    );
  }

  // Build role badge (Artist/User)
  Widget _buildRoleBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: userData['role'] == 'Artist'
            ? AppColors.orange.withOpacity(0.1)
            : AppColors.tail.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        userData['role'],
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color:
              userData['role'] == 'Artist' ? AppColors.orange : AppColors.tail,
          fontFamily: "Poppins",
        ),
      ),
    );
  }

  // Show dialog to add new artwork
  void _showAddArtworkDialog() {
    if (userData['artworkLicense'] == null) {
      _showErrorSnackBar('Please upload your Artwork License first');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add New Artwork",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tail,
                    fontFamily: "Poppins",
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _artworkNameController,
                  decoration: InputDecoration(
                    labelText: 'Artwork Name',
                    labelStyle: TextStyle(
                      color: AppColors.gray,
                      fontFamily: "Poppins",
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _artworkPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price (\$)',
                    labelStyle: TextStyle(
                      color: AppColors.gray,
                      fontFamily: "Poppins",
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _artworkDescriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color: AppColors.gray,
                      fontFamily: "Poppins",
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearArtworkForm();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: AppColors.gray,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        _addNewArtwork();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tail,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Add Artwork",
                        style: TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Clear artwork form fields
  void _clearArtworkForm() {
    _artworkNameController.clear();
    _artworkPriceController.clear();
    _artworkDescriptionController.clear();
  }

  // Add new artwork to Firebase
  Future<void> _addNewArtwork() async {
    if (_artworkNameController.text.isEmpty ||
        _artworkPriceController.text.isEmpty ||
        _artworkDescriptionController.text.isEmpty) {
      _showErrorSnackBar('Please fill all fields');
      return;
    }

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final newArtwork = {
        "title": _artworkNameController.text,
        "price": "\$${_artworkPriceController.text}",
        "description": _artworkDescriptionController.text,
        "image": "assets/icons/artwork_placeholder.png",
        "createdAt": FieldValue.serverTimestamp(),
      };

      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('artworks')
          .add(newArtwork);

      setState(() {
        userData['artworks'].add({...newArtwork, 'id': docRef.id});
      });

      _clearArtworkForm();
    } catch (e) {
      print('Error adding artwork: $e');
      _showErrorSnackBar('Error adding artwork');
    }
  }

  // Show empty state when no artworks
  Widget _buildEmptyArtworkState() {
    return Container(
      padding: EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.art_track,
            size: 64,
            color: AppColors.gray.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            "No Artworks Yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.gray,
              fontFamily: "Poppins",
            ),
          ),
          SizedBox(height: 8),
          Text(
            userData['artworkLicense'] == null
                ? "Upload your artwork license to start adding artworks"
                : "Start adding your artworks",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray.withOpacity(0.7),
              fontFamily: "Poppins",
            ),
          ),
          if (userData['artworkLicense'] != null) ...[
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddArtworkDialog,
              icon: Icon(Icons.add_circle_outline, color: AppColors.white),
              label: Text(
                "Add Artwork",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                  fontFamily: "Poppins",
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tail,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Build grid of artworks
  Widget _buildArtworkGrid() {
    if (userData['artworks'].isEmpty) {
      return _buildEmptyArtworkState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: userData['artworks'].length + 1,
      itemBuilder: (context, index) {
        if (index == userData['artworks'].length) {
          return _buildAddArtworkCard();
        }
        return _buildArtworkCard(userData['artworks'][index]);
      },
    );
  }

  // Build individual artwork card
  Widget _buildArtworkCard(Map<String, dynamic> artwork) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              artwork['image']!,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artwork['title']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray,
                    fontFamily: "Poppins",
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  artwork['price']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.tail,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  artwork['description']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray.withOpacity(0.7),
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build add artwork card
  Widget _buildAddArtworkCard() {
    return GestureDetector(
      onTap: _showAddArtworkDialog,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.tail.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppColors.tail,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              "Add Artwork",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.tail,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build section with title and content
  Widget _buildSection(String title, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.tail,
                fontFamily: "Poppins",
              ),
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  // Build profile option item
  Widget _buildProfileOption({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: AppColors.tail,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.gray,
              fontFamily: "Poppins",
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.gray,
            size: 16,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            color: AppColors.lightgray,
            height: 1,
          ),
      ],
    );
  }

  // Build license status indicator
  Widget _buildLicenseStatus({
    required String title,
    required bool isVerified,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isVerified
            ? AppColors.tail.withOpacity(0.1)
            : AppColors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.upload_file,
            color: isVerified ? AppColors.tail : AppColors.orange,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            "$title: ${isVerified ? 'Verified' : 'Not Uploaded'}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isVerified ? AppColors.tail : AppColors.orange,
              fontFamily: "Poppins",
            ),
          ),
        ],
      ),
    );
  }

  // Handle logout
  Future<void> _handleLogout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print('Error signing out: $e');
      _showErrorSnackBar('Error signing out');
    }
  }

  // Handle bottom navigation
  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/tickets');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/orders');
        break;
      case 3:
        // Already on profile page
        break;
    }
  }

  // Main build method for the profile screen
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.tail),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),

                // Profile header
                Center(
                  child: Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray,
                    ),
                  ),
                ),

                // Profile Section
                _buildSection(
                  "",
                  Row(
                    children: [
                      _buildProfileImage(),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['name'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray,
                                fontFamily: "Poppins",
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              userData['email'],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.gray.withOpacity(0.7),
                                fontFamily: "Poppins",
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildRoleBadge(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Show artist-specific sections
                if (userData['role'] == 'Artist') ...[
                  // License Status Section
                  _buildSection(
                    "License Status",
                    Column(
                      children: [
                        _buildLicenseStatus(
                          title: "Artwork License",
                          isVerified: userData['artworkLicense'] != null,
                        ),
                        SizedBox(height: 12),
                        _buildLicenseStatus(
                          title: "Events License",
                          isVerified: userData['eventsLicense'] != null,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Artworks Section
                  _buildSection(
                    "My Artworks",
                    _buildArtworkGrid(),
                  ),
                  SizedBox(height: 24),
                ],

                // Settings Section
                _buildSection(
                  "Settings",
                  Column(
                    children: [
                      _buildProfileOption(
                        title: "Edit Profile",
                        icon: Icons.edit,
                        onTap: () async {
                          dynamic artworkLicenseData =
                              userData['artworkLicense'];
                          dynamic eventsLicenseData = userData['eventsLicense'];

                          if (artworkLicenseData is List<dynamic>) {
                            artworkLicenseData = Uint8List.fromList(
                                List<int>.from(artworkLicenseData));
                          }
                          if (eventsLicenseData is List<dynamic>) {
                            eventsLicenseData = Uint8List.fromList(
                                List<int>.from(eventsLicenseData));
                          }

                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfile(
                                currentName: userData['name'],
                                currentImage: userData['profileImage'],
                                currentRole: userData['role'],
                                artworkLicense: artworkLicenseData,
                                eventsLicense: eventsLicenseData,
                              ),
                            ),
                          );

                          if (result != null) {
                            _handleEditProfileResult(result);
                          }
                        },
                      ),
                      _buildProfileOption(
                        title: "Payment Methods",
                        icon: Icons.payment,
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        title: "Shipping Addresses",
                        icon: Icons.location_on,
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        title: "Notifications",
                        icon: Icons.notifications,
                        onTap: () {},
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Help Section
                _buildSection(
                  "Help & Support",
                  Column(
                    children: [
                      _buildProfileOption(
                        title: "Help Center",
                        icon: Icons.help,
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        title: "Terms & Conditions",
                        icon: Icons.description,
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        title: "Privacy Policy",
                        icon: Icons.privacy_tip,
                        onTap: () {},
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),

                // Logout Button
                ElevatedButton(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "Log Out",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      // Bottom navigation bar
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
