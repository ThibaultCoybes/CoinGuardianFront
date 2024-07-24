import 'package:flutter/material.dart';
import 'package:coin_guardian/assets/colors.dart';

class ProfileTab extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback onTap;

  const ProfileTab({
    required this.title,
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.darkGrey, width: 1.0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon,
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            const Icon(Icons.keyboard_arrow_right_outlined),
          ],
        ),
      ),
    );
  }
}
