import 'package:flutter/material.dart';

class Editor extends StatefulWidget {
  const Editor({
    super.key,
    required this.airport,
    required this.onSave,
    this.onDelete,
  });
  
  final Map<String, dynamic> airport;
  final Future<void> Function(Map<String, dynamic> updated) onSave;
  final Future<void> Function()? onDelete;

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late TextEditingController _name;
  late TextEditingController _city;
  late TextEditingController _country;
  late TextEditingController _iataCode;
  late TextEditingController _latitude;
  late TextEditingController _longitude;

  bool _nameError = false;
  bool _cityError = false;
  bool _countryError = false;
  bool _iataCodeError = false;
  bool _latitudeError = false;
  bool _longitudeError = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: (widget.airport['name'] ?? '') as String);
    _city = TextEditingController(text: (widget.airport['city'] ?? '') as String);
    _country = TextEditingController(text: (widget.airport['country'] ?? '') as String);
    _iataCode = TextEditingController(text: (widget.airport['iataCode'] ?? '') as String);
    _latitude = TextEditingController(text: ((widget.airport['latitude'] ?? 0) as num).toDouble().toString());
    _longitude = TextEditingController(text: ((widget.airport['longitude'] ?? 0) as num).toDouble().toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _country.dispose();
    _iataCode.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNew = (widget.airport['id'] == 0);

    return AlertDialog(
      title: isNew ? 
        const Text(
          'New airport',
          style: TextStyle(fontWeight: FontWeight.bold)
        ) : 
        const Text(
          'Edit airport',
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
                  labelText: 'Airport Name',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _nameError ? 'Airport Name is required' : null
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
                controller: _city,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'City',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _cityError ? 'City is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _cityError = value.trim().isEmpty;
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
                controller: _country,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Country',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _countryError ? 'Country is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _countryError = value.trim().isEmpty;
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
                controller: _iataCode,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Airport IATA Code',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _iataCodeError ? 'Airport IATA Code is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _iataCodeError = value.trim().isEmpty;
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
                controller: _latitude,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Airport Latitude',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _latitudeError ? 'Airport Latitude is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _latitudeError = value.trim().isEmpty;
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
                controller: _longitude,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  labelText: 'Airport Longitude',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _longitudeError ? 'Airport Longitude is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _longitudeError = value.trim().isEmpty;
                  });
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
                    final double? parsedLatitude = double.tryParse(_latitude.text);
                    final double? parsedLongitude = double.tryParse(_longitude.text);

                    setState(() {
                      _nameError = _name.text.trim().isEmpty;
                      _cityError = _city.text.trim().isEmpty;
                      _countryError = _country.text.trim().isEmpty;
                      _iataCodeError = _iataCode.text.trim().isEmpty;
                      _latitudeError = parsedLatitude == null;
                      _longitudeError = parsedLongitude == null;
                    });

                    if (_nameError || _cityError || _countryError || _iataCodeError || _latitudeError || _longitudeError) {
                      return;
                    }

                    final Map<String, dynamic> updated = <String, dynamic>{
                      'id': widget.airport['id'],
                      'name': _name.text.trim(),
                      'city': _city.text.trim(),
                      'country': _country.text.trim(),
                      'iataCode': _iataCode.text.trim(),
                      'latitude': parsedLatitude,
                      'longitude': parsedLongitude
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
