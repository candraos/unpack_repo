import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:unpack/models/shipment.dart';

import '../constants.dart';

class ShipmentService with ChangeNotifier {
  List<Shipment> shipments = [];
  bool showDialog = false;

  Future<void> getShipments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String id = prefs.getString('id') ?? '';
    String type = prefs.getString('type') ?? '';
    String url = type.toLowerCase() == "employee"
        ? '${Constants.BASE_URL}shipments/employee-warehouse?employeeId=$id'
        : '${Constants.BASE_URL}getShipments?userId=$id';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    var decodedBody = jsonDecode(response.body);
    // Handle responses that are not a list
    if (decodedBody is Map && decodedBody.containsKey('message')) {
      shipments = []; // Ensure shipments are empty if "No shipments found"
    } else if (decodedBody is List) {
      shipments = decodedBody
          .map((shipmentJson) => Shipment.fromJson(shipmentJson))
          .toList();
    }
    notifyListeners();
  }

  Future<String> createShipment(Shipment shipment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    final response = await http.post(
      Uri.parse('${Constants.BASE_URL}createShipment'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(shipment.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create shipment');
    }
    List<Shipment> shipmentsTemp = shipments;
    shipmentsTemp.add(shipment);
    shipments = shipmentsTemp;
    notifyListeners();
    return jsonDecode(response.body)["totalFee"].toString();
  }

  Future deleteShipment(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    // Assuming the DELETE API endpoint is 'https://example.com/values/{value}'
    final response = await http.delete(
      Uri.parse('${Constants.BASE_URL}deleteShipment/$id'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<Shipment> shipmentsTemp = shipments;
      shipmentsTemp.removeWhere((shipment) => shipment.id == id);
      shipments = shipmentsTemp;
      notifyListeners();
    } else {
      throw Exception('Failed to delete Shipment');
    }
  }

  Future updateStatus(String id, String newStatus) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    // Assuming the DELETE API endpoint is 'https://example.com/values/{value}'
    final response =
        await http.put(Uri.parse('${Constants.BASE_URL}updateStatus/$id'),
            headers: <String, String>{
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: '{"newStatus": "$newStatus"}');

    if (response.statusCode == 200) {
      List<Shipment> shipmentsTemp = shipments;
      Shipment shipment =
          shipmentsTemp.firstWhere((shipment) => shipment.id == id);
      shipment.status = newStatus;
      shipmentsTemp.removeWhere((shipment) => shipment.id == id);
      shipmentsTemp.add(shipment);
      shipments = shipmentsTemp;
      notifyListeners();
    } else {
      throw Exception('Failed to update status');
    }
  }

  Future updateExpectedDeliveryDate(
      String id, DateTime newExpirationDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    // Assuming the DELETE API endpoint is 'https://example.com/values/{value}'
    final response = await http.put(
        Uri.parse('${Constants.BASE_URL}updateExpectedDeliveryDate/$id'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: '{"newExpirationDate": "${newExpirationDate.toString()}"}');

    if (response.statusCode == 200) {
      List<Shipment> shipmentsTemp = shipments;
      Shipment shipment =
          shipmentsTemp.firstWhere((shipment) => shipment.id == id);
      shipment.expectedDeliveryDate = newExpirationDate;
      shipmentsTemp.removeWhere((shipment) => shipment.id == id);
      shipmentsTemp.add(shipment);
      shipments = shipmentsTemp;
      notifyListeners();
    } else {
      throw Exception('Failed to update delivery date');
    }
  }
}
