import 'package:aerosense/api.dart';
import 'package:aerosense/main.dart';
import 'package:aerosense/model/menu_item.dart';
import 'package:aerosense/pages/settings/users/editor.dart';
import 'package:aerosense/widgets/footer.dart';
import 'package:aerosense/widgets/header.dart';
import 'package:aerosense/widgets/side_menu.dart';
import 'package:flutter/material.dart';

class Users extends StatefulWidget{
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  String selected = MenuItem.settingsUsers;

  List<Map<String, dynamic>> _users = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _roles = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchRoles();
  }

  Future<void> _fetchUsers() async {
    final List<dynamic> response = await Api.instance.get('/api/user') as List<dynamic>;

    setState(() {
      _users = response
        .map((dynamic e) => e as Map<String, dynamic>)
        .toList();
    });
  }

  Future<void> _fetchRoles() async {
    final List<dynamic> response = await Api.instance.get('/api/role') as List<dynamic>;

    setState(() {
      _roles = response
        .map((dynamic e) => e as Map<String, dynamic>)
        .toList();
    });
  }

  void _openUserDialog(Map<String, dynamic> user) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Editor(
          user: user,
          roles: _roles,
          onSave: (Map<String, dynamic> updatedUser) async {
            if (user['id'] == 0) {
              await Api.instance.post('/api/user', <String, dynamic>{
                'firstName': updatedUser['firstName'],
                'lastName': updatedUser['lastName'],
                'userName': updatedUser['userName'],
                'password': updatedUser['password'],
                'role': updatedUser['role'],
                'allowedFunctions': updatedUser['allowedFunctions'],
                'forbiddenFunctions': updatedUser['forbiddenFunctions']
              });
            }
            else {
              await Api.instance.put('/api/user', updatedUser);
            }
            await _fetchUsers();
          },
          onDelete: () async {
            if (user['id'] != 0) {
              await Api.instance.delete("/api/user/${user["id"]}");
              await _fetchUsers();
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

            case MenuItem.home:
              navigatorKey.currentState?.pushReplacementNamed('/home');
          }
        },
      ),
      body: _users.isEmpty
        ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[300]))
        : SingleChildScrollView(
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
                        'Users',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          _openUserDialog(<String, dynamic>{'id': 0});
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
                            label: Text(
                              'Name',
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold
                              ),
                            )
                          ),
                          DataColumn(
                            label: Text(
                              'Role',
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold
                              ),
                            )
                          ),
                          DataColumn(label: Text(
                            'Allowed Functions',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold
                            )
                          )),
                          DataColumn(label: Text(
                            'Forbidden Functions',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold
                            )
                          )),
                        ], 
                        rows: _users.map((Map<String, dynamic> user) {
                          final String allowedFunctions = (user['allowedFunctions'] ?? '')
                            .toString()
                            .replaceAll(',', ', ');
                          
                          final String forbiddenFunctions = (user['forbiddenFunctions'] ?? '')
                            .toString()
                            .replaceAll(',', ', ');
                          
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(
                                Text(
                                  '${user['firstName']} ${user['lastName']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                onTap: () => _openUserDialog(user)
                              ),
                              DataCell(
                                Text(
                                  (user['role'] as Map<String, dynamic>)['name'].toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                onTap: () => _openUserDialog(user)
                              ),
                              DataCell(
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    allowedFunctions,
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                onTap: () => _openUserDialog(user)
                              ),
                              DataCell(
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    forbiddenFunctions,
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                onTap: () => _openUserDialog(user)
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
        )
    );
  }
}
