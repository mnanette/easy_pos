import 'package:data_table_2/data_table_2.dart';
import 'package:easy_pos_r5/helpers/sql_helper.dart';
import 'package:easy_pos_r5/widgets/app_table.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_pos_r5/pages/client_ops.dart';
import 'package:easy_pos_r5/models/client.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  List<ClientData>? clients;
  @override
  void initState() {
    getClients();
    super.initState();
  }

  void getClients() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('clients');

      if (data.isNotEmpty) {
        clients = [];
        for (var item in data) {
          clients!.add(ClientData.fromJson(item));
        }
      } else {
        clients = [];
      }
    } catch (e) {
      print('Error In get data $e');
      clients = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
              onPressed: () async {
                var result = await Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => ClientsOpsPage()));
                if (result ?? false) {
                  getClients();
                }
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) async {
                var sqlHelper = GetIt.I.get<SqlHelper>();
                var result = await sqlHelper.db!.rawQuery("""
        SELECT * FROM Clients
        WHERE name LIKE '%$value%' OR phone LIKE '%$value%';
          """);

                print('values:${result}');
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                labelText: 'Search',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: AppTable(
                    columns: const [
                  DataColumn(label: Text('Id')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Center(child: Text('Actions'))),
                ],
                    source: ClientsTableSource(
                      clientsEx: clients,
                      onUpdate: (clientData) async {
                        var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (ctx) => ClientsOpsPage(
                                      clientData: clientData,
                                    )));
                        if (result ?? false) {
                          getClients();
                        }
                      },
                      onDelete: (clientData) {
                        onDeleteRow(clientData.id!);
                      },
                    ))),
          ],
        ),
      ),
    );
  }

  Future<void> onDeleteRow(int id) async {
    try {
      var dialogResult = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Client'),
              content:
                  const Text('Are you sure you want to delete this client?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          });

      if (dialogResult ?? false) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        var result = await sqlHelper.db!.delete(
          'clients',
          where: 'id =?',
          whereArgs: [id],
        );
        if (result > 0) {
          getClients();
        }
      }
    } catch (e) {
      print('Error In delete data $e');
    }
  }
}

class ClientsTableSource extends DataTableSource {
  List<ClientData>? clientsEx;

  void Function(ClientData) onUpdate;
  void Function(ClientData) onDelete;
  ClientsTableSource(
      {required this.clientsEx,
      required this.onUpdate,
      required this.onDelete});

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${clientsEx?[index].id}')),
      DataCell(Text('${clientsEx?[index].name}')),
      DataCell(Text('${clientsEx?[index].phone}')),
      DataCell(Text('${clientsEx?[index].email}')),
      DataCell(Text('${clientsEx?[index].address}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                onUpdate(clientsEx![index]);
              },
              icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: () {
                onDelete(clientsEx![index]);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              )),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => clientsEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
