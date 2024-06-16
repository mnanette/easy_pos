import 'package:easy_pos_r5/helpers/sql_helper.dart';
import 'package:easy_pos_r5/models/client.dart';
import 'package:easy_pos_r5/widgets/app_elevated_button.dart';
import 'package:easy_pos_r5/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ClientsOpsPage extends StatefulWidget {
  final ClientData? clientData;
  const ClientsOpsPage({this.clientData, super.key});

  @override
  State<ClientsOpsPage> createState() => _ClientsOpsPageState();
}

class _ClientsOpsPageState extends State<ClientsOpsPage> {
  var formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? phoneController;
  TextEditingController? emailController;
  TextEditingController? addressController;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.clientData?.name);
    phoneController = TextEditingController(text: widget.clientData?.phone);
    emailController = TextEditingController(text: widget.clientData?.email);
    addressController = TextEditingController(text: widget.clientData?.address);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientData != null ? 'Update' : 'Add New'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
            key: formKey,
            child: Column(
              children: [
                AppTextFormField(
                    controller: nameController!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                    label: 'Name'),
                const SizedBox(
                  height: 20,
                ),
                AppTextFormField(
                    controller: phoneController!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Phone is required';
                      }
                      return null;
                    },
                    label: 'Phone'),
                const SizedBox(
                  height: 20,
                ),
                AppTextFormField(
                    controller: emailController!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                    label: 'Email'),
                const SizedBox(
                  height: 20,
                ),
                AppTextFormField(
                    controller: addressController!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Address is required';
                      }
                      return null;
                    },
                    label: 'Address'),
                const SizedBox(
                  height: 20,
                ),
                AppElevatedButton(
                  label: 'Submit',
                  onPressed: () async {
                    await onSubmit();
                  },
                ),
              ],
            )),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.clientData != null) {
          // update logic
          await sqlHelper.db!.update('clients',
              {'name': nameController?.text, 'phone': phoneController?.text},
              where: 'id =?', whereArgs: [widget.clientData?.id]);
        } else {
          await sqlHelper.db!.insert('clients',
              {'name': nameController?.text, 'phone': phoneController?.text});
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text('Client Saved Successfully')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error On Create Client : $e')));
    }
  }
}
