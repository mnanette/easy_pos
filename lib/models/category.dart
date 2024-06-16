class CategoryData {
  int? id;
  String? name;
  String? phone;

  CategoryData.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    name = data["name"];
    phone = data["description"];
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "description": phone};
  }
}
