class ExchangeRateData {
  int? id;
  String? currencyPair;
  double? eRate;

  ExchangeRateData.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    currencyPair = data["Currency pair"];
    eRate = data["Rate of exchange"];
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "Currency pair": currencyPair, "Rate of exchange": eRate};
  }
}
