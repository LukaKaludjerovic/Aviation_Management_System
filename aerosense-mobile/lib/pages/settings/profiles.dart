import 'package:aerosense/main.dart';
import 'package:aerosense/model/menu_item.dart';
import 'package:aerosense/widgets/header.dart';
import 'package:aerosense/widgets/side_menu.dart';
import 'package:flutter/material.dart';

class Profiles extends StatefulWidget{
  const Profiles({super.key});

  @override
  State<Profiles> createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  String selected = MenuItem.settingsProfiles;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      drawer: SideMenu(
        selected: selected,
        onSelect: (String item) {
          selected = item;

          switch (item) {
            case MenuItem.settingsProfiles:
              navigatorKey.currentState?.pushReplacementNamed('/profiles');

            case MenuItem.settingsRoles:
              navigatorKey.currentState?.pushReplacementNamed('/roles');

            case MenuItem.home:
              navigatorKey.currentState?.pushReplacementNamed('/home');
          }
        },
      ),
      body: const Center(child: Text('Profiles')),
    );
  }
}
