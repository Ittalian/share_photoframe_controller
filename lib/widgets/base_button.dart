import 'package:flutter/material.dart';

class BaseButton extends StatelessWidget {
  final IconData icon;
  final Function onTap;
  const BaseButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () => onTap(),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 50),
        ),
      ),
    );
  }
}