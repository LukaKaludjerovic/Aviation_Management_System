import 'package:aerosense/api.dart';
import 'package:aerosense/auth.dart';
import 'package:aerosense/main.dart';
import 'package:aerosense/model/menu_item.dart';
import 'package:aerosense/model/permission.dart';
import 'package:aerosense/widgets/footer.dart';
import 'package:aerosense/widgets/header.dart';
import 'package:aerosense/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActiveAircraft extends StatefulWidget {
  const ActiveAircraft({super.key});

  @override
  State<ActiveAircraft> createState() => _ActiveAircraftState();
}

class _ActiveAircraftState extends State<ActiveAircraft> {
  String selected = MenuItem.activeAircraft;

  final ScrollController _activeAircraftController = ScrollController();

  List<Map<String, dynamic>> _activeAircraft = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _fetchActiveAircraft();
  }

  Future<void> _fetchActiveAircraft() async {
    final List<dynamic> response = await Api.instance.get('/api/aircraft/active') as List<dynamic>;

    setState(() {
      _activeAircraft = response
        .map((dynamic e) => e as Map<String, dynamic>)
        .toList();
    });
  }

  void _openAircraftDialog(Map<String, dynamic> aircraftType) {}

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
      body: _activeAircraft.isEmpty
        ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[300]))
        : Scrollbar(
          controller: _activeAircraftController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _activeAircraftController,
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
                          'Active Aircraft',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (Auth.instance.allowed(Permission.modifyActiveAircraft))
                          IconButton(
                            onPressed: () {
                              _openAircraftDialog(<String, dynamic>{'id': 0});
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
                                width: 115,
                                child: Center(
                                  child: Text(
                                    'Registration',
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
                                width: 85,
                                child: Center(
                                  child: Text(
                                    'MSN',
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
                                width: 95,
                                child: Center(
                                  child: Text(
                                    'Type',
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
                                width: 130,
                                child: Center(
                                  child: Text(
                                    'Configuration',
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
                                width: 95,
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
                          rows: _activeAircraft.map((Map<String, dynamic> activeAircraft) {
                            final String eisDateString = activeAircraft['eisDate'].toString();
                            final DateTime eisDate = DateTime.parse(eisDateString);
                            final String formattedEisDate = DateFormat('dd.MM.yyyy.').format(eisDate);

                            return DataRow(
                              cells: <DataCell>[
                                DataCell(
                                  SizedBox(
                                    width: 115,
                                    child: Center(
                                      child: Text(
                                        activeAircraft['registration'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.modifyActiveAircraft)) {
                                      _openAircraftDialog(activeAircraft);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 85,
                                    child: Center(
                                      child: Text(
                                        activeAircraft['msn'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.modifyActiveAircraft)) {
                                      _openAircraftDialog(activeAircraft);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 95,
                                    child: Center(
                                      child: Text(
                                        (activeAircraft['type'] as Map<String, dynamic>)['code'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.modifyActiveAircraft)) {
                                      _openAircraftDialog(activeAircraft);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 130,
                                    child: Center(
                                      child: Text(
                                        activeAircraft['configuration'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.modifyActiveAircraft)) {
                                      _openAircraftDialog(activeAircraft);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 95,
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
                                    if (Auth.instance.allowed(Permission.modifyActiveAircraft)) {
                                      _openAircraftDialog(activeAircraft);
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
