class ClientData {
  int? id;
  String? name;
  String? phone;
  

  ClientData.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    name = data["name"];
    phone = data["description"];
   

    //@override
    //String? toString() => name; // Return the name as a string
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "Phone": phone,
     
    };
  }
}
