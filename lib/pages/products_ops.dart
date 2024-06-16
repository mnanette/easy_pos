import 'package:easy_pos_r5/helpers/sql_helper.dart';
import 'package:easy_pos_r5/models/products.dart';
import 'package:easy_pos_r5/widgets/app_elevated_button.dart';
import 'package:easy_pos_r5/widgets/app_text_form_field.dart';
import 'package:easy_pos_r5/widgets/categories_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class ProductOpsPage extends StatefulWidget {
  final Product? product;
  const ProductOpsPage({this.product, super.key});

  @override
  State<ProductOpsPage> createState() => _ProductOpsPageState();
}

class _ProductOpsPageState extends State<ProductOpsPage> {
  var formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? descriptionController;
  TextEditingController? priceController;
  TextEditingController? stockController;
  TextEditingController? imageController;
  bool isAvailable = false;
  int? selectedCategoryId;

  @override
  void initState() {
    setInitialData();

    super.initState();
  }

  void setInitialData() {
    nameController = TextEditingController(text: widget.product?.name);
    descriptionController =
        TextEditingController(text: widget.product?.description);

    imageController = TextEditingController(text: widget.product?.image);

    priceController =
        TextEditingController(text: '${widget.product?.price ?? ''}');
    stockController =
        TextEditingController(text: '${widget.product?.stock ?? ''}');

    isAvailable = widget.product?.isAvailable ?? false;
    selectedCategoryId = widget.product?.categoryId;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Update' : 'Add New'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
            key: formKey,
            child: SingleChildScrollView(
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
                      controller: descriptionController!,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                      label: 'Description'),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextFormField(
                            controller: priceController!,
                            keyboardType: TextInputType.number,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Price is required';
                              }
                              return null;
                            },
                            label: 'Price'),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: AppTextFormField(
                            keyboardType: TextInputType.number,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            controller: stockController!,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Stock is required';
                              }
                              return null;
                            },
                            label: 'Stock'),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  AppTextFormField(
                      controller: imageController!,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Image Url is required';
                        }
                        return null;
                      },
                      label: 'Image Url'),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Switch(
                          value: isAvailable,
                          onChanged: (value) {
                            setState(() {
                              isAvailable = value;
                            });
                          }),
                      const SizedBox(
                        width: 10,
                      ),
                      Text('Is Avaliable')
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CategoriesDropDown(
                    selectedValue: selectedCategoryId,
                    onChanged: (categoryId) {
                      setState(() {
                        selectedCategoryId = categoryId;
                      });
                    },
                  ),
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
              ),
            )),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.product != null) {
          // update logic
          await sqlHelper.db!.update(
              'products',
              {
                'name': nameController?.text,
                'description': descriptionController?.text,
                'price': priceController?.text,
                'stock': stockController?.text,
                'image': imageController?.text,
                'isAvailable': isAvailable ? 1 : 0,
                'categoryId': selectedCategoryId,
              },
              where: 'id =?',
              whereArgs: [widget.product?.id]);
        } else {
          await sqlHelper.db!.insert('products', {
            'name': nameController?.text,
            'description': descriptionController?.text,
            'price': priceController?.text,
            'stock': stockController?.text,
            'image': imageController?.text,
            'isAvailable': isAvailable ? 1 : 0,
            'categoryId': selectedCategoryId,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text('Category Saved Successfully')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error In Create Category : $e')));
    }
  }
}
