import 'package:aerosense/api.dart';
import 'package:aerosense/auth.dart';
import 'package:aerosense/main.dart';
import 'package:aerosense/widgets/header.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);

    try {
      final Map<String, dynamic> response = await Api.instance.post(
        '/api/auth/login',
        <String, dynamic>{
          'username': _username.text.trim(),
          'password': _password.text.trim()
        }
      ) as Map<String, dynamic>;

      final List<dynamic> permissionsJson = response['permissions'] as List<dynamic>;
      final List<String> permissions = permissionsJson.map((dynamic p) => p.toString()).toList();
      Auth.instance.permissions = permissions;

      final Map<String, dynamic> user = response['user'] as Map<String, dynamic>;
      final Map<String, dynamic> role = user['role'] as Map<String, dynamic>;

      Auth.instance.token = response['token'] as String;
      Auth.instance.firstName = user['firstName'] as String;
      Auth.instance.lastName = user['lastName'] as String;
      Auth.instance.userName = user['userName'] as String;
      Auth.instance.roleName = role['name'] as String;
      Api.instance.token = response['token'] as String;

      navigatorKey.currentState?.pushReplacementNamed('/home');
    } 
    catch (e) {
      //
    }
    finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Stack(
        children: <Widget>[
          const Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              minimum: EdgeInsets.only(top: 16),
              child: Column(
                children: <Widget>[
                  Text(
                    'Welcome to AeroSense',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'New generation AMOS application',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
      
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Please log in',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 30),
                          
                    Theme(
                      data: Theme.of(context).copyWith(
                        inputDecorationTheme: const InputDecorationTheme(
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2)
                          ),
                        )
                      ),
                      child: TextField(
                        controller: _username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                          
                    Theme(
                      data: Theme.of(context).copyWith(
                        inputDecorationTheme: const InputDecorationTheme(
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                            ),
                          ),
                        )
                      ),
                      child: TextField(
                        controller: _password,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.black
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey
                            ),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                          
                    const SizedBox(
                      height: 24
                    ),
                          
                    if (_loading) ...<Widget>[
                      CircularProgressIndicator(
                        color: Colors.lightBlue[300]
                      )
                    ] 
                    else ...<Widget>[
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 250
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return Colors.lightBlue[300]!;
                                }
                                else if (states.contains(WidgetState.disabled)) {
                                  return Colors.grey[300]!;
                                }
                                return Colors.grey[300]!;
                              }),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                  vertical: 16
                                ),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)
                                ),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                              ),
                            )),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ),
          ),

          const Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Text(
                'Having troubles?\nPlease contact support@aerosense.com',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}
