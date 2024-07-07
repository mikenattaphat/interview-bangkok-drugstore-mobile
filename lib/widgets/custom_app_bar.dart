import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final IconThemeData? icon;
  final Widget? leadingIcon;
  final double height;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.icon,
    this.leadingIcon,
    this.height = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: AppBar(
        centerTitle: true,
        title: title,
        backgroundColor: Colors.white,
        iconTheme: icon,
        leading: leadingIcon,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
