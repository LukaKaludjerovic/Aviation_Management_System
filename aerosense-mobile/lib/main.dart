import 'package:aerosense/pages/home.dart';
import 'package:aerosense/pages/login.dart';
import 'package:aerosense/pages/settings/profiles.dart';
import 'package:aerosense/pages/settings/roles.dart';
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
        '/profiles': (BuildContext context) => const Profiles(),
        '/roles': (BuildContext context) => const Roles()
      },
    );
  }
}
