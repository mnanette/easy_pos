import 'package:easy_pos_r5/helpers/sql_helper.dart';
import 'package:easy_pos_r5/models/order.dart';
import 'package:easy_pos_r5/models/order_item.dart';
import 'package:easy_pos_r5/models/products.dart';
import 'package:easy_pos_r5/widgets/app_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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

  @override
  void initState() {
    initPage();
    super.initState();
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
      select P.* ,C.name as categoryName,C.description as categoryDesc 
      from products P
      inner join categories C
      where P.categoryId = C.id
      """);

      if (data.isNotEmpty) {
        products = [];
        for (var item in data) {
          products!.add(Product.fromJson(item));
        }
      } else {
        products = [];
      }
    } catch (e) {
      print('Error In get data $e');
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Label : $orderLabel',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                          color: Colors.red,
                          child: Text('TODO: add client drop down here')),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                onAddProductClicked();
                              },
                              icon: Icon(Icons.add)),
                          Text(
                            'Add Products',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
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
                            leading:
                                Image.network(orderItem.product?.image ?? ''),
                            title: Text(
                                '${orderItem.product?.name ?? ''},${orderItem.productCount}X'),
                            trailing: Text(
                                '${(orderItem.productCount ?? 0) * (orderItem.product?.price ?? 0)}'),
                          ),
                        ),
                      Container(
                        color: Colors.red,
                        child: Text('TODO: add discount textfield'),
                      ),
                      Text(
                        'Total Price : $calculateTotalPrice',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              AppElevatedButton(
                  onPressed: selectedOrderItem.isEmpty
                      ? null
                      : () async {
                          await onSetOrder();
                        },
                  label: 'Add Order')
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSetOrder() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();

      var orderId = await sqlHelper.db!.insert('orders', {
        'label': orderLabel,
        'totalPrice': calculateTotalPrice,
        'discount': 0,
        'clientId': 1
      });

      var batch = sqlHelper.db!.batch();
      for (var orderItem in selectedOrderItem) {
        batch.insert('orderProductItems', {
          'orderId': orderId,
          'productId': orderItem.productId,
          'productCount': orderItem.productCount ?? 0,
        });
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text('Order Set Successfully')));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error In Create Order : $e')));
    }
  }

  double get calculateTotalPrice {
    double total = 0;

    for (var orderItem in selectedOrderItem) {
      total = total +
          ((orderItem.productCount ?? 0) * (orderItem.product?.price ?? 0));
    }

    return total;
  }

  void onAddProductClicked() async {
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateEx) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: (products?.isEmpty ?? false)
                    ? Center(
                        child: Text('No Data Found'),
                      )
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
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                for (var product in products!)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: ListTile(
                                        leading: Image.network(
                                            product.image ?? 'No Image'),
                                        title: Text(product.name ?? 'No Name'),
                                        subtitle: getOrderItem(product.id!) ==
                                                null
                                            ? null
                                            : Row(
                                                children: [
                                                  IconButton(
                                                      onPressed: getOrderItem(
                                                                      product
                                                                          .id!) !=
                                                                  null &&
                                                              getOrderItem(product
                                                                          .id!)
                                                                      ?.productCount ==
                                                                  1
                                                          ? null
                                                          : () {
                                                              var orderItem =
                                                                  getOrderItem(
                                                                      product
                                                                          .id!);

                                                              orderItem
                                                                      ?.productCount =
                                                                  (orderItem.productCount ??
                                                                          0) -
                                                                      1;
                                                              setStateEx(() {});
                                                            },
                                                      icon: Icon(Icons.remove)),
                                                  Text(
                                                      getOrderItem(product.id!)!
                                                          .productCount
                                                          .toString()),
                                                  IconButton(
                                                      onPressed: () {
                                                        var orderItem =
                                                            getOrderItem(
                                                                product.id!);

                                                        if ((orderItem
                                                                    ?.productCount ??
                                                                0) <
                                                            (product.stock ??
                                                                0)) {
                                                          orderItem
                                                                  ?.productCount =
                                                              (orderItem.productCount ??
                                                                      0) +
                                                                  1;
                                                        }

                                                        setStateEx(() {});
                                                      },
                                                      icon: Icon(Icons.add)),
                                                ],
                                              ),
                                        trailing:
                                            getOrderItem(product.id!) == null
                                                ? IconButton(
                                                    onPressed: () {
                                                      onAddItem(product);
                                                      setStateEx(() {});
                                                    },
                                                    icon: Icon(Icons.add))
                                                : IconButton(
                                                    onPressed: () {
                                                      onDeleteItem(product.id!);
                                                      setStateEx(() {});
                                                    },
                                                    icon: Icon(Icons.delete))),
                                  )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          AppElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              label: 'Back')
                        ],
                      ),
              ),
            );
          });
        });

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
    selectedOrderItem.add(
        OrderItem(productId: product.id, productCount: 1, product: product));
  }

  void onDeleteItem(int productId) {
    for (var i = 0; i < (selectedOrderItem.length); i++) {
      if (selectedOrderItem[i].productId == productId) {
        selectedOrderItem.removeAt(i);
        break;
      }
    }
  }
}
