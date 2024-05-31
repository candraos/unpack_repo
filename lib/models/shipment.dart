import 'item.dart';

class Shipment {
  String? id;
  String customerId;
  String receiverId;
  String origin;
  String destination;
  DateTime shipmentDate;
  DateTime? expectedDeliveryDate;
  String status;
  String warehouseId;
  List<Item> items;

  Shipment({
    this.id,
    required this.customerId,
    required this.receiverId,
    required this.origin,
    required this.destination,
    required this.shipmentDate,
    required this.expectedDeliveryDate,
    required this.status,
    required this.warehouseId,
    required this.items,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: json["_id"],
      customerId: json['customer_id'],
      receiverId: json['receiver_id'],
      origin: json['origin'],
      destination: json['destination'],
      shipmentDate: DateTime.parse(json['shipmentDate']),
      expectedDeliveryDate:json['expectedDeliveryDate'] != null ? DateTime.parse(json['expectedDeliveryDate']) : null,
      status: json['status'],
      warehouseId: json['warehouseID'],
      items: (json['Items'] as List<dynamic>)
          .map((itemJson) => Item.fromJson(itemJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'customer_id': customerId,
      'receiver_id': receiverId,
      'origin': origin,
      'destination': destination,
      'shipmentDate': shipmentDate.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'status': status,
      'warehouseID': warehouseId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}