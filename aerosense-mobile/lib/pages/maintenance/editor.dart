import 'package:aerosense/model/maintenance_work.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Editor extends StatefulWidget {
  const Editor({
    super.key,
    required this.maintenance,
    required this.aircraft,
    required this.onSave,
    this.onDelete,
    this.onComplete
  });
  
  final Map<String, dynamic> maintenance;
  final List<Map<String, dynamic>> aircraft;
  final Future<void> Function(Map<String, dynamic> updated) onSave;
  final Future<void> Function()? onDelete;
  final Future<void> Function()? onComplete;

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late Map<String, dynamic> _selectedAircraft;
  late List<String> _description;
  late TextEditingController _scheduledFor;
  late TextEditingController _expectedCompletitionDate;

  DateTime? _selectedScheduledFor;
  DateTime? _selectedExpectedCompletitionDate;

  bool _descriptionError = false;
  bool _scheduledForError = false;
  bool _expectedCompletitionDateError = false;

  final ScrollController _descriptionController = ScrollController();

  @override
  void initState() {
    super.initState();
    _description = (widget.maintenance['description'] ?? '')
      .toString()
      .split(',')
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toList();

    if (widget.maintenance['aircraft'] != null) {
      _selectedAircraft = widget.aircraft.firstWhere(
        (Map<String, dynamic> a) => a['id'] == (widget.maintenance['aircraft'] as Map<String, dynamic>)['id'],
        orElse: () => widget.aircraft.first,
      );
    }
    else {
      _selectedAircraft = widget.aircraft.first;
    }

    if (widget.maintenance['scheduledFor'] != null) {
      _selectedScheduledFor = DateTime.parse(widget.maintenance['scheduledFor'] as String);
      _scheduledFor = TextEditingController(
        text: DateFormat('dd.MM.yyyy.').format(_selectedScheduledFor!),
      );
    } else {
      _scheduledFor = TextEditingController();
    }

    if (widget.maintenance['expectedCompletitionDate'] != null) {
      _selectedExpectedCompletitionDate = DateTime.parse(widget.maintenance['expectedCompletitionDate'] as String);
      _expectedCompletitionDate = TextEditingController(
        text: DateFormat('dd.MM.yyyy.').format(_selectedExpectedCompletitionDate!),
      );
    } else {
      _expectedCompletitionDate = TextEditingController();
    }
  }

  @override
  void dispose() {
    _scheduledFor.dispose();
    _expectedCompletitionDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNew = (widget.maintenance['id'] == 0);

    return AlertDialog(
      title: isNew ? 
        const Text(
          'New maintenance',
          style: TextStyle(fontWeight: FontWeight.bold)
        ) : 
        const Text(
          'Edit maintenance',
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
                ),
              ),
              child: DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedAircraft,
                decoration: const InputDecoration(
                  labelText: 'Aircraft',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  border: OutlineInputBorder(),
                ),
                iconEnabledColor: Colors.black,
                selectedItemBuilder: (BuildContext context) {
                  return widget.aircraft.map((Map<String, dynamic> aircraft) {
                    return Text(
                      aircraft['registration'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  }).toList();
                },
                items: widget.aircraft.map((Map<String, dynamic> aircraft) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: aircraft,
                    child: Text(aircraft['registration'] as String),
                  );
                }).toList(),
                onChanged: (Map<String, dynamic>? value) {
                  if (value != null) {
                    setState(() {
                      _selectedAircraft = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Description of work',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 500,
              child: Scrollbar(
                controller: _descriptionController,
                thumbVisibility: true,
                child: ListView(
                  controller: _descriptionController,
                  children: MaintenanceWork.all.map((String work) {
                    final bool checked = _description.contains(work);

                    return CheckboxListTile(
                      title: Text(work),
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
                            _description.add(work);

                            if (work == 'Corrosion Treatment' || work == 'Cabin Reconfiguration') {
                              _description.add('A Check');
                            }
                            if (work == 'Landing Gear Replacement') {
                              _description.add('D Check');
                            }
                          } else {
                            _description.remove(work);

                            if (work == 'A Check') {
                              _description.remove('Corrosion Treatment');
                              _description.remove('Cabin Reconfiguration');
                            }
                            if (work == 'D Check') {
                              _description.remove('Landing Gear Replacement');
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
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
                cursorColor: Colors.black,
                controller: _scheduledFor,
                readOnly: true,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Scheduled For',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _scheduledForError ? 'Scheduled For Date is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _scheduledForError = value.trim().isEmpty;
                  });
                },
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedScheduledFor ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 5 * 365)),
                    helpText: 'Select Scheduled For Date',
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
                      _selectedScheduledFor = picked;
                      _scheduledFor.text = DateFormat('dd.MM.yyyy').format(picked);
                      _scheduledForError = false;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            if (!isNew) ...<Widget>[
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
                  controller: _expectedCompletitionDate,
                  readOnly: true,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                  decoration: InputDecoration(
                    labelText: 'Expected Completition Date',
                    labelStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey
                      ),
                    ),
                    border: const OutlineInputBorder(),
                    errorText: _expectedCompletitionDateError ? 'Expected Completition Date is required' : null
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _expectedCompletitionDateError = value.trim().isEmpty;
                    });
                  },
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedExpectedCompletitionDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 5 * 365)),
                      helpText: 'Select Expected Completition Date',
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
                        _selectedExpectedCompletitionDate = picked;
                        _expectedCompletitionDate.text = DateFormat('dd.MM.yyyy').format(picked);
                        _expectedCompletitionDateError = false;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16)
            ],

            if (isNew)
              const Center(
                child: Text(
                  'Expected Completition Date will be automatically estimated based on previous maintenance of same parts',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            
            if (!isNew) 
              const Center(
                child: Text(
                  'Expected Completition Date has been automatically estimated, please modify it if it is not correct',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            
            if (!isNew) 
              const Center(
                child: Text(
                  'If you change Expected Completition Date manually, prediction will not work nevertheless you changed criteria',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
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
            
                if (!isNew && widget.onComplete != null && _selectedScheduledFor!.isBefore(DateTime.now()))
                  TextButton(
                    onPressed: () async {
                      await widget.onComplete!();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'Complete',
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
                    setState(() {
                      _descriptionError = _description.join(',').trim().isEmpty;
                      _scheduledForError = _scheduledFor.text.trim().isEmpty;
                      _expectedCompletitionDateError = _expectedCompletitionDate.text.trim().isEmpty && !isNew;
                    });

                    if (_descriptionError || _scheduledForError || _expectedCompletitionDateError) {
                      return;
                    }

                    final Map<String, dynamic> updated = <String, dynamic>{
                      'id': widget.maintenance['id'],
                      'aircraft': _selectedAircraft,
                      'description': _description.join(',').trim(),
                      'scheduledFor': _selectedScheduledFor!.toIso8601String(),
                      'expectedCompletitionDate': _selectedExpectedCompletitionDate?.toIso8601String(),
                      'completedAt': widget.maintenance['completedAt']
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
