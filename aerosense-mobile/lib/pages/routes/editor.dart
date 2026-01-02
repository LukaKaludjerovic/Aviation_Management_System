import 'package:aerosense/pages/routes/route_detail_editor.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Editor extends StatefulWidget {
  const Editor({
    super.key,
    required this.route,
    required this.airports,
    required this.aircraftTypes,
    required this.onSave,
    this.onDelete,
    this.onTerminate
  });
  
  final Map<String, dynamic> route;
  final List<Map<String, dynamic>> airports;
  final List<Map<String, dynamic>> aircraftTypes;
  final Future<void> Function(Map<String, dynamic> updated) onSave;
  final Future<void> Function()? onDelete;
  final Future<void> Function()? onTerminate;

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late Map<String, dynamic> _selectedOrigin;
  late Map<String, dynamic> _selectedDestination;
  late TextEditingController _blockTime;
  late List<Map<String, dynamic>> _routeDetails;
  late TextEditingController _commencedAt;

  DateTime? _selectedCommencedAt;

  bool _blockTimeError = false;
  bool _commencedAtError = false;

  @override
  void initState() {
    super.initState();
    _blockTime = TextEditingController(text: ((widget.route['blockTime'] ?? 0) as int).toString());

    if (widget.route['origin'] != null) {
      _selectedOrigin = widget.airports.firstWhere(
        (Map<String, dynamic> a) => a['id'] == (widget.route['origin'] as Map<String, dynamic>)['id'],
        orElse: () => widget.airports.first,
      );
    }
    else {
      _selectedOrigin = widget.airports.first;
    }

    if (widget.route['destination'] != null) {
      _selectedDestination = widget.airports.firstWhere(
        (Map<String, dynamic> a) => a['id'] == (widget.route['destination'] as Map<String, dynamic>)['id'],
        orElse: () => widget.airports.first,
      );
    }
    else {
      _selectedDestination = widget.airports.skip(1).first;
    }

    _routeDetails = (widget.route['routeDetails'] as List<dynamic>?)
      ?.map((dynamic e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
      .toList()
      ?? <Map<String, dynamic>>[];

    if (widget.route['commencedAt'] != null) {
      _selectedCommencedAt = DateTime.parse(widget.route['commencedAt'] as String);
      _commencedAt = TextEditingController(
        text: DateFormat('dd.MM.yyyy.').format(_selectedCommencedAt!),
      );
    } else {
      _commencedAt = TextEditingController();
    }

    widget.airports.sort((Map<String, dynamic> a, Map<String, dynamic> b) => a['name'].toString().compareTo(b['name'].toString()));
  }

  @override
  void dispose() {
    _blockTime.dispose();
    _commencedAt.dispose();
    super.dispose();
  }

  void _openRouteDetailDialog(Map<String, dynamic> routeDetail){
    showDialog<void>(
      context: context, 
      builder: (BuildContext context){
        return RouteDetailEditor(
          routeDetail: routeDetail,
          aircraftTypes: widget.aircraftTypes,
          onSave: (Map<String, dynamic> updatedRouteDetail) {
            setState(() {
              if (updatedRouteDetail['id'] == 0) {
                final Map<String, dynamic> routeDetailToAdd = <String, dynamic>{
                  'routeId': updatedRouteDetail['routeId'],
                  'flightNumber': updatedRouteDetail['flightNumber'],
                  'daysOfWeek': updatedRouteDetail['daysOfWeek'],
                  'departure': updatedRouteDetail['departure'],
                  'arrival': updatedRouteDetail['arrival'],
                  'aircraftType': updatedRouteDetail['aircraftType']
                };

                _routeDetails.add(routeDetailToAdd);
              }
              else {
                final int index = _routeDetails.indexWhere((Map<String, dynamic> rd) => rd['id'] == updatedRouteDetail['id']);

                if (index != -1) {
                  _routeDetails[index] = updatedRouteDetail;
                }
              }
            });
          },
          onDelete: () {
            setState(() {
              if (routeDetail['id'] != 0) {
                _routeDetails.removeWhere((Map<String, dynamic> rd) => rd['id'] == routeDetail['id']);
              }
            });
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context){
    final bool isNew = (widget.route['id'] == 0);

    return AlertDialog(
      title: isNew ? 
        const Text(
          'New route',
          style: TextStyle(fontWeight: FontWeight.bold)
        ) : 
        const Text(
          'Edit route',
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
      content: SizedBox(
        width: 500,
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
                value: _selectedOrigin,
                decoration: const InputDecoration(
                  labelText: 'Origin Airport',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  border: OutlineInputBorder(),
                ),
                iconEnabledColor: Colors.black,
                selectedItemBuilder: (BuildContext context) {
                  return widget.airports.map((Map<String, dynamic> airport) {
                    return Text(
                      airport['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  }).toList();
                },
                items: widget.airports.map((Map<String, dynamic> airport) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: airport,
                    child: Text(airport['name'] as String),
                  );
                }).toList(),
                onChanged: (Map<String, dynamic>? value) {
                  if (value != null) {
                    setState(() {
                      _selectedOrigin = value;
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
                ),
              ),
              child: DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedDestination,
                decoration: const InputDecoration(
                  labelText: 'Destination Airport',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  border: OutlineInputBorder(),
                ),
                iconEnabledColor: Colors.black,
                selectedItemBuilder: (BuildContext context) {
                  return widget.airports.map((Map<String, dynamic> airport) {
                    return Text(
                      airport['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  }).toList();
                },
                items: widget.airports.map((Map<String, dynamic> airport) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: airport,
                    child: Text(airport['name'] as String),
                  );
                }).toList(),
                onChanged: (Map<String, dynamic>? value) {
                  if (value != null) {
                    setState(() {
                      _selectedDestination = value;
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
                controller: _blockTime,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Block Time (min)',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _blockTimeError ? 'Block Time is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _blockTimeError = value.trim().isEmpty;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            if (!isNew) ...<Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Route Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      _openRouteDetailDialog(<String, dynamic>{'id': 0, 'routeId': widget.route['id']});
                    }, 
                    icon: const Icon(Icons.add_circle),
                    iconSize: 22,
                  )
                ],
              ),

              if (_routeDetails.isEmpty)
                const Center(
                  child: Text(
                    'No route details yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    )
                  ),
                )
              else 
                Column(
                  children: _routeDetails
                    .map((Map<String, dynamic> rd) {
                      Color rowColor = Colors.black;
                      final int aircraftRange = ((rd['aircraftType'] as Map<String, dynamic>)['range'] ?? 0) as int;
                      final int routeDistance = (widget.route['distance'] ?? 0) as int;

                      if (aircraftRange < routeDistance) {
                        rowColor = Colors.red;
                      }

                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            _openRouteDetailDialog(rd);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                width: 110,
                                child: Center(
                                  child: Text(
                                    rd['flightNumber'].toString(),
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: rowColor
                                    )
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 140,
                                child: Center(
                                  child: Text(
                                    '${rd['departure'].toString().substring(0, 5)} - ${rd['arrival'].toString().substring(0, 5)}',
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: rowColor
                                    )
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 130,
                                child: Center(
                                  child: Text(
                                    rd['daysOfWeek'].toString(),
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: rowColor
                                    )
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: Center(
                                  child: Text(
                                    (rd['aircraftType'] as Map<String, dynamic>)['code'].toString(),
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: rowColor
                                    )
                                  ),
                                ),
                              ),
                            ]
                          ),
                        ),
                      );
                    })
                    .toList()
                ),
              const SizedBox(height: 16),
            ],

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
                controller: _commencedAt,
                readOnly: true,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Commenced At',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _commencedAtError ? 'Commence Date is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _commencedAtError = value.trim().isEmpty;
                  });
                },
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedCommencedAt ?? DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now().add(const Duration(days: 5 * 365)),
                    helpText: 'Select Commence Date',
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
                      _selectedCommencedAt = picked;
                      _commencedAt.text = DateFormat('dd.MM.yyyy').format(picked);
                      _commencedAtError = false;
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
            
                if (!isNew && widget.onTerminate != null)
                  TextButton(
                    onPressed: () async {
                      await widget.onTerminate!();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'Terminate',
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
                    final int? parsedBlockTime = int.tryParse(_blockTime.text);

                    setState(() {
                      _blockTimeError = parsedBlockTime == null;
                      _commencedAtError = _selectedCommencedAt == null;
                    });

                    if (_blockTimeError || _commencedAtError) {
                      return;
                    }

                    final Map<String, dynamic> updated = <String, dynamic>{
                      'id': widget.route['id'],
                      'origin': _selectedOrigin,
                      'destination': _selectedDestination,
                      'distance': widget.route['distance'],
                      'blockTime': parsedBlockTime,
                      'routeDetails': _routeDetails,
                      'commencedAt': _selectedCommencedAt!.toIso8601String(),
                      'terminatedAt': widget.route['terminatedAt']
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
