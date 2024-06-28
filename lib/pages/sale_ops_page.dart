import 'package:easy_pos_r5/helpers/sql_helper.dart';
import 'package:easy_pos_r5/models/order.dart';
import 'package:easy_pos_r5/models/order_item.dart';
import 'package:easy_pos_r5/models/products.dart';
import 'package:easy_pos_r5/widgets/app_elevated_button.dart';
import 'package:easy_pos_r5/widgets/clients_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../widgets/app_text_form_field.dart';

var discountController = TextEditingController();

class SaleOpsPage extends StatefulWidget {
  final Order? order;
  const SaleOpsPage({this.order, super.key});

  @override
  State<SaleOpsPage> createState() => _SaleOpsPageState();
}

class _SaleOpsPageState extends State<SaleOpsPage> {
  String? orderLabel;
  List<Product>? products;
  List<OrderItem> selectedOrderItem = [];
  int? selectedClientId;

  @override
  void initState() {
    super.initState();
    initPage();
  }

  void initPage() {
    orderLabel = widget.order == null
        ? '#OR${DateTime.now().millisecondsSinceEpoch}'
        : widget.order?.id.toString();
    getProducts();
  }

  void getProducts() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
      select P.*, C.name as categoryName, C.description as categoryDesc 
      from products P
      inner join categories C
      on P.categoryId = C.id
      """);

      if (data.isNotEmpty) {
        products = data.map((item) => Product.fromJson(item)).toList();
      } else {
        products = [];
      }
    } catch (e) {
      print('Error in getProducts: $e');
      products = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'Add New Sale' : 'Update Sale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOrderDetailsCard(),
              _buildOrderItemsCard(),
              AppElevatedButton(
                onPressed: selectedOrderItem.isEmpty ? null : onSetOrder,
                label: widget.order == null ? 'Add Order' : 'Update Order',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Label: $orderLabel',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ClientsDropDown(
              selectedValue: selectedClientId,
              onChanged: (clientId) {
                setState(() {
                  selectedClientId = clientId;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  onPressed: onAddProductClicked,
                  icon: Icon(Icons.add),
                ),
                Text(
                  'Add Products',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Order Items',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            for (var orderItem in selectedOrderItem)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  leading: Image.network(orderItem.product?.image ?? ''),
                  title: Text('${orderItem.product?.name ?? ''}, ${orderItem.productCount}x'),
                  trailing: Text('${orderItem.productCount! * orderItem.product!.price!}'),
                ),
              ),
            AppTextFormField(
              controller: discountController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Specify discount percentage';
                }
                return null;
              },
              label: 'Discount',
            ),
            Text(
              'Total Price: ${calculateTotalPrice()}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onSetOrder() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();

      var orderId = await sqlHelper.db!.insert('orders', {
        'label': orderLabel,
        'totalPrice': calculateTotalPrice(),
        'discount': double.tryParse(discountController.text) ?? 0.0,
        'clientId': selectedClientId ?? 1,
      });

      var batch = sqlHelper.db!.batch();
      for (var orderItem in selectedOrderItem) {
        batch.insert('orderProductItems', {
          'orderId': orderId,
          'productId': orderItem.productId,
          'productCount': orderItem.productCount,
        });
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text('Order Set Successfully'),
      ));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error in Create Order: $e'),
      ));
    }
  }

  double calculateTotalPrice() {
    double total = selectedOrderItem.fold(
      0,
          (sum, item) => sum + (item.productCount! * item.product!.price!),
    );
    double discount = double.tryParse(discountController.text) ?? 0.0;
    return total - (total * (discount / 100));
  }

  void onAddProductClicked() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateEx) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: products == null || products!.isEmpty
                    ? Center(child: Text('No Data Found'))
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Products',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: products!.map((product) {
                          var orderItem = getOrderItem(product.id!);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              leading: Image.network(product.image ?? 'No Image'),
                              title: Text(product.name ?? 'No Name'),
                              subtitle: orderItem == null
                                  ? null
                                  : Row(
                                children: [
                                  IconButton(
                                    onPressed: orderItem.productCount == 1
                                        ? null
                                        : () {
                                      setStateEx(() {
                                        orderItem.productCount =
                                            (orderItem.productCount ?? 0) - 1;
                                      });
                                    },
                                    icon: Icon(Icons.remove),
                                  ),
                                  Text(orderItem.productCount.toString()),
                                  IconButton(
                                    onPressed: () {
                                      setStateEx(() {
                                        if (orderItem.productCount! < product.stock!) {
                                          orderItem.productCount =
                                              (orderItem.productCount ?? 0) + 1;
                                        }
                                      });
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ],
                              ),
                              trailing: orderItem == null
                                  ? IconButton(
                                onPressed: () {
                                  setStateEx(() {
                                    onAddItem(product);
                                  });
                                },
                                icon: Icon(Icons.add),
                              )
                                  : IconButton(
                                onPressed: () {
                                  setStateEx(() {
                                    onDeleteItem(product.id!);
                                  });
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      label: 'Back',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    setState(() {});
  }

  OrderItem? getOrderItem(int productId) {
    for (var item in selectedOrderItem) {
      if (item.productId == productId) {
        return item;
      }
    }
    return null;
  }

  void onAddItem(Product product) {
    selectedOrderItem.add(OrderItem(
      productId: product.id,
      productCount: 1,
      product: product,
    ));
    setState(() {});
  }

  void onDeleteItem(int productId) {
    selectedOrderItem.removeWhere((item) => item.productId == productId);
    setState(() {});
  }
}
