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

class PendingMaintenance extends StatefulWidget {
  const PendingMaintenance({super.key});

  @override
  State<PendingMaintenance> createState() => _PendingMaintenanceState();
}

class _PendingMaintenanceState extends State<PendingMaintenance> {
  String selected = MenuItem.pendingMaintenance;

  final ScrollController _pendingMaintenanceController = ScrollController();

  List<Map<String, dynamic>> _pendingMaintenance = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _fetchPendingMaintenance();
  }

  Future<void> _fetchPendingMaintenance() async {
    final List<dynamic> response = await Api.instance.get('/api/maintenance/pending') as List<dynamic>;

    setState(() {
      _pendingMaintenance = response
        .map((dynamic e) => e as Map<String, dynamic>)
        .toList();
    });
  }

  void _openMaintenanceDialog(Map<String, dynamic> aircraft) {}

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
      body: _pendingMaintenance.isEmpty
        ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[300]))
        : Scrollbar(
          controller: _pendingMaintenanceController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _pendingMaintenanceController,
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
                          'Pending Maintenance',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (Auth.instance.allowed(Permission.modifyPendingMaintenance))
                          IconButton(
                            onPressed: () {
                              _openMaintenanceDialog(<String, dynamic>{'id': 0});
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
                                    'Expected completition',
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
                          rows: _pendingMaintenance.map((Map<String, dynamic> pendingMaintenance) {
                            final List<String> descriptionList = pendingMaintenance['description']
                              .toString()
                              .split(',')
                              .toList();
                            
                            final String scheduledForString = pendingMaintenance['scheduledFor'].toString();
                            final DateTime scheduledFor = DateTime.parse(scheduledForString);
                            final String formattedScheduledFor = DateFormat('dd.MM.yyyy.').format(scheduledFor);

                            final String expectedCompletitionString = pendingMaintenance['expectedCompletitionDate'].toString();
                            final DateTime expectedCompletition = DateTime.parse(expectedCompletitionString);
                            final String formattedExpectedCompletition = DateFormat('dd.MM.yyyy.').format(expectedCompletition);

                            return DataRow(
                              cells: <DataCell>[
                                DataCell(
                                  SizedBox(
                                    width: 125,
                                    child: Center(
                                      child: Text(
                                        (pendingMaintenance['aircraft'] as Map<String, dynamic>)['registration'].toString(),
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.modifyPendingMaintenance)) {
                                      _openMaintenanceDialog(pendingMaintenance);
                                    }
                                  }
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
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.modifyPendingMaintenance)) {
                                      _openMaintenanceDialog(pendingMaintenance);
                                    }
                                  }
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
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.modifyPendingMaintenance)) {
                                      _openMaintenanceDialog(pendingMaintenance);
                                    }
                                  }
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 150,
                                    child: Center(
                                      child: Text(
                                        formattedExpectedCompletition,
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: (() {
                                            if (expectedCompletition.isBefore(DateTime.now())){
                                              return Colors.red;
                                            }

                                            return Colors.black;
                                          })()
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  onTap: () { 
                                    if (Auth.instance.allowed(Permission.modifyPendingMaintenance)) {
                                      _openMaintenanceDialog(pendingMaintenance);
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
