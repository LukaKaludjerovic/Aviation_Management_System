import 'package:aerosense/api.dart';
import 'package:aerosense/main.dart';
import 'package:aerosense/model/menu_item.dart';
import 'package:aerosense/widgets/footer.dart';
import 'package:aerosense/widgets/header.dart';
import 'package:aerosense/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoricMaintenance extends StatefulWidget {
  const HistoricMaintenance({super.key});

  @override
  State<HistoricMaintenance> createState() => _HistoricMaintenanceState();
}

class _HistoricMaintenanceState extends State<HistoricMaintenance> {
  String selected = MenuItem.historicMaintenance;

  final ScrollController _historicMaintenanceController = ScrollController();

  List<Map<String, dynamic>> _historicMaintenance = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _fetchHistoricMaintenance();
  }

  Future<void> _fetchHistoricMaintenance() async {
    final List<dynamic> response = await Api.instance.get('/api/maintenance/completed') as List<dynamic>;

    setState(() {
      _historicMaintenance = response
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
      body: _historicMaintenance.isEmpty
        ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[300]))
        : Scrollbar(
          controller: _historicMaintenanceController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _historicMaintenanceController,
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
                          'Historic Maintenance',
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
                                width: 125,
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
                                width: 150,
                                child: Center(
                                  child: Text(
                                    'Description',
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
                                width: 150,
                                child: Center(
                                  child: Text(
                                    'Scheduled for',
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
                                width: 150,
                                child: Center(
                                  child: Text(
                                    'Completed at',
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
                          rows: _historicMaintenance.map((Map<String, dynamic> historicMaintenance) {
                            final List<String> descriptionList = historicMaintenance['description']
                              .toString()
                              .split(',')
                              .toList();

                            final String scheduledForString = historicMaintenance['scheduledFor'].toString();
                            final DateTime scheduledFor = DateTime.parse(scheduledForString);
                            final String formattedScheduledFor = DateFormat('dd.MM.yyyy.').format(scheduledFor);

                            final String completedAtString = historicMaintenance['completedAt'].toString();
                            final DateTime completedAt = DateTime.parse(completedAtString);
                            final String formattedCompletedAt = DateFormat('dd.MM.yyyy.').format(completedAt);

                            return DataRow(
                              cells: <DataCell>[
                                DataCell(
                                  SizedBox(
                                    width: 125,
                                    child: Center(
                                      child: Text(
                                        (historicMaintenance['aircraft'] as Map<String, dynamic>)['registration'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 150,
                                    child: Center(
                                      child: Column(
                                        children: descriptionList.map((String desc) => 
                                          Text(
                                            desc.trim(),
                                            softWrap: true,
                                            style: const TextStyle(fontSize: 16),
                                            textAlign: TextAlign.center
                                          )
                                        ).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 150,
                                    child: Center(
                                      child: Text(
                                        formattedScheduledFor,
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 150,
                                    child: Center(
                                      child: Text(
                                        formattedCompletedAt,
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
