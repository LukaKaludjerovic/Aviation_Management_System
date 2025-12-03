import 'package:aerosense/api.dart';
import 'package:aerosense/main.dart';
import 'package:aerosense/model/menu_item.dart';
import 'package:aerosense/model/permission.dart';
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

    setState(() {
      _roles = List<Map<String, dynamic>>.from(response as Iterable<dynamic>);
    });
  }

  void _openRoleDialog(Map<String, dynamic> role) {
    final TextEditingController name = TextEditingController(text: (role['name'] ?? '') as String);

    final List<String> selectedFunctions = (role['allowedFunctions'] ?? '')
      .toString()
      .split(',')
      .map((String f) => f.trim())
      .where((String f) => f.isNotEmpty)
      .toList();

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: role['id'] == 0 
                ? const Text('New role') 
                : const Text('Edit role'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Theme(
                      data: Theme.of(context).copyWith(
                        inputDecorationTheme: const InputDecorationTheme(
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                            ),
                          ),
                        )
                      ),
                      child: TextField(
                        autofocus: true,
                        controller: name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Role Name',
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey
                            ),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16
                    ),

                    const Text(
                      'Allowed Functions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),

                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Scrollbar(
                        child: ListView(
                          children: Permission.all.map((String func) {
                            return CheckboxListTile(
                              title: Text(func),
                              value: selectedFunctions.contains(func),
                              fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.black;
                                }
                                return Colors.transparent;
                              }),
                              onChanged: (bool? checked) {
                                setState(() {
                                  if (checked ?? false) {
                                    selectedFunctions.add(func);
                                  } 
                                  else {
                                    selectedFunctions.remove(func);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (role['id'] != 0) Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextButton(
                              onPressed: () async {
                                await Api.instance.delete("/api/role/${role["id"]}");

                                _fetchRoles();

                                if (!context.mounted) {
                                  return;
                                }
                                Navigator.pop(context);
                              }, 
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.black
                                ),
                              )
                            ),
                          ],
                        ) 
                        else const Row(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: Colors.black
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (role['id'] == 0) {
                              final Map<String, String> newRole = <String, String>{
                                'name': name.text.trim(),
                                'allowedFunctions': selectedFunctions.join(','),
                              };

                              await Api.instance.post('/api/role', newRole);
                            }
                            else {
                              final Map<String, dynamic> updatedRole = <String, dynamic>{
                                'id': role['id'],
                                'name': name.text.trim(),
                                'allowedFunctions': selectedFunctions.join(','),
                              };

                              await Api.instance.put('/api/role', updatedRole);
                            }
                            
                            _fetchRoles();

                            if (!context.mounted) {
                              return;
                            }
                            Navigator.pop(context);
                          }, 
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: Colors.black
                            ),
                          )
                        )
                      ],
                    )
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
  
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
      body: _roles.isEmpty
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
                          'Roles',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
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
                              label: Text(
                                'Name',
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
                          ], 
                          rows: _roles.map((Map<String, dynamic> role) {
                            final String allowedFunctions = 
                              role['allowedFunctions']
                              .toString()
                              .replaceAll(',', ', ');
                            
                            return DataRow(
                              cells: <DataCell>[
                                DataCell(
                                  Text(
                                    role['name'].toString(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  onTap: () => _openRoleDialog(role)
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 300,
                                    child: Text(
                                      allowedFunctions,
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  onTap: () => _openRoleDialog(role)
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
