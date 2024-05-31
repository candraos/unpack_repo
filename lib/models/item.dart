class Item {
  String? id;
  String name;
  int quantity;
  bool isSensitive;
  String type;

  Item({
    this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.isSensitive,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'],
      name: json['name'],
      type: json['type'],
      quantity: json['quantity'],
      isSensitive: json['isSensitive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'name': name,
      'quantity': quantity,
      'type' : type,
      'isSensitive': isSensitive,
    };
  }
}