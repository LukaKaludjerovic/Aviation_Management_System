import 'package:aerosense/pages/aircraft/active_aircraft.dart';
import 'package:aerosense/pages/aircraft/historic_aircraft.dart';
import 'package:aerosense/pages/home.dart';
import 'package:aerosense/pages/login.dart';
import 'package:aerosense/pages/maintenance/historic_maintenance.dart';
import 'package:aerosense/pages/maintenance/pending_maintenance.dart';
import 'package:aerosense/pages/routes/current_routes.dart';
import 'package:aerosense/pages/routes/historic_routes.dart';
import 'package:aerosense/pages/settings/aircraft_types.dart';
import 'package:aerosense/pages/settings/airports.dart';
import 'package:aerosense/pages/settings/roles.dart';
import 'package:aerosense/pages/settings/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  runApp(const MainApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Aviation Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true
      ),
      initialRoute: '/login',
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => const Login(),
        '/home': (BuildContext context) => const Home(),
        '/users': (BuildContext context) => const Users(),
        '/roles': (BuildContext context) => const Roles(),
        '/aircraft-types': (BuildContext context) => const AircraftTypes(),
        '/airports': (BuildContext context) => const Airports(),
        '/active-aircraft': (BuildContext context) => const ActiveAircraft(),
        '/historic-aircraft': (BuildContext context) => const HistoricAircraft(),
        '/current-routes': (BuildContext context) => const CurrentRoutes(),
        '/historic-routes': (BuildContext context) => const HistoricRoutes(),
        '/pending-maintenance': (BuildContext context) => const PendingMaintenance(),
        '/historic-maintenance': (BuildContext context) => const HistoricMaintenance()
      },
    );
  }
}
