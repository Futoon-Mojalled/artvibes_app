// Import necessary packages for the app
import 'package:flutter/material.dart';
import 'package:artvibes_app/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

// Widget to display detailed information about a specific order
class OrderDetails extends StatelessWidget {
  // Store the order data passed from the previous screen
  final Map<String, dynamic> order;

  // Constructor that requires order data
  const OrderDetails({Key? key, required this.order}) : super(key: key);

  // Helper function to format dates consistently
  String formatDate(dynamic date) {
    if (date == null) return 'N/A';

    try {
      // Handle different types of date formats
      if (date is Timestamp) {
        DateTime dateTime = date.toDate();
        return DateFormat('dd-MM-yyyy').format(dateTime);
      } else if (date is DateTime) {
        return DateFormat('dd-MM-yyyy').format(date);
      }
      return 'Invalid Date';
    } catch (e) {
      return 'N/A';
    }
  }

  // Main build method for the OrderDetails screen
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
              // Header section with back button and title
              Column(
                children: [
                  Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                          "assets/icons/previous.png",
                          height: 29,
                        ),
                      ),
                      // Page title
                      Expanded(
                        child: Center(
                          child: Text(
                            "Order Details",
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
                ],
              ),

              // Main content area with order details
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      _buildOrderSummaryCard(context),
                      SizedBox(height: 20),
                      // Section title for artworks
                      Text(
                        "Ordered Artworks",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildArtworksCard(),
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

  // Build the card showing order summary information
  Widget _buildOrderSummaryCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 2,
      color: AppColors.white,
      shadowColor: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display order details in rows
            _buildDetailRow("Order Number", "#${order['orderNumber']}",
                valueColor: AppColors.tail),
            _buildDivider(),
            _buildDetailRow("Order Date", formatDate(order['orderDate'])),
            _buildDivider(),
            _buildDetailRow("Status", order['status'] ?? 'N/A',
                valueColor: (order['status'] ?? '') == 'Processing'
                    ? AppColors.orange
                    : const Color(0xFF4EA94F)),
            _buildDivider(),
            _buildDetailRow("Total Amount", "${order['totalAmount'] ?? 0} SAR",
                valueColor: AppColors.tail),
          ],
        ),
      ),
    );
  }

  // Build the card showing list of ordered artworks
  Widget _buildArtworksCard() {
    // Get artworks list from order data, or empty list if null
    List<dynamic> orderArtworks = (order['artworks'] as List?) ?? [];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      color: AppColors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        // Generate a list of artwork items
        child: Column(
          children: List.generate(orderArtworks.length, (index) {
            final artwork = orderArtworks[index] as Map<String, dynamic>;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Artwork image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        artwork['imagePath'] ?? 'assets/images/placeholder.png',
                        width: 63,
                        height: 80,
                        fit: BoxFit.cover,
                        // Show placeholder if image fails to load
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 63,
                            height: 80,
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported,
                                color: AppColors.gray),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 11),
                    // Artwork details (name, artist, price)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artwork['name'] ?? 'Untitled',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins",
                              color: AppColors.gray,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "By ${artwork['artist'] ?? 'Unknown Artist'}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                              color: AppColors.gray.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "${artwork['price'] ?? 0} SAR",
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
                  ],
                ),
                // Add divider between artworks except for the last one
                if (index < orderArtworks.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildDivider(),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Helper widget to build a row with label and value
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
              color: AppColors.gray,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
              color: valueColor ?? AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to create a consistent divider line
  Widget _buildDivider() {
    return Divider(
      color: AppColors.lightgray,
      thickness: 1,
    );
  }
}
