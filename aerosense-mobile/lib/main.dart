import 'package:aerosense/pages/aircraft/aircraft.dart';
import 'package:aerosense/pages/home.dart';
import 'package:aerosense/pages/login.dart';
import 'package:aerosense/pages/maintenance/maintenance.dart';
import 'package:aerosense/pages/routes/routes.dart';
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
        '/aircraft': (BuildContext context) => const Aircraft(),
        '/routes': (BuildContext context) => const Routes(),
        '/maintenance': (BuildContext context) => const Maintenance()
      },
    );
  }
}
