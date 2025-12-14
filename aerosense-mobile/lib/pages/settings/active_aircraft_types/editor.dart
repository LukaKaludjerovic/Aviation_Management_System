import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Editor extends StatefulWidget {
  const Editor({
    super.key,
    required this.aircraftType,
    required this.onSave,
    this.onDelete,
  });
  
  final Map<String, dynamic> aircraftType;
  final Future<void> Function(Map<String, dynamic> updated) onSave;
  final Future<void> Function()? onDelete;

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late TextEditingController _name;
  late TextEditingController _code;
  late TextEditingController _range;
  late TextEditingController _eisDate;

  DateTime? _selectedEisDate;

  bool _nameError = false;
  bool _codeError = false;
  bool _rangeError = false;
  bool _eisDateError = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: (widget.aircraftType['name'] ?? '') as String);
    _code = TextEditingController(text: (widget.aircraftType['code'] ?? '') as String);
    _range = TextEditingController(text: ((widget.aircraftType['range'] ?? 0) as int).toString());

    if (widget.aircraftType['eisDate'] != null) {
      _selectedEisDate = DateTime.parse(widget.aircraftType['eisDate'] as String);
      _eisDate = TextEditingController(
        text: DateFormat('dd.MM.yyyy.').format(_selectedEisDate!),
      );
    } else {
      _eisDate = TextEditingController();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _range.dispose();
    _eisDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNew = (widget.aircraftType['id'] == 0);

    return AlertDialog(
      title: isNew ? 
        const Text(
          'New aircraft type',
          style: TextStyle(fontWeight: FontWeight.bold)
        ) : 
        const Text(
          'Edit aircraft type',
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
                controller: _name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Aircraft Type Name',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _nameError ? 'Aircraft Type Name is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _nameError = value.trim().isEmpty;
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
                controller: _code,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Aircraft Type Code',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _codeError ? 'Aircraft Type Code is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _codeError = value.trim().isEmpty;
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
                controller: _range,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Aircraft Type Range (km)',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _rangeError ? 'Aircraft Type Range is a required as number' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _rangeError = int.tryParse(value) == null;
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
                          colorScheme: const ColorScheme.light(
                            primary: Colors.black,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
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
                    final int? parsedRange = int.tryParse(_range.text);

                    setState(() {
                      _nameError = _name.text.trim().isEmpty;
                      _codeError = _code.text.trim().isEmpty;
                      _rangeError = parsedRange == null;
                      _eisDateError = _selectedEisDate == null;
                    });

                    if (_nameError || _codeError || _rangeError || _eisDateError) {
                      return;
                    }

                    final Map<String, dynamic> updated = <String, dynamic>{
                      'id': widget.aircraftType['id'],
                      'name': _name.text.trim(),
                      'code': _code.text.trim(),
                      'range': parsedRange,
                      'eisDate': _selectedEisDate!.toIso8601String()
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
