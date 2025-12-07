import 'package:aerosense/api.dart';
import 'package:aerosense/auth.dart';
import 'package:aerosense/main.dart';
import 'package:aerosense/model/menu_item.dart';
import 'package:aerosense/widgets/footer.dart';
import 'package:aerosense/widgets/header.dart';
import 'package:aerosense/widgets/side_menu.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String selected = MenuItem.home;

  final TextEditingController _oldPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _repeatPassword = TextEditingController();

  final String firstName = Auth.instance.firstName;
  final String lastName = Auth.instance.lastName;
  final String roleName = Auth.instance.roleName;

  bool _loading = false;
  bool _oldPasswordError = false;
  bool _newPasswordError = false;
  bool _repeatPasswordError = false;
  String? _errorMessage;
  String? _successMessage;

  void _autoClearMessages() {
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = null;
        _successMessage = null;
      });
    });
  }

  Future<void> _changePassword() async {
    setState(() {
      _oldPasswordError = _oldPassword.text.trim().isEmpty;
      _newPasswordError = _newPassword.text.trim().isEmpty;
      _repeatPasswordError = _repeatPassword.text.trim().isEmpty;
    });

    if (_oldPasswordError || _newPasswordError || _repeatPasswordError) {
      return;
    }

    if (_newPassword.text.trim() != _repeatPassword.text.trim()) {
      setState(() {
        _errorMessage = 'New password and repeated password must match.';
      });

      _autoClearMessages();

      return;
    }

    setState(() => _loading = true);

    try {
      await Api.instance.put(
        '/api/user/change-password',
        <String, dynamic>{
          'oldPassword': _oldPassword.text.trim(),
          'newPassword': _newPassword.text.trim()
        }
      );

      setState(() {
        _successMessage = 'Password successfully changed';
      });

      _autoClearMessages();

      _oldPassword.clear();
      _newPassword.clear();
      _repeatPassword.clear();
    } 
    catch (e) {
      //
    }
    finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _repeatPassword.dispose();
    super.dispose();
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

            case MenuItem.home:
              navigatorKey.currentState?.pushReplacementNamed('/home');

            case MenuItem.aircraft:
              navigatorKey.currentState?.pushReplacementNamed('/aircraft');
            
            case MenuItem.routes:
              navigatorKey.currentState?.pushReplacementNamed('/routes');
            
            case MenuItem.maintenance:
              navigatorKey.currentState?.pushReplacementNamed('/maintenance');
          }
        },
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SafeArea(
          minimum: const EdgeInsets.only(top: 16),
          child: Column(
            children: <Widget>[
              Text(
                'Welcome $firstName $lastName!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                roleName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 40),

              CircleAvatar(
                radius: 150,
                backgroundColor: Colors.grey[300],
                child: const Icon(
                  Icons.person,
                  size: 150,
                  color: Colors.white,
                ),
              ),
              const Spacer(),

              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'Want to change your password?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Safe password equals safe app!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 30),

                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
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
                                controller: _oldPassword,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Old password',
                                  labelStyle: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  border: const OutlineInputBorder(),
                                  errorText: _oldPasswordError ? 'Old password is required' : null,
                                ),
                                onChanged: (String value) {
                                  setState(() {
                                    _oldPasswordError = value.trim().isEmpty;
                                  });
                                },
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
                                    borderSide: BorderSide(width: 2)
                                  ),
                                )
                              ),
                              child: TextField(
                                controller: _newPassword,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'New password',
                                  labelStyle: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  border: const OutlineInputBorder(),
                                  errorText: _newPasswordError ? 'New password is required' : null,
                                ),
                                onChanged: (String value) {
                                  setState(() {
                                    _newPasswordError = value.trim().isEmpty;
                                  });
                                },
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
                                    borderSide: BorderSide(width: 2)
                                  ),
                                )
                              ),
                              child: TextField(
                                controller: _repeatPassword,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Repeat new password',
                                  labelStyle: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  border: const OutlineInputBorder(),
                                  errorText: _repeatPasswordError ? 'Repeat password is required' : null,
                                ),
                                onChanged: (String value) {
                                  setState(() {
                                    _repeatPasswordError = value.trim().isEmpty;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            if (_errorMessage != null) ...<Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],

                            if (_successMessage != null) ...<Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  _successMessage!,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],

                            const SizedBox(height: 8),

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
                                    onPressed: _loading ? null : _changePassword,
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
                                      'Change password',
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
                    ],
                  )
                ),
              ),
              const Spacer()
            ],
          ),
        ),
      ),
    );
  }
}
