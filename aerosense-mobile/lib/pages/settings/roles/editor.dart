import 'package:aerosense/model/permission.dart';
import 'package:flutter/material.dart';

class Editor extends StatefulWidget {
  const Editor({
    super.key,
    required this.role,
    required this.onSave,
    this.onDelete,
  });
  
  final Map<String, dynamic> role;
  final Future<void> Function(Map<String, dynamic> updated) onSave;
  final Future<void> Function()? onDelete;

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late TextEditingController _name;
  late List<String> _selectedFunctions;

  final ScrollController _allowedFunctionsController = ScrollController();

  bool _nameError = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: (widget.role['name'] ?? '') as String);

    _selectedFunctions = (widget.role['allowedFunctions'] ?? '')
      .toString()
      .split(',')
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toList();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNew = (widget.role['id'] == 0);

    return AlertDialog(
      title: isNew ? 
        const Text(
          'New role',
          style: TextStyle(fontWeight: FontWeight.bold)
        ) : 
        const Text(
          'Edit role',
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
                  labelText: 'Role Name',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _nameError ? 'Name is required' : null
                ),
                onChanged: (String value) {
                  setState(() {
                    _nameError = value.trim().isEmpty;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Allowed Functions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 300,
              child: Scrollbar(
                controller: _allowedFunctionsController,
                thumbVisibility: true,
                child: ListView(
                  controller: _allowedFunctionsController,
                  children: Permission.all.map((String func) {
                    final bool checked = _selectedFunctions.contains(func);

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
                            _selectedFunctions.add(func);
                          } else {
                            _selectedFunctions.remove(func);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
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
                    setState(() {
                      _nameError = _name.text.trim().isEmpty;
                    });

                    if (_nameError) {
                      return;
                    }

                    final Map<String, dynamic> updated = <String, dynamic>{
                      'id': widget.role['id'],
                      'name': _name.text.trim(),
                      'allowedFunctions': _selectedFunctions.join(','),
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
