import 'package:easy_pos_r5/models/client.dart';
import 'package:flutter/material.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late List<ClientData> clients;
  ClientData? selectedClient;

  @override
  void initState() {
    super.initState();
    // Fetch clients when the screen loads
    fetchClients().then((clientList) {
      setState(() {
        clients = clientList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Client:'),
            DropdownButton<ClientData>(
              hint: Text('Select a client'),
              value: selectedClient,
              onChanged: (ClientData? newValue) {
                setState(() {
                  selectedClient = newValue;
                });
              },
              items: clients.map((ClientData client) {
                return DropdownMenuItem<ClientData>(
                  value: client,
                  child: Text(ClientData.name),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle creating the order with selectedClient
                if (selectedClient != null) {
                  // Example: Print selected client's name
                  print('Selected Client: ${selectedClient!.name}');
                  // Add your order creation logic here
                  // You can use selectedClient.id or other data as needed
                } else {
                  // No client selected, handle this case
                  print('No client selected');
                }
              },
              child: Text('Create Order'),
            ),
          ],
        ),
      ),
    );
  }
}
