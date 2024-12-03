import 'package:flutter/material.dart';
import 'cart.dart';
import 'artworks.dart';
import 'package:artvibes_app/colors.dart';
import 'artwork_details.dart';

// Main widget for the artwork marketplace screen
// StatefulWidget is used because this screen needs to update its state (like cart count)
class ArtworkMarketplace extends StatefulWidget {
  @override
  _ArtworkMarketplaceState createState() => _ArtworkMarketplaceState();
}

class _ArtworkMarketplaceState extends State<ArtworkMarketplace> {
  // ====== Helper Methods ======

  // Adds an artwork to the shopping cart
  void addToCart(Map<String, dynamic> artwork) {
    setState(() {
      Cart.addItem(artwork);
    });
  }

  // Opens the details page for a specific artwork
  void navigateToArtworkDetails(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtworkDetails(
          artworkIndex: index,
          onAddToCart: () => addToCart(Artworks.getArtworks()[index]),
        ),
      ),
    );
  }

  // Creates a single artwork card widget
  Widget buildArtworkCard(Map<String, dynamic> artwork, int index) {
    return GestureDetector(
      onTap: () => navigateToArtworkDetails(context, index),
      child: Card(
        elevation: 2,
        color: AppColors.white,
        shadowColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            // Artwork Image and Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Artwork Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    artwork["imagePath"],
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 5.3),

                // Artwork Name and Price
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artwork["name"],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                          color: AppColors.gray,
                        ),
                      ),
                      Text(
                        "${artwork["price"]} SAR",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tail,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Add to Cart Button
            Positioned(
              bottom: -5,
              right: -5,
              child: IconButton(
                icon: Image.asset(
                  "assets/icons/add.png",
                  width: 22,
                  height: 22,
                ),
                onPressed: () => addToCart(artwork),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== Main Build Method ======
  @override
  Widget build(BuildContext context) {
    final artworks = Artworks.getArtworks();
    final cartCount = Cart.getCartCount();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Navigation Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/home'),
                    child: Image.asset(
                      "assets/icons/previous.png",
                      height: 29,
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
                    child: Stack(
                      children: [
                        Image.asset(
                          "assets/icons/shopping_basket.png",
                          height: 31,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: AppColors.gray,
                            child: Text(
                              cartCount.toString(),
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
                ],
              ),

              // Page Title
              Text(
                "Artwork Marketplace",
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray,
                  fontFamily: "Poppins",
                ),
              ),
              SizedBox(height: 6),

              // Grid of Artwork Cards
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 3.0,
                    crossAxisSpacing: 3.0,
                    childAspectRatio: 0.63,
                  ),
                  itemCount: artworks.length,
                  itemBuilder: (context, index) =>
                      buildArtworkCard(artworks[index], index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
