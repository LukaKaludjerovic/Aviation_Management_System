import 'package:aerosense/api.dart';
import 'package:aerosense/auth.dart';
import 'package:aerosense/main.dart';
import 'package:aerosense/model/menu_item.dart';
import 'package:aerosense/model/permission.dart';
import 'package:aerosense/pages/settings/roles/editor.dart';
import 'package:aerosense/widgets/footer.dart';
import 'package:aerosense/widgets/header.dart';
import 'package:aerosense/widgets/side_menu.dart';
import 'package:flutter/material.dart';

class Roles extends StatefulWidget{
  const Roles({super.key});

  @override
  State<Roles> createState() => _RolesState();
}

class _RolesState extends State<Roles> {
  String selected = MenuItem.settingsRoles;

  List<Map<String, dynamic>> _roles = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    final List<dynamic> response = await Api.instance.get('/api/role') as List<dynamic>;

    setState(() {
      _roles = response
        .map((dynamic e) => e as Map<String, dynamic>)
        .toList();
    });
  }

  void _openRoleDialog(Map<String, dynamic> role) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Editor(
          role: role,
          onSave: (Map<String, dynamic> updatedRole) async {
            if (role['id'] == 0) {
              await Api.instance.post('/api/role', <String, dynamic>{
                'name': updatedRole['name'],
                'allowedFunctions': updatedRole['allowedFunctions'],
              });
            }
            else {
              await Api.instance.put('/api/role', updatedRole);
            }
            await _fetchRoles();
          },
          onDelete: () async {
            if (role['id'] != 0) {
              await Api.instance.delete("/api/role/${role["id"]}");
              await _fetchRoles();
            }
          }
        );
      }
    );
  }
  
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
            
            case MenuItem.settingsAircraftTypes:
              navigatorKey.currentState?.pushReplacementNamed('/aircraft-types');

            case MenuItem.settingsAirports:
              navigatorKey.currentState?.pushReplacementNamed('/airports');

            case MenuItem.home:
              navigatorKey.currentState?.pushReplacementNamed('/home');

            case MenuItem.activeAircraft:
              navigatorKey.currentState?.pushReplacementNamed('/active-aircraft');

            case MenuItem.historicAircraft:
              navigatorKey.currentState?.pushReplacementNamed('/historic-aircraft');
            
            case MenuItem.currentRoutes:
              navigatorKey.currentState?.pushReplacementNamed('/current-routes');

            case MenuItem.historicRoutes:
              navigatorKey.currentState?.pushReplacementNamed('/historic-routes');
            
            case MenuItem.pendingMaintenance:
              navigatorKey.currentState?.pushReplacementNamed('/pending-maintenance');

            case MenuItem.historicMaintenance:
              navigatorKey.currentState?.pushReplacementNamed('/historic-maintenance');
          }
        },
      ),
      body: _roles.isEmpty
        ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[300]))
        : Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Spacer(),
                        const Text(
                          'Roles',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (Auth.instance.allowed(Permission.settingsModifyRoles))
                          IconButton(
                            onPressed: () {
                              _openRoleDialog(<String, dynamic>{'id': 0});
                            }, 
                            icon: const Icon(Icons.add_circle),
                            iconSize: 32,
                          )
                      ],
                    ),
                  ),
                ),
                    
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 500
                        ),
                        child: DataTable(
                          columnSpacing: 60,
                          dataRowMaxHeight: double.infinity,
                          columns: const <DataColumn>[
                            DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Center(
                                  child: Text(
                                    'Name',
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 300,
                                child: Center(
                                  child: Text(
                                    'Allowed Functions',
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ),
                          ], 
                          rows: _roles.map((Map<String, dynamic> role) {
                            final List<String> allowedFunctions = (role['allowedFunctions'] ?? '')
                              .toString()
                              .split(',')
                              .toList();
                            
                            return DataRow(
                              cells: <DataCell>[
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: Center(
                                      child: Text(
                                        role['name'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.settingsModifyRoles)) {
                                      _openRoleDialog(role);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 300,
                                    child: Center(
                                      child: Column(
                                        children: allowedFunctions.map((String func) => 
                                          Text(
                                            func, 
                                            softWrap: true, 
                                            overflow: TextOverflow.visible, 
                                            style: const TextStyle(fontSize: 16),
                                            textAlign: TextAlign.center,
                                          )
                                        ).toList()
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.settingsModifyRoles)) {
                                      _openRoleDialog(role);
                                    }
                                  }
                                ),
                              ]
                            );
                          }).toList()
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          ),
        )
    );
  }
}
