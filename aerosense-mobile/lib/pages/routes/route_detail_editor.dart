import 'package:flutter/material.dart';

class RouteDetailEditor extends StatefulWidget {
  const RouteDetailEditor({
    super.key,
    required this.routeDetail,
    this.blockTime,
    required this.aircraftTypes,
    required this.onSave,
    this.onDelete,
  });
  
  final Map<String, dynamic> routeDetail;
  final int? blockTime;
  final List<Map<String, dynamic>> aircraftTypes;
  final void Function(Map<String, dynamic> updated) onSave;
  final void Function()? onDelete;

  @override
  State<RouteDetailEditor> createState() => _EditorState();
}

class _EditorState extends State<RouteDetailEditor> {
  late TextEditingController _flightNumber;
  late TextEditingController _daysOfWeek;
  late TextEditingController _departure;
  late TextEditingController _arrival;
  late Map<String, dynamic> _selectedAircraftType;

  bool _flightNumberError = false;
  bool _daysOfWeekError = false;
  bool _departureError = false;
  bool _arrivalError = false;

  bool _departureTimeCalculated = false;
  bool _arrivalTimeCalculated = false;

  @override
  void initState() {
    super.initState();
    _flightNumber = TextEditingController(text: (widget.routeDetail['flightNumber'] ?? '').toString());
    _daysOfWeek = TextEditingController(text: (widget.routeDetail['daysOfWeek'] ?? '').toString());
    _departure = TextEditingController(text: (widget.routeDetail['departure'] ?? '').toString());
    _arrival = TextEditingController(text: (widget.routeDetail['arrival'] ?? '').toString());

    if (_departure.text.length >= 5) {
      _departure.text = _departure.text.substring(0, 5);
    }

    if (_arrival.text.length >= 5) {
      _arrival.text = _arrival.text.substring(0, 5);
    }

    if (widget.routeDetail['aircraftType'] != null) {
      _selectedAircraftType = widget.aircraftTypes.firstWhere(
        (Map<String, dynamic> at) => at['id'] == (widget.routeDetail['aircraftType'] as Map<String, dynamic>)['id'],
        orElse: () => widget.aircraftTypes.first,
      );
    }
    else {
      _selectedAircraftType = widget.aircraftTypes.first;
    }
  }

  String calculateDepartureTime() {
    final int hours = int.tryParse(_arrival.text.substring(0, 2)) ?? 0;
    final int minutes = int.tryParse(_arrival.text.substring(3, 5)) ?? 0;
    final int time = hours * 60 + minutes;

    final int departureTime = (time - widget.blockTime! + 24 * 60) % (24 * 60);
    final int departureHours = departureTime ~/ 60;
    final int departureMinutes = departureTime % 60;

    return '${departureHours.toString().padLeft(2, '0')}:${departureMinutes.toString().padLeft(2, '0')}';
  }

  String calculateArrivalTime() {
    final int hours = int.tryParse(_departure.text.substring(0, 2)) ?? 0;
    final int minutes = int.tryParse(_departure.text.substring(3, 5)) ?? 0;
    final int time = hours * 60 + minutes;

    final int arrivalTime = (time + widget.blockTime!) % (24 * 60);
    final int arrivalHours = arrivalTime ~/ 60;
    final int arrivalMinutes = arrivalTime % 60;

    return '${arrivalHours.toString().padLeft(2, '0')}:${arrivalMinutes.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _flightNumber.dispose();
    _daysOfWeek.dispose();
    _departure.dispose();
    _arrival.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    final bool isNew = (widget.routeDetail['id'] == 0);

    return AlertDialog(
      title: isNew ? 
        const Text(
          'New route detail',
          style: TextStyle(fontWeight: FontWeight.bold)
        ) : 
        const Text(
          'Edit route detail',
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
                )
              ),
              child: TextField(
                cursorColor: Colors.black,
                controller: _flightNumber,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Flight number',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _flightNumberError ? 'Flight number is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _flightNumberError = value.trim().isEmpty;
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
                controller: _daysOfWeek,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Days of week (example: 1-3-5-7)',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _daysOfWeekError ? 'Days of week are required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _daysOfWeekError = value.trim().isEmpty;
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
                controller: _departure,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Departure time (hh:mm)',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _departureError ? 'Departure time is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _departureError = value.trim().isEmpty;
                    if (widget.blockTime != null &&
                        value.length == 5 &&
                        value[2] == ':' && 
                        int.tryParse(value[0]) != null && 
                        int.tryParse(value[1]) != null && 
                        int.tryParse(value[3]) != null && 
                        int.tryParse(value[4]) != null
                    ) {
                      _arrival.text = calculateArrivalTime();
                      _arrivalTimeCalculated = true;
                    }
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
                controller: _arrival,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Arrival time (hh:mm)',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _arrivalError ? 'Arrival time is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _arrivalError = value.trim().isEmpty;
                    if (widget.blockTime != null &&
                        value.length == 5 &&
                        value[2] == ':' && 
                        int.tryParse(value[0]) != null && 
                        int.tryParse(value[1]) != null && 
                        int.tryParse(value[3]) != null && 
                        int.tryParse(value[4]) != null
                    ) {
                      _departure.text = calculateDepartureTime();
                      _departureTimeCalculated = true;
                    }
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
                value: _selectedAircraftType,
                decoration: const InputDecoration(
                  labelText: 'Aircraft Type',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  border: OutlineInputBorder(),
                ),
                iconEnabledColor: Colors.black,
                selectedItemBuilder: (BuildContext context) {
                  return widget.aircraftTypes.map((Map<String, dynamic> aircraftType) {
                    return Text(
                      aircraftType['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  }).toList();
                },
                items: widget.aircraftTypes.map((Map<String, dynamic> aircraftType) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: aircraftType,
                    child: Text(aircraftType['name'] as String),
                  );
                }).toList(),
                onChanged: (Map<String, dynamic>? value) {
                  if (value != null) {
                    setState(() {
                      _selectedAircraftType = value;
                    });
                  }
                },
              ),
            ),

            if (_arrivalTimeCalculated) ...<Widget>[
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Calculated arrival time does not take time zones into consideration, please adjust it to local time manually if needed',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
            ],

            if (_departureTimeCalculated) ...<Widget>[
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Calculated departure time does not take time zones into consideration, please adjust it to local time manually if needed',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
            ]
          ],
        )
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
                      widget.onDelete!();
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
              ]
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
                      _flightNumberError = _flightNumber.text.trim().isEmpty;
                      _daysOfWeekError = _daysOfWeek.text.trim().isEmpty;
                      _departureError = _departure.text.trim().isEmpty;
                      _arrivalError = _arrival.text.trim().isEmpty;
                    });

                    if (_flightNumberError || _daysOfWeekError || _departureError || _arrivalError) {
                      return;
                    }

                    final Map<String, dynamic> updated = <String, dynamic>{
                      'id': widget.routeDetail['id'],
                      'routeId': widget.routeDetail['routeId'],
                      'flightNumber': _flightNumber.text.trim(),
                      'daysOfWeek': _daysOfWeek.text.trim(),
                      'departure': _departure.text.trim(),
                      'arrival': _arrival.text.trim(),
                      'aircraftType': _selectedAircraftType
                    };
                    widget.onSave(updated);
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
