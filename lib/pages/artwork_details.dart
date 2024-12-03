import 'package:flutter/material.dart';
import 'package:artvibes_app/colors.dart';
import 'artworks.dart';
import 'cart.dart';

// Screen that shows detailed information about a specific artwork
// StatelessWidget is used because we don't need to manage any changing state
class ArtworkDetails extends StatelessWidget {
  final int artworkIndex; // Which artwork to display
  final Function onAddToCart; // Function to call when adding to cart

  const ArtworkDetails({
    Key? key,
    required this.artworkIndex,
    required this.onAddToCart,
  }) : super(key: key);

  // ====== UI Building Methods ======

  // Creates the top navigation bar with back button, logo, and cart
  Widget _buildTopNavBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/artwork_marketplace'),
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Image.asset(
              "assets/icons/previous.png",
              height: 29,
            ),
          ),
        ),
        // App Logo
        Image.asset(
          "assets/images/logo.png",
          height: 76,
        ),
        // Shopping Cart Icon with Item Count
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/cart'),
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Stack(
              children: [
                Image.asset(
                  "assets/icons/shopping_basket.png",
                  height: 31,
                ),
                // Cart Items Counter
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: AppColors.gray,
                    child: Text(
                      Cart.getCartCount().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Creates the artwork information section
  Widget _buildArtworkInfo(Map<String, dynamic> artwork) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Artwork Title
        Text(
          artwork["name"],
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.gray,
            fontFamily: "Poppins",
          ),
        ),
        SizedBox(height: 1.5),

        // Artwork Description
        Text(
          artwork["description"],
          style: TextStyle(
            fontSize: 14,
            color: AppColors.gray,
            fontWeight: FontWeight.w500,
            fontFamily: "Poppins",
          ),
        ),
        SizedBox(height: 7.5),

        // Artist Name
        Row(
          children: [
            Text(
              "Artist: ",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.gray,
              ),
            ),
            Text(
              artwork["artist"],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.tail,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.8),

        // Artwork Price
        Row(
          children: [
            Text(
              "Price: ",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.gray,
              ),
            ),
            Text(
              "${artwork["price"]} SAR",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.tail,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Creates the add to cart button
  Widget _buildAddToCartButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lavender,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          minimumSize: Size(double.infinity, 50),
        ),
        onPressed: () {
          onAddToCart(); // Add artwork to cart
          Navigator.pop(context); // Go back to previous screen
        },
        child: Text(
          "Add To Cart",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ====== Main Build Method ======
  @override
  Widget build(BuildContext context) {
    // Get the artwork data for this screen
    final artwork = Artworks.getArtworks()[artworkIndex];

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navigation Bar
              _buildTopNavBar(context),
              SizedBox(height: 3),

              // Artwork Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  artwork["imagePath"],
                  width: MediaQuery.of(context).size.width,
                  height: 370,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),

              // Artwork Information
              _buildArtworkInfo(artwork),
              SizedBox(height: 12),

              // Add to Cart Button
              _buildAddToCartButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
