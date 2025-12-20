import 'package:aerosense/api.dart';
import 'package:aerosense/auth.dart';
import 'package:aerosense/main.dart';
import 'package:aerosense/model/menu_item.dart';
import 'package:aerosense/model/permission.dart';
import 'package:aerosense/pages/settings/airports/editor.dart';
import 'package:aerosense/widgets/footer.dart';
import 'package:aerosense/widgets/header.dart';
import 'package:aerosense/widgets/side_menu.dart';
import 'package:flutter/material.dart';

class Airports extends StatefulWidget {
  const Airports({super.key});

  @override
  State<Airports> createState() => _AirportsState();
}

class _AirportsState extends State<Airports> {
  String selected = MenuItem.settingsAirports;

  final ScrollController _airportsController = ScrollController();

  List<Map<String, dynamic>> _airports = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _fetchAirports();
  }

  Future<void> _fetchAirports() async {
    final List<dynamic> response = await Api.instance.get('/api/airport') as List<dynamic>;

    setState(() {
      _airports = response
        .map((dynamic e) => e as Map<String, dynamic>)
        .toList();
    });
  }

  void _openAirportsDialog(Map<String, dynamic> airport) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Editor(
          airport: airport,
          onSave: (Map<String, dynamic> updatedAirport) async {
            if (airport['id'] == 0) {
              await Api.instance.post('/api/airport', <String, dynamic>{
                'name': updatedAirport['name'],
                'city': updatedAirport['city'],
                'country': updatedAirport['country'],
                'iataCode': updatedAirport['iataCode'],
                'latitude': updatedAirport['latitude'],
                'longitude': updatedAirport['longitude']
              });
            }
            else {
              await Api.instance.put('/api/airport', updatedAirport);
            }
            await _fetchAirports();
          },
          onDelete: () async {
            if (airport['id'] != 0) {
              await Api.instance.delete("/api/airport/${airport["id"]}");
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
      body: _airports.isEmpty
        ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[300]))
        : Scrollbar(
          controller: _airportsController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _airportsController,
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
                          'Airports',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (Auth.instance.allowed(Permission.settingsModifyAirports))
                          IconButton(
                            onPressed: () {
                              _openAirportsDialog(<String, dynamic>{'id': 0});
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
                                width: 130,
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
                                width: 130,
                                child: Center(
                                  child: Text(
                                    'City',
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
                                    'Country',
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
                                    'IATA Code',
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
                          rows: _airports.map((Map<String, dynamic> airport) {
                            return DataRow(
                              cells: <DataCell>[
                                DataCell(
                                  SizedBox(
                                    width: 130,
                                    child: Center(
                                      child: Text(
                                        airport['name'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.settingsModifyAirports)) {
                                      _openAirportsDialog(airport);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 130,
                                    child: Center(
                                      child: Text(
                                        airport['city'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.settingsModifyAirports)) {
                                      _openAirportsDialog(airport);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 130,
                                    child: Center(
                                      child: Text(
                                        airport['country'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.settingsModifyAirports)) {
                                      _openAirportsDialog(airport);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: Center(
                                      child: Text(
                                        airport['iataCode'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.settingsModifyAirports)) {
                                      _openAirportsDialog(airport);
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
