import 'package:flutter/material.dart';
import 'package:artvibes_app/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'orders.dart';

// Main Cart class that manages both the UI and the global cart state
class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  // ====== Static Cart Management Methods ======
  // These methods can be used from anywhere in the app to manage the cart
  static List<Map<String, dynamic>> cartItems = [];

  static int getCartCount() => cartItems.length;
  static void addItem(Map<String, dynamic> item) => cartItems.add(item);
  static void removeItem(Map<String, dynamic> item) => cartItems.remove(item);
  static void clearCart() => cartItems.clear();
  static List<Map<String, dynamic>> getItems() => cartItems;
  static int getTotalAmount() =>
      cartItems.fold(0, (total, item) => total + (item['price'] as int));

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  // ====== Local Variables ======
  List<Map<String, dynamic>> cartItems = Cart.cartItems;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ====== Helper Methods ======

  // Removes an item from the cart
  void _removeFromCart(int index) {
    setState(() {
      Cart.removeItem(cartItems[index]);
    });
  }

  // Shows a message to the user
  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: AppColors.white,
            fontFamily: "Poppins",
          ),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Shows order confirmation dialog
  void _showOrderConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: AppColors.white,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lavender.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.lavender,
                    size: 40,
                  ),
                ),
                SizedBox(height: 16),

                // Title
                Text(
                  "Order Placed Successfully!",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 20,
                    color: AppColors.gray,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12),

                // Message
                Text(
                  "Your order has been placed successfully. You can track your order in the Orders section.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    color: AppColors.gray,
                  ),
                ),
                SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lavender,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, '/orders');
                        },
                        child: Text(
                          "View Orders",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.gray),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, '/artwork_marketplace');
                        },
                        child: Text(
                          "Continue Shopping",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray,
                          ),
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

  // ====== Order Processing ======

  // Handles the order placement process
  Future<void> _placeOrder() async {
    if (cartItems.isEmpty) return;

    User? user = _auth.currentUser;
    if (user == null) {
      _showMessage('Please login to place an order');
      return;
    }

    try {
      // Create new order object
      final newOrder = {
        "orderNumber":
            DateTime.now().millisecondsSinceEpoch.toString().substring(7),
        "status": "Processing",
        "totalAmount": Cart.getTotalAmount(),
        "orderDate": FieldValue.serverTimestamp(),
        "artworks": cartItems
            .map((item) => {
                  "imagePath": item["imagePath"],
                  "name": item["name"],
                  "artist": item["artist"],
                  "price": item["price"],
                })
            .toList(),
      };

      // Save order and clear cart
      await OrderService.addOrder(newOrder);
      setState(() => Cart.clearCart());

      // Show success dialog
      if (context.mounted) {
        _showOrderConfirmation();
      }
    } catch (e) {
      if (context.mounted) {
        _showMessage('Failed to place order. Please try again.');
      }
    }
  }

  // ====== UI Building Methods ======

  // Builds the cart item card
  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 3.0,
        top: 1.0,
        right: 0.0,
        bottom: 10.0,
      ),
      child: Row(
        children: [
          // Artwork Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item["imagePath"],
              width: 66,
              height: 83,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 11),

          // Artwork Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["name"],
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.gray,
                  ),
                ),
                Text(
                  "By ${item['artist']}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                    color: AppColors.gray.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "${item['price']} SAR",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                    color: AppColors.tail,
                  ),
                ),
              ],
            ),
          ),

          // Remove Button
          IconButton(
            icon: Icon(Icons.remove_circle_rounded, color: AppColors.yellow),
            onPressed: () => _removeFromCart(index),
          ),
        ],
      ),
    );
  }

  // Builds the cart total and action buttons
  Widget _buildCartActions() {
    return Column(
      children: [
        // Total Amount
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray,
              ),
            ),
            Text(
              "${Cart.getTotalAmount()} SAR",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 17.8,
                fontWeight: FontWeight.w700,
                color: AppColors.tail,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Place Order Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          onPressed: _placeOrder,
          child: Text(
            "Place Order",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 8),

        // Continue Shopping Button
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: AppColors.gray, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          onPressed: () => Navigator.pushNamed(context, '/artwork_marketplace'),
          child: Text(
            "Continue Shopping",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.gray,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 13),
      ],
    );
  }

  // Builds the empty cart message
  Widget _buildEmptyCart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 240),
        Text(
          "Your cart is empty",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.gray,
            fontFamily: "Poppins",
          ),
        ),
        SizedBox(height: 280),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          onPressed: () => Navigator.pushNamed(context, '/artwork_marketplace'),
          child: Text(
            "Browse Artworks",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
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
              SizedBox(height: 24),
              // Top Navigation Bar
              Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/artwork_marketplace'),
                    child: Image.asset(
                      "assets/icons/previous.png",
                      height: 29,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Cart",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 29),
                ],
              ),

              // Cart Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: cartItems.isEmpty
                      ? _buildEmptyCart()
                      : Column(
                          children: [
                            // List of Cart Items
                            Expanded(
                              child: ListView.builder(
                                itemCount: cartItems.length,
                                itemBuilder: (context, index) =>
                                    _buildCartItem(cartItems[index], index),
                              ),
                            ),
                            // Total and Action Buttons
                            _buildCartActions(),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
