class Product {
  int? id;
  String? name;
  String? description;
  double? price;
  int? stock;
  bool? isAvailable;
  String? image;
  int? categoryId;
  String? categoryName;
  String? categoryDesc;

  Product.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    name = data["name"];
    description = data["description"];
    price = data["price"];
    stock = data["stock"];
    isAvailable = data["isAvaliable"] == 1 ? true : false;
    image = data["image"];
    categoryId = data["categoryId"];
    categoryName = data["categoryName"];
    categoryDesc = data["categoryDesc"];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "stock": stock,
      "isAvaliable": isAvailable,
      "image": image,
      "categoryId": categoryId,
    };
  }
}
