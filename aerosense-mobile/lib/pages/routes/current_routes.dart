import 'package:aerosense/api.dart';
import 'package:aerosense/auth.dart';
import 'package:aerosense/main.dart';
import 'package:aerosense/model/menu_item.dart';
import 'package:aerosense/model/permission.dart';
import 'package:aerosense/pages/routes/editor.dart';
import 'package:aerosense/widgets/footer.dart';
import 'package:aerosense/widgets/header.dart';
import 'package:aerosense/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrentRoutes extends StatefulWidget {
  const CurrentRoutes({super.key});

  @override
  State<CurrentRoutes> createState() => _CurrentRoutesState();
}

class _CurrentRoutesState extends State<CurrentRoutes> {
  String selected = MenuItem.currentRoutes;

  final ScrollController _currentRoutesController = ScrollController();

  List<Map<String, dynamic>> _currentRoutes = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _airports = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _fetchCurrentRoutes();
    _fetchAirports();
  }

  Future<void> _fetchCurrentRoutes() async {
    final List<dynamic> response = await Api.instance.get('/api/route/current') as List<dynamic>;

    setState(() {
      _currentRoutes = response
        .map((dynamic e) => e as Map<String, dynamic>)
        .toList();
    });
  }

  Future<void> _fetchAirports() async {
    final List<dynamic> response = await Api.instance.get('/api/airport') as List<dynamic>;

    setState(() {
      _airports = response
        .map((dynamic e) => e as Map<String, dynamic>)
        .toList();
    });
  }

  void _openRoutesDialog(Map<String, dynamic> route) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Editor(
          route: route,
          airports: _airports,
          onSave: (Map<String, dynamic> updatedRoute) async {
            if (route['id'] == 0) {
              await Api.instance.post('/api/route', <String, dynamic>{
                'origin': updatedRoute['origin'],
                'destination': updatedRoute['destination'],
                'blockTime': updatedRoute['blockTime'],
                'routeDetails': updatedRoute['routeDetails'],
                'commencedAt': updatedRoute['commencedAt'],
              });
            }
            else {
              await Api.instance.put('/api/route', updatedRoute);
            }
            await _fetchCurrentRoutes();
            await _fetchAirports();
          },
          onDelete: () async {
            if (route['id'] != 0) {
              await Api.instance.delete("/api/route/${route["id"]}");
              await _fetchCurrentRoutes();
              await _fetchAirports();
            }
          },
          onTerminate: () async {
            if (route['id'] != 0) {
              await Api.instance.put("/api/route/${route["id"]}/terminate", <String, dynamic>{});
              await _fetchCurrentRoutes();
              await _fetchAirports();
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
      body: _currentRoutes.isEmpty
        ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[300]))
        : Scrollbar(
          controller: _currentRoutesController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _currentRoutesController,
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
                          'Current Routes',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (Auth.instance.allowed(Permission.modifyCurrentRoutes))
                          IconButton(
                            onPressed: () {
                              _openRoutesDialog(<String, dynamic>{'id': 0});
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
                                width: 100,
                                child: Center(
                                  child: Text(
                                    'Origin',
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
                                width: 110,
                                child: Center(
                                  child: Text(
                                    'Destination',
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
                                width: 100,
                                child: Center(
                                  child: Text(
                                    'Frequency',
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
                                width: 90,
                                child: Center(
                                  child: Text(
                                    'Distance',
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
                                width: 75,
                                child: Center(
                                  child: Text(
                                    'Block time',
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
                                width: 120,
                                child: Center(
                                  child: Text(
                                    'Commenced',
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
                          rows: _currentRoutes.map((Map<String, dynamic> currentRoute) {
                            final int frequencies = ((currentRoute['routeDetails']) as List<dynamic>)
                              .map((dynamic rd) => (rd as Map<String, dynamic>)['daysOfWeek']?.toString() ?? '')
                              .join()
                              .replaceAll('-', '')
                              .length;
                            
                            final int hours = int.parse(currentRoute['blockTime'].toString()) ~/ 60;
                            final int minutes = int.parse(currentRoute['blockTime'].toString()) % 60;
                            final String formattedBlockTime = '${hours}h ${minutes}min';

                            final String commencedAtString = currentRoute['commencedAt'].toString();
                            final DateTime commentedAt = DateTime.parse(commencedAtString);
                            final String formattedCommencedAt = DateFormat('dd.MM.yyyy.').format(commentedAt);

                            return DataRow(
                              cells: <DataCell>[
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: Center(
                                      child: Text(
                                        (currentRoute['origin'] as Map<String, dynamic>)['name'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.modifyCurrentRoutes)) {
                                      _openRoutesDialog(currentRoute);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 110,
                                    child: Center(
                                      child: Text(
                                        (currentRoute['destination'] as Map<String, dynamic>)['name'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.modifyCurrentRoutes)) {
                                      _openRoutesDialog(currentRoute);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: Center(
                                      child: Text(
                                        '$frequencies weekly',
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.modifyCurrentRoutes)) {
                                      _openRoutesDialog(currentRoute);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 90,
                                    child: Center(
                                      child: Text(
                                        '${currentRoute['distance']}km',
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.modifyCurrentRoutes)) {
                                      _openRoutesDialog(currentRoute);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 75,
                                    child: Center(
                                      child: Text(
                                        formattedBlockTime,
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.modifyCurrentRoutes)) {
                                      _openRoutesDialog(currentRoute);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 120,
                                    child: Center(
                                      child: Text(
                                        formattedCommencedAt,
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.modifyCurrentRoutes)) {
                                      _openRoutesDialog(currentRoute);
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
