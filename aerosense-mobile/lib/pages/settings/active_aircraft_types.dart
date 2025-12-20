import 'package:aerosense/api.dart';
import 'package:aerosense/auth.dart';
import 'package:aerosense/main.dart';
import 'package:aerosense/model/menu_item.dart';
import 'package:aerosense/model/permission.dart';
import 'package:aerosense/pages/settings/active_aircraft_types/editor.dart';
import 'package:aerosense/widgets/footer.dart';
import 'package:aerosense/widgets/header.dart';
import 'package:aerosense/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActiveAircraftTypes extends StatefulWidget {
  const ActiveAircraftTypes({super.key});

  @override
  State<ActiveAircraftTypes> createState() => _ActiveAircraftTypesState();
}

class _ActiveAircraftTypesState extends State<ActiveAircraftTypes> {
  String selected = MenuItem.settingsActiveAircraftTypes;

  final ScrollController _activeAircraftTypesController = ScrollController();

  List<Map<String, dynamic>> _aircraftTypes = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _fetchAircraftTypes();
  }

  Future<void> _fetchAircraftTypes() async {
    final List<dynamic> response = await Api.instance.get('/api/aircraft-type/active') as List<dynamic>;

    setState(() {
      _aircraftTypes = response
        .map((dynamic e) => e as Map<String, dynamic>)
        .toList();
    });
  }

  void _openAircraftTypesDialog(Map<String, dynamic> aircraftType) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Editor(
          aircraftType: aircraftType,
          onSave: (Map<String, dynamic> updatedAircraftType) async {
            if (aircraftType['id'] == 0) {
              await Api.instance.post('/api/aircraft-type', <String, dynamic>{
                'name': updatedAircraftType['name'],
                'code': updatedAircraftType['code'],
                'range': updatedAircraftType['range'],
                'eisDate': updatedAircraftType['eisDate']
              });
            }
            else {
              await Api.instance.put('/api/aircraft-type', updatedAircraftType);
            }
            await _fetchAircraftTypes();
          },
          onDelete: () async {
            if (aircraftType['id'] != 0) {
              await Api.instance.delete("/api/aircraft-type/${aircraftType["id"]}");
              await _fetchAircraftTypes();
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
            
            case MenuItem.settingsActiveAircraftTypes:
              navigatorKey.currentState?.pushReplacementNamed('/active-aircraft-types');

            case MenuItem.settingsHistoricAircraftTypes:
              navigatorKey.currentState?.pushReplacementNamed('/historic-aircraft-types');

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
      body: _aircraftTypes.isEmpty
        ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[300]))
        : Scrollbar(
          controller: _activeAircraftTypesController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _activeAircraftTypesController,
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
                          'Active Aircraft Types',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (Auth.instance.allowed(Permission.settingsModifyActiveAircraftTypes))
                          IconButton(
                            onPressed: () {
                              _openAircraftTypesDialog(<String, dynamic>{'id': 0});
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
                          columnSpacing: 30,
                          dataRowMaxHeight: double.infinity,
                          columns: const <DataColumn>[
                            DataColumn(
                              label: SizedBox(
                                width: 150,
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
                                width: 80,
                                child: Center(
                                  child: Text(
                                    'Range',
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
                                width: 200,
                                child: Center(
                                  child: Text(
                                    'Entry into Service',
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
                          rows: _aircraftTypes.map((Map<String, dynamic> aircraftType) {
                            final String eisDateString = aircraftType['eisDate'].toString();
                            final DateTime eisDate = DateTime.parse(eisDateString);
                            final String formattedEisDate = DateFormat('dd.MM.yyyy.').format(eisDate);

                            return DataRow(
                              cells: <DataCell>[
                                DataCell(
                                  SizedBox(
                                    width: 150,
                                    child: Center(
                                      child: Text(
                                        aircraftType['name'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.settingsModifyActiveAircraftTypes)) {
                                      _openAircraftTypesDialog(aircraftType);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 80,
                                    child: Center(
                                      child: Text(
                                        '${aircraftType['range']}km',
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.settingsModifyActiveAircraftTypes)) {
                                      _openAircraftTypesDialog(aircraftType);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 200,
                                    child: Center(
                                      child: Text(
                                        formattedEisDate,
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.settingsModifyActiveAircraftTypes)) {
                                      _openAircraftTypesDialog(aircraftType);
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
