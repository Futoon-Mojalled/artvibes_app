// Import required Flutter and Firebase packages for the app
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:artvibes_app/colors.dart';
import 'bottom_nav_bar.dart';
import 'order_details.dart';
import 'cart.dart';

// Service class to handle all Firebase-related order operations
class OrderService {
  // Initialize Firebase instances
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get a stream of orders for the current user
  // Stream allows real-time updates when orders change
  static Stream<QuerySnapshot> getOrders() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .snapshots();
    }
    return const Stream.empty();
  }

  // Add a new order to Firebase for the current user
  static Future<void> addOrder(Map<String, dynamic> order) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Create a timestamp for midnight to avoid timezone issues
      final now = DateTime.now();
      final orderDate = DateTime(now.year, now.month, now.day);

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .add({
        ...order,
        'userId': user.uid,
        'orderDate': Timestamp.fromDate(orderDate),
      });
    }
  }
}

// Main Orders widget that shows the list of orders
class Orders extends StatefulWidget {
  @override
  _OrdersState createState() => _OrdersState();
}

// State class for the Orders widget
class _OrdersState extends State<Orders> {
  // Track which tab is selected in bottom navigation
  int _currentIndex = 2;

  // Handle tab selection in bottom navigation
  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to different pages based on selected tab
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

  // Function to place a new order
  static Future<void> placeOrder(BuildContext context) async {
    final cartItems = Cart.getItems();
    if (cartItems.isEmpty) return;

    try {
      // Create new order object with current cart items
      final newOrder = {
        "orderNumber":
            DateTime.now().millisecondsSinceEpoch.toString().substring(7),
        "status": "Processing",
        "totalAmount": Cart.getTotalAmount(),
        "orderDate": Timestamp.now(),
        "artworks": cartItems
            .map((item) => {
                  "imagePath": item["imagePath"],
                  "name": item["name"],
                  "artist": item["artist"],
                  "price": item["price"],
                })
            .toList(),
      };

      // Add order to Firebase and clear cart
      await OrderService.addOrder(newOrder);
      Cart.clearCart();

      // Show success dialog if context is still valid
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: Text(
                "Order Placed Successfully!",
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: AppColors.gray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                "Your order has been placed successfully. You can track your order in the Orders section.",
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: AppColors.gray,
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    "View Orders",
                    style: TextStyle(
                      color: AppColors.lavender,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/orders');
                  },
                ),
                TextButton(
                  child: Text(
                    "Continue Shopping",
                    style: TextStyle(
                      color: AppColors.gray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/artwork_marketplace');
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Show error message if order placement fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to place order. Please try again.',
              style: TextStyle(color: AppColors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Widget to show when there are no orders
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppColors.tail,
          ),
          SizedBox(height: 16),
          Text(
            "No Orders Yet",
            style: TextStyle(
              fontSize: 22,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w700,
              color: AppColors.gray,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Start exploring artworks and make your first purchase!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
            ),
          ),
          SizedBox(height: 24),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/artwork_marketplace');
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.lavender,
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              "Explore Artworks",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Simple divider line between sections
  Widget _buildDivider() {
    return Divider(
      color: AppColors.lightgray,
      thickness: 1,
    );
  }

  // Main build method for the Orders screen
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
              // Page title
              Center(
                child: Text(
                  "My Orders",
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray,
                  ),
                ),
              ),
              SizedBox(height: 15),
              // Main content area with order list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: OrderService.getOrders(),
                  builder: (context, snapshot) {
                    // Handle different states of data loading
                    if (snapshot.hasError) {
                      return Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState();
                    }

                    // Build list of orders
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final orderDoc = snapshot.data!.docs[index];
                        final orderData =
                            orderDoc.data() as Map<String, dynamic>;

                        // Individual order card
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                          color: AppColors.white,
                          shadowColor: Colors.grey[200],
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 14.0,
                              top: 14.0,
                              right: 14.0,
                              bottom: 5,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Order number and date
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "#${orderData['orderNumber']}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.tail,
                                      ),
                                    ),
                                    Text(
                                      orderData['orderDate'] != null
                                          ? DateTime.fromMillisecondsSinceEpoch(
                                                  orderData['orderDate']
                                                      .toDate()
                                                      .millisecondsSinceEpoch)
                                              .toString()
                                              .split(' ')[0]
                                          : '',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.gray,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 7),
                                _buildDivider(),
                                SizedBox(height: 7),
                                // Order total amount
                                Text(
                                  "Total: ${orderData['totalAmount']} SAR",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gray,
                                  ),
                                ),
                                // Order status and details button
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Status: ",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.gray,
                                          ),
                                        ),
                                        Text(
                                          "${orderData['status']}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: orderData['status'] ==
                                                    'Processing'
                                                ? AppColors.orange
                                                : const Color(0xFF4EA94F),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OrderDetails(order: orderData),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: AppColors.lavender,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                        minimumSize: Size(60, 34),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                      ),
                                      child: Text(
                                        "Details",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.white,
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
                  },
                ),
              ),
            ],
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