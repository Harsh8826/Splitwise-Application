import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddPressed;

  const CustomBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0F2F1), Color.fromARGB(255, 236, 240, 239)], // Less dark gradient to blend with app context
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 52, 39, 39).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0,Icons.person_outline, 'Friends'),
                      _buildNavItem(1, Icons.groups_outlined, 'Groups'),
                      SizedBox(width: 60), // Space for FAB
                      _buildNavItem(2, Icons.list_alt, 'Activity'),
                      _buildNavItem(3, Icons.account_circle_outlined, 'Account'),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: MediaQuery.of(context).size.width / 2 -30 ,
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: onAddPressed,
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
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

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryGreen : AppColors.greyText,
              size: 25,
            ),
            SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryGreen : AppColors.greyText,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
