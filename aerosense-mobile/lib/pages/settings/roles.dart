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
  String _selected = MenuItem.settingsRoles;

  List<Map<String, dynamic>> _roles = [];

  void setSelected(String selected) => _selected = selected;

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  void _fetchRoles() async {
    final response = await Api.instance.get("/api/role");

    if (response is List) {
      setState(() {
        _roles = List<Map<String, dynamic>>.from(response);
      });
    }
  }

  void _openRoleDialog(Map<String, dynamic> role) {
    final TextEditingController name = TextEditingController(text: role["name"]);

    List<String> selectedFunctions = (role["allowedFunctions"] ?? "")
      .toString()
      .split(",")
      .map((f) => f.trim())
      .where((f) => f.isNotEmpty)
      .toList();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: role["id"] == 0 
                ? Text("New role") 
                : Text("Edit role"),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        inputDecorationTheme: const InputDecorationTheme(
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                        )
                      ),
                      child: TextField(
                        autofocus: true,
                        controller: name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: "Role Name",
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Allowed Functions",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Scrollbar(
                        child: ListView(
                          children: Permission.all.map((func) {
                            return CheckboxListTile(
                              title: Text(func),
                              value: selectedFunctions.contains(func),
                              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.black;
                                }
                                return Colors.transparent;
                              }),
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    selectedFunctions.add(func);
                                  } else {
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

              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    role["id"] != 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () async {
                                await Api.instance.delete("/api/role/${role["id"]}");

                                _fetchRoles();

                                if (!context.mounted) return;
                                Navigator.pop(context);
                              }, 
                              child: const Text(
                                "Delete",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.black
                                ),
                              )
                            ),
                          ],
                        )
                      : Row(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: Colors.black
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (role["id"] == 0) {
                              final newRole = {
                                "name": name.text.trim(),
                                "allowedFunctions": selectedFunctions.join(","),
                              };

                              await Api.instance.post("/api/role", newRole);
                            }
                            else {
                              final updatedRole = {
                                "id": role["id"],
                                "name": name.text.trim(),
                                "allowedFunctions": selectedFunctions.join(","),
                              };

                              await Api.instance.put("/api/role", updatedRole);
                            }
                            
                            _fetchRoles();

                            if (!context.mounted) return;
                            Navigator.pop(context);
                          }, 
                          child: const Text(
                            "Save",
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
      body: _roles.isEmpty
        ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[300]))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Spacer(),
                        Text(
                          "Roles",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {
                            _openRoleDialog({"id": 0});
                          }, 
                          icon: Icon(Icons.add_circle),
                          iconSize: 32,
                        )
                      ],
                    ),
                  ),
                ),
        
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 500),
                        child: DataTable(
                          columnSpacing: 60,
                          dataRowMaxHeight: double.infinity,
                          columns: const [
                            DataColumn(
                              label: Text(
                                "Name",
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold
                                ),
                              )
                            ),
                            DataColumn(label: Text(
                              "Allowed Functions",
                              style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold
                                )
                            )),
                          ], 
                          rows: _roles.map((role) {
                            final allowedFunctions = 
                              role["allowedFunctions"]
                              .toString()
                              .replaceAll(",", ", ");
                            
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    role["name"].toString(),
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