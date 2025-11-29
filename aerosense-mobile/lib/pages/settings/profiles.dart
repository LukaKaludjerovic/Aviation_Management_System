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
  String _selected = MenuItem.settingsProfiles;

  void setSelected(String selected) => _selected = selected;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      drawer: SideMenu(
        selected: _selected,
        onSelect: (item) {
          setSelected(item);

          switch (item) {
            case MenuItem.settingsProfiles:
              navigatorKey.currentState?.pushReplacementNamed("/profiles");
              break;

            case MenuItem.settingsRoles:
              navigatorKey.currentState?.pushReplacementNamed("/roles");
              break;

            case MenuItem.home:
              navigatorKey.currentState?.pushReplacementNamed("/home");
              break;
          }
        },
      ),
      body: Center(
        child: Text("Profiles"),
      ),
    );
  }
}