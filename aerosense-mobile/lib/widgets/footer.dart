import 'package:flutter/material.dart';

class Footer extends StatelessWidget implements PreferredSizeWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Having troubles?\nPlease contact support@aerosense.com',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
