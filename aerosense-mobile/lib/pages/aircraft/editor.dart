import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Editor extends StatefulWidget {
  const Editor({
    super.key,
    required this.aircraft,
    required this.types,
    required this.onSave,
    this.onDelete,
    this.onRetire
  });
  
  final Map<String, dynamic> aircraft;
  final List<Map<String, dynamic>> types;
  final Future<void> Function(Map<String, dynamic> updated) onSave;
  final Future<void> Function()? onDelete;
  final Future<void> Function()? onRetire;

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late TextEditingController _msn;
  late TextEditingController _registration;
  late Map<String, dynamic> _selectedType;
  late TextEditingController _configuration;
  late TextEditingController _firstFlight;
  late TextEditingController _eisDate;

  DateTime? _selectedFirstFlight;
  DateTime? _selectedEisDate;

  bool _msnError = false;
  bool _registrationError = false;
  bool _configurationError = false;
  bool _firstFlightError = false;
  bool _eisDateError = false;

  @override
  void initState() {
    super.initState();
    _msn = TextEditingController(text: ((widget.aircraft['msn'] ?? 0) as int).toString());
    _registration = TextEditingController(text: (widget.aircraft['registration'] ?? '') as String);
    _configuration = TextEditingController(text: (widget.aircraft['configuration'] ?? '').toString());

    if (widget.aircraft['type'] != null) {
      _selectedType = widget.types.firstWhere(
        (Map<String, dynamic> t) => t['id'] == (widget.aircraft['type'] as Map<String, dynamic>)['id'],
        orElse: () => widget.types.first,
      );
    }
    else {
      _selectedType = widget.types.first;
    }

    if (widget.aircraft['firstFlight'] != null) {
      _selectedFirstFlight = DateTime.parse(widget.aircraft['firstFlight'] as String);
      _firstFlight = TextEditingController(
        text: DateFormat('dd.MM.yyyy.').format(_selectedFirstFlight!),
      );
    } else {
      _firstFlight = TextEditingController();
    }

    if (widget.aircraft['eisDate'] != null) {
      _selectedEisDate = DateTime.parse(widget.aircraft['eisDate'] as String);
      _eisDate = TextEditingController(
        text: DateFormat('dd.MM.yyyy.').format(_selectedEisDate!),
      );
    } else {
      _eisDate = TextEditingController();
    }
  }

  @override
  void dispose() {
    _msn.dispose();
    _registration.dispose();
    _configuration.dispose();
    _firstFlight.dispose();
    _eisDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNew = (widget.aircraft['id'] == 0);

    return AlertDialog(
      title: isNew ? 
        const Text(
          'New aircraft',
          style: TextStyle(fontWeight: FontWeight.bold)
        ) : 
        const Text(
          'Edit aircraft',
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
                controller: _msn,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Aircraft MSN',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _msnError ? 'MSN is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _msnError = int.tryParse(value) == null;
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
                controller: _registration,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Aircraft registration',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _registrationError ? 'Registration is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _registrationError = value.trim().isEmpty;
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
                ),
              ),
              child: DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Aircraft type',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  border: OutlineInputBorder(),
                ),
                iconEnabledColor: Colors.black,
                selectedItemBuilder: (BuildContext context) {
                  return widget.types.map((Map<String, dynamic> type) {
                    return Text(
                      type['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  }).toList();
                },
                items: widget.types.map((Map<String, dynamic> type) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: type,
                    child: Text(type['name'] as String),
                  );
                }).toList(),
                onChanged: (Map<String, dynamic>? value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
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
                controller: _configuration,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Aircraft Configuration',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _configurationError ? 'Configuration is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _configurationError = value.trim().isEmpty;
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
                controller: _firstFlight,
                readOnly: true,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'First Flight Date',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _firstFlightError ? 'First Flight Date is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _firstFlightError = value.trim().isEmpty;
                  });
                },
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedFirstFlight ?? DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now().add(const Duration(days: 5 * 365)),
                    helpText: 'Select First Flight Date',
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Colors.lightBlue[300]!,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ),
                        ),
                        child: child!
                      );
                    },
                  );

                  if (picked != null) {
                    setState(() {
                      _selectedFirstFlight = picked;
                      _firstFlight.text = DateFormat('dd.MM.yyyy').format(picked);
                      _firstFlightError = false;
                    });
                  }
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
                controller: _eisDate,
                readOnly: true,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Entry into Service Date',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _eisDateError ? 'Entry into Service Date is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _eisDateError = value.trim().isEmpty;
                  });
                },
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedEisDate ?? DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now().add(const Duration(days: 5 * 365)),
                    helpText: 'Select Entry into Service Date',
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Colors.lightBlue[300]!,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ),
                        ),
                        child: child!
                      );
                    },
                  );

                  if (picked != null) {
                    setState(() {
                      _selectedEisDate = picked;
                      _eisDate.text = DateFormat('dd.MM.yyyy').format(picked);
                      _eisDateError = false;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
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
            
                if (!isNew && widget.onRetire != null)
                  TextButton(
                    onPressed: () async {
                      await widget.onRetire!();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'Retire',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 1),
                ],
            ),
            
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
                    final int? parsedMSN = int.tryParse(_msn.text);

                    setState(() {
                      _msnError = parsedMSN == null;
                      _registrationError = _registration.text.trim().isEmpty;
                      _configurationError = _configuration.text.trim().isEmpty;
                      _firstFlightError = _selectedFirstFlight == null;
                      _eisDateError = _selectedEisDate == null;
                    });

                    if (_msnError || _registrationError || _configurationError || _firstFlightError || _eisDateError) {
                      return;
                    }

                    final Map<String, dynamic> updated = <String, dynamic>{
                      'id': widget.aircraft['id'],
                      'msn': parsedMSN,
                      'registration': _registration.text.trim(),
                      'type': _selectedType,
                      'configuration': _configuration.text.trim(),
                      'firstFlight': _selectedFirstFlight!.toIso8601String(),
                      'eisDate': _selectedEisDate!.toIso8601String(),
                      'wfsDate': widget.aircraft['wfsDate']
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
