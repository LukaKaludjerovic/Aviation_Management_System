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
      final response = await Api.instance.post(
        "/api/auth/login",
        {
          "username": _username.text.trim(),
          "password": _password.text.trim()
        }
      );

      final permissions = response["permissions"];
      if (permissions is List) {
        Auth.instance.setPermissions(permissions.map((p) => p.toString()).toList());
      }

      Auth.instance.setToken(response["token"]);
      Auth.instance.setFirstName(response["user"]["firstName"]);
      Auth.instance.setLastName(response["user"]["lastName"]);
      Auth.instance.setUserName(response["user"]["userName"]);
      Auth.instance.setRoleName(response["user"]["role"]["name"]);
      Api.instance.setToken(response["token"]);

      navigatorKey.currentState?.pushReplacementNamed("/home");
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
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              minimum: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "Welcome to AeroSense",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "New generation AMOS application",
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
                  children: [
                    const Text(
                      "Please log in",
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
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                        )
                      ),
                      child: TextField(
                        controller: _username,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: "Username",
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
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                        )
                      ),
                      child: TextField(
                        controller: _password,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                          
                    const SizedBox(height: 24),
                          
                    if (_loading) ...[
                      CircularProgressIndicator(color: Colors.lightBlue[300])
                    ] else ...[
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 250),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return Colors.lightBlue[300]!;
                                } else if (states.contains(WidgetState.disabled)) {
                                  return Colors.grey[300]!;
                                }
                                return Colors.grey[300]!;
                              }),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 16),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            child: const Text(
                              "Login",
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

          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Text(
                "Having troubles?\nPlease contact support@aerosense.com",
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