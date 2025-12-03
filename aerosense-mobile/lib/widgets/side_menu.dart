import 'package:aerosense/auth.dart';
import 'package:aerosense/main.dart';
import 'package:aerosense/model/menu_item.dart';
import 'package:aerosense/model/permission.dart';
import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
    required this.selected,
    required this.onSelect
  });
  
  final String selected;
  final void Function(String) onSelect;

  Future<void> _logout() async {
    await Auth.instance.logout();
    
    navigatorKey.currentState?.pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                '${Auth.instance.firstName} ${Auth.instance.lastName}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: selected == MenuItem.home
                    ? FontWeight.bold
                    : FontWeight.normal
                ),
              ),
              accountEmail: Text(
                Auth.instance.roleName,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: selected == MenuItem.home
                    ? FontWeight.bold
                    : FontWeight.normal
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(
                  Icons.person, 
                  size: 36, 
                  color: Colors.black
                ),
              ),
              decoration: const BoxDecoration(color: Colors.transparent),
              onDetailsPressed: () {
                Navigator.pop(context);
                onSelect(MenuItem.home);
              },
            ),

            if (Auth.instance.allowed(Permission.settingsProfiles) || Auth.instance.allowed(Permission.settingsRoles)) ...<Widget>[
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  iconTheme: const IconThemeData(color: Colors.black),
                  expansionTileTheme: const ExpansionTileThemeData(
                    iconColor: Colors.black,
                    collapsedIconColor: Colors.black,
                    textColor: Colors.black,
                    collapsedTextColor: Colors.black,
                  ),
                ),
                child: ExpansionTile(
                  initiallyExpanded: selected == MenuItem.settingsProfiles || selected == MenuItem.settingsRoles,
                  leading: const Icon(Icons.settings),
                  title: Text(
                    'Settings',
                    style: TextStyle(
                      fontWeight: selected == MenuItem.settingsProfiles || selected == MenuItem.settingsRoles
                        ? FontWeight.bold
                        : FontWeight.normal
                    ),
                  ),
                  childrenPadding: const EdgeInsets.only(
                    left: 40, 
                    right: 40
                  ),
                  children: <Widget>[
                    if (Auth.instance.allowed(Permission.settingsProfiles))
                      ListTile(
                        leading: const Icon(Icons.manage_accounts),
                        title: Text(
                          'Profiles',
                          style: TextStyle(
                            fontWeight: selected == MenuItem.settingsProfiles
                              ? FontWeight.bold
                              : FontWeight.normal
                          ),
                        ),
                        selected: selected == MenuItem.settingsProfiles,
                        selectedColor: Colors.black,
                        onTap: () {
                          Navigator.pop(context);
                          onSelect(MenuItem.settingsProfiles);
                        }
                      ),
                    if (Auth.instance.allowed(Permission.settingsRoles))
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings),
                        title: Text(
                          'Roles',
                          style: TextStyle(
                            fontWeight: selected == MenuItem.settingsRoles
                              ? FontWeight.bold
                              : FontWeight.normal
                          ),
                        ),
                        selected: selected == MenuItem.settingsRoles,
                        selectedColor: Colors.black,
                        onTap: () {
                          Navigator.pop(context);
                          onSelect(MenuItem.settingsRoles);
                        }
                      ),
                  ],
                ),
              ),
              const Divider(),
            ],

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
