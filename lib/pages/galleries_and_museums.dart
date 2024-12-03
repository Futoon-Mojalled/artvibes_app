import 'package:flutter/material.dart';
import 'package:artvibes_app/colors.dart';

class GalleriesAndMuseums extends StatelessWidget {
  const GalleriesAndMuseums({Key? key}) : super(key: key);

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
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      "assets/icons/previous.png",
                      height: 29,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Galleries and Museums",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Your galleries and museums content goes here
              Expanded(
                child: Center(
                  child: Text(
                    "Explore Galleries and Museums!",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.gray,
                      fontFamily: "Poppins",
                    ),
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
