import 'package:aerosense/main.dart';
import 'package:aerosense/model/menu_item.dart';
import 'package:aerosense/widgets/footer.dart';
import 'package:aerosense/widgets/header.dart';
import 'package:aerosense/widgets/side_menu.dart';
import 'package:flutter/material.dart';

class Aircraft extends StatefulWidget {
  const Aircraft({super.key});

  @override
  State<Aircraft> createState() => _AircraftState();
}

class _AircraftState extends State<Aircraft> {
  String selected = MenuItem.aircraft;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      bottomNavigationBar: const Footer(),
      drawer: SideMenu(
        selected: selected,
        onSelect: (String item) {
          selected = item;

          switch (item) {
            case MenuItem.settingsUsers:
              navigatorKey.currentState?.pushReplacementNamed('/users');

            case MenuItem.settingsRoles:
              navigatorKey.currentState?.pushReplacementNamed('/roles');

            case MenuItem.home:
              navigatorKey.currentState?.pushReplacementNamed('/home');

            case MenuItem.aircraft:
              navigatorKey.currentState?.pushReplacementNamed('/aircraft');
            
            case MenuItem.routes:
              navigatorKey.currentState?.pushReplacementNamed('/routes');
            
            case MenuItem.maintenance:
              navigatorKey.currentState?.pushReplacementNamed('/maintenance');
          }
        },
      ),
      body: const Center(child: Text('Aircraft')),
    );
  }
}
