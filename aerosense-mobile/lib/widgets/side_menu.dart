import 'package:aerosense/auth.dart';
import 'package:aerosense/main.dart';
import 'package:aerosense/model/menu_item.dart';
import 'package:aerosense/model/permission.dart';
import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  SideMenu({
    super.key,
    required this.selected,
    required this.onSelect
  });

  final ScrollController _scrollController = ScrollController();
  
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

            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: <Widget>[
                      if (Auth.instance.allowed(Permission.activeAircraft) ||
                        Auth.instance.allowed(Permission.historicAircraft)
                      ) ...<Widget>[
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
                            initiallyExpanded: 
                              selected == MenuItem.activeAircraft || 
                              selected == MenuItem.historicAircraft,
                            leading: const Icon(Icons.connecting_airports),
                            title: Text(
                              'Aircraft',
                              style: TextStyle(
                                fontWeight: 
                                  selected == MenuItem.activeAircraft || 
                                  selected == MenuItem.historicAircraft
                                    ? FontWeight.bold
                                    : FontWeight.normal
                              ),
                            ),
                            childrenPadding: const EdgeInsets.only(
                              left: 40, 
                              right: 40
                            ),
                            children: <Widget>[
                              if (Auth.instance.allowed(Permission.activeAircraft))
                                ListTile(
                                  leading: const Icon(Icons.airplanemode_active),
                                  title: Text(
                                    'Active Aircraft',
                                    style: TextStyle(
                                      fontWeight: selected == MenuItem.activeAircraft
                                        ? FontWeight.bold
                                        : FontWeight.normal
                                    ),
                                  ),
                                  selected: selected == MenuItem.activeAircraft,
                                  selectedColor: Colors.black,
                                  onTap: () {
                                    Navigator.pop(context);
                                    onSelect(MenuItem.activeAircraft);
                                  }
                                ),
                              if (Auth.instance.allowed(Permission.historicAircraft))
                                ListTile(
                                  leading: const Icon(Icons.airplanemode_inactive),
                                  title: Text(
                                    'Historic Aircraft',
                                    style: TextStyle(
                                      fontWeight: selected == MenuItem.historicAircraft
                                        ? FontWeight.bold
                                        : FontWeight.normal
                                    ),
                                  ),
                                  selected: selected == MenuItem.historicAircraft,
                                  selectedColor: Colors.black,
                                  onTap: () {
                                    Navigator.pop(context);
                                    onSelect(MenuItem.historicAircraft);
                                  }
                                ),
                            ],
                          ),
                        ),
                        const Divider()
                      ],
                
                      if (Auth.instance.allowed(Permission.currentRoutes) ||
                        Auth.instance.allowed(Permission.historicRoutes)
                      ) ...<Widget>[
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
                            initiallyExpanded: 
                              selected == MenuItem.currentRoutes || 
                              selected == MenuItem.historicRoutes,
                            leading: const Icon(Icons.route),
                            title: Text(
                              'Routes',
                              style: TextStyle(
                                fontWeight: 
                                  selected == MenuItem.currentRoutes || 
                                  selected == MenuItem.historicRoutes
                                    ? FontWeight.bold
                                    : FontWeight.normal
                              ),
                            ),
                            childrenPadding: const EdgeInsets.only(
                              left: 40, 
                              right: 40
                            ),
                            children: <Widget>[
                              if (Auth.instance.allowed(Permission.currentRoutes))
                                ListTile(
                                  leading: const Icon(Icons.flight_takeoff),
                                  title: Text(
                                    'Current Routes',
                                    style: TextStyle(
                                      fontWeight: selected == MenuItem.currentRoutes
                                        ? FontWeight.bold
                                        : FontWeight.normal
                                    ),
                                  ),
                                  selected: selected == MenuItem.currentRoutes,
                                  selectedColor: Colors.black,
                                  onTap: () {
                                    Navigator.pop(context);
                                    onSelect(MenuItem.currentRoutes);
                                  }
                                ),
                              if (Auth.instance.allowed(Permission.historicRoutes))
                                ListTile(
                                  leading: const Icon(Icons.flight_land),
                                  title: Text(
                                    'Historic Routes',
                                    style: TextStyle(
                                      fontWeight: selected == MenuItem.historicRoutes
                                        ? FontWeight.bold
                                        : FontWeight.normal
                                    ),
                                  ),
                                  selected: selected == MenuItem.historicRoutes,
                                  selectedColor: Colors.black,
                                  onTap: () {
                                    Navigator.pop(context);
                                    onSelect(MenuItem.historicRoutes);
                                  }
                                ),
                            ],
                          ),
                        ),
                        const Divider()
                      ],
                
                      if (Auth.instance.allowed(Permission.pendingMaintenance) ||
                        Auth.instance.allowed(Permission.historicMaintenance)
                      ) ...<Widget>[
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
                            initiallyExpanded: 
                              selected == MenuItem.pendingMaintenance || 
                              selected == MenuItem.historicMaintenance,
                            leading: const Icon(Icons.build),
                            title: Text(
                              'Maintenance',
                              style: TextStyle(
                                fontWeight: 
                                  selected == MenuItem.pendingMaintenance || 
                                  selected == MenuItem.historicMaintenance
                                    ? FontWeight.bold
                                    : FontWeight.normal
                              ),
                            ),
                            childrenPadding: const EdgeInsets.only(
                              left: 40, 
                              right: 40
                            ),
                            children: <Widget>[
                              if (Auth.instance.allowed(Permission.pendingMaintenance))
                                ListTile(
                                  leading: const Icon(Icons.pending_actions),
                                  title: Text(
                                    'Pending Maintenance',
                                    style: TextStyle(
                                      fontWeight: selected == MenuItem.pendingMaintenance
                                        ? FontWeight.bold
                                        : FontWeight.normal
                                    ),
                                  ),
                                  selected: selected == MenuItem.pendingMaintenance,
                                  selectedColor: Colors.black,
                                  onTap: () {
                                    Navigator.pop(context);
                                    onSelect(MenuItem.pendingMaintenance);
                                  }
                                ),
                              if (Auth.instance.allowed(Permission.historicMaintenance))
                                ListTile(
                                  leading: const Icon(Icons.done_all),
                                  title: Text(
                                    'Historic Maintenance',
                                    style: TextStyle(
                                      fontWeight: selected == MenuItem.historicMaintenance
                                        ? FontWeight.bold
                                        : FontWeight.normal
                                    ),
                                  ),
                                  selected: selected == MenuItem.historicMaintenance,
                                  selectedColor: Colors.black,
                                  onTap: () {
                                    Navigator.pop(context);
                                    onSelect(MenuItem.historicMaintenance);
                                  }
                                ),
                            ],
                          ),
                        ),
                        const Divider()
                      ],
                
                      if (Auth.instance.allowed(Permission.settingsUsers) ||
                        (Auth.instance.allowed(Permission.settingsUsers) && Auth.instance.allowed(Permission.settingsModifyUsers)) ||
                        Auth.instance.allowed(Permission.settingsRoles) ||
                        (Auth.instance.allowed(Permission.settingsRoles) && Auth.instance.allowed(Permission.settingsModifyRoles))
                      ) ...<Widget>[
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
                            initiallyExpanded: 
                              selected == MenuItem.settingsUsers || 
                              selected == MenuItem.settingsRoles ||
                              selected == MenuItem.settingsActiveAircraftTypes ||
                              selected == MenuItem.settingsHistoricAircraftTypes ||
                              selected == MenuItem.settingsAirports,
                            leading: const Icon(Icons.settings),
                            title: Text(
                              'Settings',
                              style: TextStyle(
                                fontWeight: 
                                  selected == MenuItem.settingsUsers || 
                                  selected == MenuItem.settingsRoles ||
                                  selected == MenuItem.settingsActiveAircraftTypes ||
                                  selected == MenuItem.settingsHistoricAircraftTypes ||
                                  selected == MenuItem.settingsAirports
                                    ? FontWeight.bold
                                    : FontWeight.normal
                              ),
                            ),
                            childrenPadding: const EdgeInsets.only(
                              left: 40, 
                              right: 40
                            ),
                            children: <Widget>[
                              if (Auth.instance.allowed(Permission.settingsUsers))
                                ListTile(
                                  leading: const Icon(Icons.manage_accounts),
                                  title: Text(
                                    'Users',
                                    style: TextStyle(
                                      fontWeight: selected == MenuItem.settingsUsers
                                        ? FontWeight.bold
                                        : FontWeight.normal
                                    ),
                                  ),
                                  selected: selected == MenuItem.settingsUsers,
                                  selectedColor: Colors.black,
                                  onTap: () {
                                    Navigator.pop(context);
                                    onSelect(MenuItem.settingsUsers);
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
                              if (Auth.instance.allowed(Permission.settingsActiveAircraftTypes))
                                ListTile(
                                  leading: const Icon(Icons.airlines),
                                  title: Text(
                                    'Active Aircraft Types',
                                    style: TextStyle(
                                      fontWeight: selected == MenuItem.settingsActiveAircraftTypes
                                        ? FontWeight.bold
                                        : FontWeight.normal
                                    ),
                                  ),
                                  selected: selected == MenuItem.settingsActiveAircraftTypes,
                                  selectedColor: Colors.black,
                                  onTap: () {
                                    Navigator.pop(context);
                                    onSelect(MenuItem.settingsActiveAircraftTypes);
                                  }
                                ),
                              if (Auth.instance.allowed(Permission.settingsHistoricAircraftTypes))
                                ListTile(
                                  leading: const Icon(Icons.hourglass_bottom),
                                  title: Text(
                                    'Historic Aircraft Types',
                                    style: TextStyle(
                                      fontWeight: selected == MenuItem.settingsHistoricAircraftTypes
                                        ? FontWeight.bold
                                        : FontWeight.normal
                                    ),
                                  ),
                                  selected: selected == MenuItem.settingsHistoricAircraftTypes,
                                  selectedColor: Colors.black,
                                  onTap: () {
                                    Navigator.pop(context);
                                    onSelect(MenuItem.settingsHistoricAircraftTypes);
                                  }
                                ),
                              if (Auth.instance.allowed(Permission.settingsAirports))
                                ListTile(
                                  leading: const Icon(Icons.airline_stops),
                                  title: Text(
                                    'Airports',
                                    style: TextStyle(
                                      fontWeight: selected == MenuItem.settingsAirports
                                        ? FontWeight.bold
                                        : FontWeight.normal
                                    ),
                                  ),
                                  selected: selected == MenuItem.settingsAirports,
                                  selectedColor: Colors.black,
                                  onTap: () {
                                    Navigator.pop(context);
                                    onSelect(MenuItem.settingsAirports);
                                  }
                                ),
                            ],
                          ),
                        ),
                        const Divider()
                      ],
                    ],
                  ),
                ),
              )
            ),

            const Divider(),
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
