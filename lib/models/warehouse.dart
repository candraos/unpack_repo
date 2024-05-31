class Warehouse {
  final String id;
  final String name;
  final String address;
  final String employeeId;

  Warehouse({
    required this.id,
    required this.name,
    required this.address,
    required this.employeeId,
  });

  // Factory method to create Warehouse instance from JSON
  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      employeeId: json['employeeId'] as String,
    );
  }

  // Method to convert Warehouse instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'employeeId': employeeId,
    };
  }
}
