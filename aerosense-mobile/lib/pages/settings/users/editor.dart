import 'package:aerosense/model/permission.dart';
import 'package:flutter/material.dart';

class Editor extends StatefulWidget {
  const Editor({
    super.key,
    required this.user,
    required this.roles,
    required this.onSave,
    this.onDelete,
  });
  
  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> roles;
  final Future<void> Function(Map<String, dynamic> updated) onSave;
  final Future<void> Function()? onDelete;

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late TextEditingController _firstName;
  late TextEditingController _lastName;
  late TextEditingController _userName;
  late TextEditingController _password;
  late Map<String, dynamic> _selectedRole;
  late List<String> _allowedFunctions;
  late List<String> _forbiddenFunctions;

  final ScrollController _allowedFunctionsController = ScrollController();
  final ScrollController _forbiddenFunctionsController = ScrollController();

  bool _firstNameError = false;
  bool _lastNameError = false;
  bool _userNameError = false;
  bool _passwordError = false;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: (widget.user['firstName'] ?? '') as String);
    _lastName = TextEditingController(text: (widget.user['lastName'] ?? '') as String);
    _userName = TextEditingController(text: (widget.user['userName'] ?? '') as String);
    _password = TextEditingController(text: '');
    
    if (widget.user['role'] != null) {
      _selectedRole = widget.roles.firstWhere(
        (Map<String, dynamic> r) => r['id'] == (widget.user['role'] as Map<String, dynamic>)['id'],
        orElse: () => widget.roles.first,
      );
    }
    else {
      _selectedRole = widget.roles.first;
    }

    _allowedFunctions = (widget.user['allowedFunctions'] ?? '')
      .toString()
      .split(',')
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toList();

    _forbiddenFunctions = (widget.user['forbiddenFunctions'] ?? '')
      .toString()
      .split(',')
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toList();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _userName.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNew = (widget.user['id'] == 0);

    return AlertDialog(
      title: isNew ? 
        const Text(
          'New user',
          style: TextStyle(fontWeight: FontWeight.bold),
        ) : 
        const Text(
          'Edit user',
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
                cursorColor: Colors.black,
                controller: _firstName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'First name',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _firstNameError ? 'First name is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _firstNameError = value.trim().isEmpty;
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
                    borderSide: BorderSide(
                      width: 2,
                    ),
                  ),
                )
              ),
              child: TextField(
                cursorColor: Colors.black,
                controller: _lastName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Last name',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _lastNameError ? 'Last name is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _lastNameError = value.trim().isEmpty;
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
                    borderSide: BorderSide(
                      width: 2,
                    ),
                  ),
                )
              ),
              child: TextField(
                cursorColor: Colors.black,
                controller: _userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _userNameError ? 'Username is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _userNameError = value.trim().isEmpty;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            if (isNew) ...<Widget>[
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
                  cursorColor: Colors.black,
                  controller: _password,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey
                      ),
                    ),
                    border: const OutlineInputBorder(),
                    errorText: _passwordError ? 'Password is required' : null
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _passwordError = value.trim().isEmpty;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'Role',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

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
                ),
              ),
              child: DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Select role',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  border: OutlineInputBorder(),
                ),
                iconEnabledColor: Colors.black,
                selectedItemBuilder: (BuildContext context) {
                  return widget.roles.map((Map<String, dynamic> role) {
                    return Text(
                      role['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  }).toList();
                },
                items: widget.roles.map((Map<String, dynamic> role) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: role,
                    child: Text(role['name'] as String),
                  );
                }).toList(),
                onChanged: (Map<String, dynamic>? value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Allowed Functions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 150,
              child: Scrollbar(
                thumbVisibility: true,
                controller: _allowedFunctionsController,
                child: ListView(
                  controller: _allowedFunctionsController,
                  children: Permission.all.map((String func) {
                    final bool checked = _allowedFunctions.contains(func);

                    return CheckboxListTile(
                      title: Text(func),
                      value: checked,
                      fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.black;
                        }
                        return Colors.transparent;
                      }),
                      onChanged: (bool? val) {
                        setState(() {
                          if (val ?? false) {
                            _allowedFunctions.add(func);
                          } else {
                            _allowedFunctions.remove(func);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Forbidden Functions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 150,
              child: Scrollbar(
                thumbVisibility: true,
                controller: _forbiddenFunctionsController,
                child: ListView(
                  controller: _forbiddenFunctionsController,
                  children: Permission.all.map((String func) {
                    final bool checked = _forbiddenFunctions.contains(func);

                    return CheckboxListTile(
                      title: Text(func),
                      value: checked,
                      fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.black;
                        }
                        return Colors.transparent;
                      }),
                      onChanged: (bool? val) {
                        setState(() {
                          if (val ?? false) {
                            _forbiddenFunctions.add(func);
                          } else {
                            _forbiddenFunctions.remove(func);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ]
        )
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (!isNew && widget.onDelete != null)
              TextButton(
                onPressed: () async {
                  await widget.onDelete!();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              )
            else
              const SizedBox(width: 1),

            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _firstNameError = _firstName.text.trim().isEmpty;
                      _lastNameError = _lastName.text.trim().isEmpty;
                      _userNameError = _userName.text.trim().isEmpty;
                      _passwordError = _password.text.trim().isEmpty && widget.user['id'] == 0;
                    });

                    if (_firstNameError || _lastNameError || _userNameError || _passwordError) {
                      return;
                    }

                    final Map<String, dynamic> updated = <String, dynamic>{
                      'id': widget.user['id'],
                      'firstName': _firstName.text.trim(),
                      'lastName': _lastName.text.trim(),
                      'userName': _userName.text.trim(),
                      'password': _password.text.trim(),
                      'role': _selectedRole,
                      'allowedFunctions': _allowedFunctions.join(','),
                      'forbiddenFunctions': _forbiddenFunctions.join(',')
                    };
                    await widget.onSave(updated);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
