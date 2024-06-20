import 'package:flutter/material.dart';

class ClientDropdown extends StatefulWidget {
  @override
  _ClientDropdownState createState() => _ClientDropdownState();
}

class _ClientDropdownState extends State<ClientDropdown> {
  late String _selectedClient;

  List<String> _clients = [
    'Client 1',
    'Client 2',
    'Client 3',
    // Add more clients here
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: _selectedClient,
      onChanged: (value) {
        setState(() {
          _selectedClient = value!;
        });
      },
      items: _clients.map((client) {
        return DropdownMenuItem(
          child: Text(client),
          value: client,
        );
      }).toList(),
    );
  }
}
