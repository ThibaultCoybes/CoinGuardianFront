import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:coin_guardian/assets/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final BuildContext context;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: AppColors.white,
      color: AppColors.purple,
      animationDuration: const Duration(milliseconds: 300),
      onTap: (index) async {
        await Future.delayed(const Duration(milliseconds: 350));

        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/analytics');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/history');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/settings');
            break;
          default:
            break;
        }
      },
      index: selectedIndex,
      items: const [
        Icon(
          Icons.home,
          color: AppColors.white,
        ),
        Icon(
          Icons.graphic_eq_outlined,
          color: AppColors.white,
        ),
        Icon(
          Icons.history,
          color: AppColors.white,
        ),
        Icon(
          Icons.settings,
          color: AppColors.white,
        ),
      ],
    );
  }
}
