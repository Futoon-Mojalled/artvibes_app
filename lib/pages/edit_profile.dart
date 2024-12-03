// Import required Flutter packages and dependencies
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For selecting images from device
import 'package:artvibes_app/colors.dart'; // Custom app colors
import 'dart:io'; // For handling files
import 'dart:html' as html; // For web-specific features
import 'dart:typed_data'; // For handling binary data
import 'package:flutter/foundation.dart'
    show kIsWeb; // To check if app is running on web

// Main widget class for the Edit Profile screen
class EditProfile extends StatefulWidget {
  // Required user data that will be passed when creating this screen
  final String currentName;
  final String currentImage;
  final String currentRole;
  final dynamic artworkLicense;
  final dynamic eventsLicense;

  // Constructor to initialize the widget with required data
  const EditProfile({
    Key? key,
    required this.currentName,
    required this.currentImage,
    required this.currentRole,
    this.artworkLicense,
    this.eventsLicense,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

// State class that handles the dynamic content of the Edit Profile screen
class _EditProfileScreenState extends State<EditProfile> {
  // Controllers and variables to manage form data
  late TextEditingController _nameController; // Handles text input for name
  File? _imageFile; // Stores selected image file (mobile)
  File? _artworkLicenseFile; // Stores artwork license file (mobile)
  File? _eventsLicenseFile; // Stores events license file (mobile)
  Uint8List? _webImage; // Stores image data (web)
  Uint8List? _webArtworkLicense; // Stores artwork license data (web)
  Uint8List? _webEventsLicense; // Stores events license data (web)
  String? _currentImagePath; // Current profile image path
  String _selectedRole = 'Client'; // Selected user role
  bool _isLoading = false; // Loading state flag
  String? _nameError; // Error message for name field
  bool _hasUnsavedChanges = false; // Track if form has unsaved changes

  @override
  void initState() {
    super.initState();
    // Initialize form with current user data
    _nameController = TextEditingController(text: widget.currentName);
    _currentImagePath = widget.currentImage;
    _selectedRole = widget.currentRole;
    _nameController.addListener(_onFieldChanged);

    // Initialize license data if it exists
    if (widget.artworkLicense != null) {
      if (widget.artworkLicense is Uint8List) {
        _webArtworkLicense = widget.artworkLicense as Uint8List;
      } else if (widget.artworkLicense is List<int>) {
        _webArtworkLicense =
            Uint8List.fromList(widget.artworkLicense as List<int>);
      }
    }

    if (widget.eventsLicense != null) {
      if (widget.eventsLicense is Uint8List) {
        _webEventsLicense = widget.eventsLicense as Uint8List;
      } else if (widget.eventsLicense is List<int>) {
        _webEventsLicense =
            Uint8List.fromList(widget.eventsLicense as List<int>);
      }
    }
  }

  // Track when form fields are changed
  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  // Handle image selection from device
  Future<void> _pickImage(String type) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // Handle web platform image selection
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            switch (type) {
              case 'profile':
                _webImage = bytes;
                break;
              case 'artwork':
                _webArtworkLicense = bytes;
                break;
              case 'events':
                _webEventsLicense = bytes;
                break;
            }
            _hasUnsavedChanges = true;
          });
        } else {
          // Handle mobile platform image selection
          setState(() {
            switch (type) {
              case 'profile':
                _imageFile = File(pickedFile.path);
                break;
              case 'artwork':
                _artworkLicenseFile = File(pickedFile.path);
                break;
              case 'events':
                _eventsLicenseFile = File(pickedFile.path);
                break;
            }
            _hasUnsavedChanges = true;
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorSnackBar('Failed to select image. Please try again.');
    }
  }

  // Show error message to user
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

  // Build profile image widget based on platform and selected image
  Widget _buildProfileImage() {
    if (kIsWeb && _webImage != null) {
      return Image.memory(
        _webImage!,
        fit: BoxFit.cover,
      );
    } else if (!kIsWeb && _imageFile != null) {
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        _currentImagePath!,
        fit: BoxFit.cover,
      );
    }
  }

  // Check if license file exists for given type
  bool _hasLicenseFile(String type) {
    if (kIsWeb) {
      switch (type) {
        case 'artwork':
          return _webArtworkLicense != null ||
              (widget.artworkLicense != null &&
                  (widget.artworkLicense is Uint8List ||
                      widget.artworkLicense is List<int>));
        case 'events':
          return _webEventsLicense != null ||
              (widget.eventsLicense != null &&
                  (widget.eventsLicense is Uint8List ||
                      widget.eventsLicense is List<int>));
        default:
          return false;
      }
    } else {
      switch (type) {
        case 'artwork':
          return _artworkLicenseFile != null ||
              (widget.artworkLicense != null &&
                  (widget.artworkLicense is Uint8List ||
                      widget.artworkLicense is List<int>));
        case 'events':
          return _eventsLicenseFile != null ||
              (widget.eventsLicense != null &&
                  (widget.eventsLicense is Uint8List ||
                      widget.eventsLicense is List<int>));
        default:
          return false;
      }
    }
  }

  // Handle back button press with unsaved changes
  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Discard Changes?',
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'You have unsaved changes. Are you sure you want to discard them?',
              style: TextStyle(
                fontFamily: "Poppins",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.gray,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Discard',
                  style: TextStyle(
                    color: AppColors.orange,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Validate form fields
  bool _validateForm() {
    bool isValid = true;
    setState(() {
      _nameError = null;
      if (_nameController.text.trim().isEmpty) {
        _nameError = 'Name is required';
        isValid = false;
      } else if (_nameController.text.trim().length < 2) {
        _nameError = 'Name must be at least 2 characters';
        isValid = false;
      }
    });
    return isValid;
  }

  // Save changes and return updated data
  Future<void> _saveChanges() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result = {
        'name': _nameController.text.trim(),
        'role': _selectedRole,
      };

      // Add image if changed
      if (_webImage != null) {
        if (_webImage!.length > 900000) {
          _showErrorSnackBar(
              'Image size too large. Please choose a smaller image.');
          setState(() => _isLoading = false);
          return;
        }
        result['webImageBytes'] = _webImage;
        result['isFileImage'] = true;
      }

      // Add license URLs if uploaded
      if (_webArtworkLicense != null) {
        result['artworkLicense'] = _webArtworkLicense;
      }
      if (_webEventsLicense != null) {
        result['eventsLicense'] = _webEventsLicense;
      }

      Navigator.pop(context, result);
    } catch (e) {
      print('Error saving changes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving changes')),
      );
    }

    setState(() => _isLoading = false);
  }

  // Build license upload section
  Widget _buildLicenseUpload({
    required String title,
    required String subtitle,
    required String type,
    required Function() onTap,
    String? currentLicense,
  }) {
    final bool hasLicense = _hasLicenseFile(type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
              fontFamily: "Poppins",
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasLicense ? AppColors.tail : AppColors.lightgray,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  hasLicense ? Icons.check_circle : Icons.upload_file,
                  color: hasLicense ? AppColors.tail : AppColors.gray,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  hasLicense ? 'License Uploaded' : subtitle,
                  style: TextStyle(
                    color: hasLicense ? AppColors.tail : AppColors.gray,
                    fontFamily: "Poppins",
                    fontSize: 14,
                  ),
                ),
                if (hasLicense) ...[
                  SizedBox(height: 8),
                  Text(
                    'Tap to change',
                    style: TextStyle(
                      color: AppColors.gray,
                      fontFamily: "Poppins",
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build role selection dropdown
  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Role',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
              fontFamily: "Poppins",
            ),
          ),
        ),
        Theme(
          data: Theme.of(context).copyWith(
            popupMenuTheme: PopupMenuThemeData(
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gray.withOpacity(0.08),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: PopupMenuButton<String>(
              offset: Offset(0, 50),
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 40,
                maxWidth: MediaQuery.of(context).size.width - 40,
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'Client',
                  height: 48,
                  child: Text(
                    'Client',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                      color: AppColors.gray,
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Artist',
                  height: 48,
                  child: Text(
                    'Artist',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                      color: AppColors.gray,
                    ),
                  ),
                ),
              ],
              onSelected: (String value) {
                setState(() {
                  _selectedRole = value;
                  _hasUnsavedChanges = true;
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedRole,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.gray,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.gray,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build the main UI of the screen
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.gray),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            "Edit Profile",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.gray,
              fontFamily: "Poppins",
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  // Profile image section
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.lightgray,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _buildProfileImage(),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _pickImage('profile'),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.tail,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  // Name input field
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(
                        color: AppColors.gray,
                        fontFamily: "Poppins",
                      ),
                      errorText: _nameError,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.lightgray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.tail),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.orange),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.orange),
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Role selection dropdown
                  _buildRoleDropdown(),
                  // Show license upload sections if Artist role is selected
                  if (_selectedRole == 'Artist') ...[
                    SizedBox(height: 20),
                    _buildLicenseUpload(
                      title: 'Artwork License',
                      subtitle: 'Upload your artwork license',
                      type: 'artwork',
                      onTap: () => _pickImage('artwork'),
                      currentLicense: widget.artworkLicense,
                    ),
                    SizedBox(height: 20),
                    _buildLicenseUpload(
                      title: 'Events License',
                      subtitle: 'Upload your events license',
                      type: 'events',
                      onTap: () => _pickImage('events'),
                      currentLicense: widget.eventsLicense,
                    ),
                  ],
                  SizedBox(height: 40),
                  // Save changes button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tail,
                      minimumSize: Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Save Changes",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                              fontFamily: "Poppins",
                            ),
                          ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.tail),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Clean up resources when widget is disposed
  @override
  void dispose() {
    if (_hasUnsavedChanges) {
      if (kIsWeb) {
        // Clear web image data
        _webImage = null;
        _webArtworkLicense = null;
        _webEventsLicense = null;
      } else {
        // Clean up temporary image files if they weren't saved
        [_imageFile, _artworkLicenseFile, _eventsLicenseFile].forEach((file) {
          if (file != null) {
            try {
              file.deleteSync();
            } catch (e) {
              print('Error deleting temporary file: $e');
            }
          }
        });
      }
    }

    _nameController.removeListener(_onFieldChanged);
    _nameController.dispose();
    super.dispose();
  }
}
