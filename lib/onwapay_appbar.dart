import 'package:flutter/material.dart';

class OnwaPayAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const OnwaPayAppBar({
    super.key,
    required this.title,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBack,
      backgroundColor: Colors.green[700],
      elevation: 4,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/images/OnwaPay_logo.jpg", // ✅ use your logo
            height: 32,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
