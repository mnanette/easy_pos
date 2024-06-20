class ClientData {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? address;

  ClientData.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    name = data["name"];
    phone = data["description"];
    email = data["email"];
    address = data["address"];

    @override
    String toString() => '$name'; // Return the name as a string
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "Phone": phone,
      "Email": email,
      "Address": address
    };
  }
}
