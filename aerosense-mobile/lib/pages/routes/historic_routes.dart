import 'package:aerosense/api.dart';
import 'package:aerosense/main.dart';
import 'package:aerosense/model/menu_item.dart';
import 'package:aerosense/widgets/footer.dart';
import 'package:aerosense/widgets/header.dart';
import 'package:aerosense/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoricRoutes extends StatefulWidget {
  const HistoricRoutes({super.key});

  @override
  State<HistoricRoutes> createState() => _HistoricRoutesState();
}

class _HistoricRoutesState extends State<HistoricRoutes> {
  String selected = MenuItem.historicRoutes;

  final ScrollController _historicRoutesController = ScrollController();

  List<Map<String, dynamic>> _historicRoutes = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _fetchHistoricRoutes();
  }

  Future<void> _fetchHistoricRoutes() async {
    final List<dynamic> response = await Api.instance.get('/api/route/historic') as List<dynamic>;

    setState(() {
      _historicRoutes = response
        .map((dynamic e) => e as Map<String, dynamic>)
        .toList();
    });
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
      body: _historicRoutes.isEmpty
        ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[300]))
        : Scrollbar(
          controller: _historicRoutesController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _historicRoutesController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Spacer(),
                        Text(
                          'Historic Routes',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer()
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
                            DataColumn(
                              label: SizedBox(
                                width: 120,
                                child: Center(
                                  child: Text(
                                    'Terminated',
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
                          rows: _historicRoutes.map((Map<String, dynamic> historicRoute) {
                            final int frequencies = ((historicRoute['routeDetails']) as List<dynamic>)
                              .map((dynamic rd) => (rd as Map<String, dynamic>)['daysOfWeek']?.toString() ?? '')
                              .join()
                              .replaceAll('-', '')
                              .length;
                            
                            final String commencedAtString = historicRoute['commencedAt'].toString();
                            final DateTime commencedAt = DateTime.parse(commencedAtString);
                            final String formattedCommencedAt = DateFormat('dd.MM.yyyy.').format(commencedAt);

                            final String terminatedAtString = historicRoute['terminatedAt'].toString();
                            final DateTime terminatedAt = DateTime.parse(terminatedAtString);
                            final String formattedTerminatedAt = DateFormat('dd.MM.yyyy.').format(terminatedAt);

                            return DataRow(
                              cells: <DataCell>[
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: Center(
                                      child: Text(
                                        (historicRoute['origin'] as Map<String, dynamic>)['name'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 110,
                                    child: Center(
                                      child: Text(
                                        (historicRoute['destination'] as Map<String, dynamic>)['name'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
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
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 120,
                                    child: Center(
                                      child: Text(
                                        formattedTerminatedAt,
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
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
