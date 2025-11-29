import 'package:aerosense/auth.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.lightBlue[300],
      centerTitle: true,
      title: const Text(
        "AeroSense",
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevation: 0,
      leading: Auth.instance.isLoggedIn
        ? Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(), 
              icon: const Icon(Icons.menu, color: Colors.white)
            )
          )
        : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

