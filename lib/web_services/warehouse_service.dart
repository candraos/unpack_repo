import 'dart:convert';

import '../constants.dart';
import '../models/warehouse.dart';
import 'package:http/http.dart' as http;

class WarehouseService{
  Future<List<Warehouse>> fetchWarehouses() async {
    final response = await http.get(Uri.parse('${Constants.BASE_URL}getWarehouses'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Warehouse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load warehouses');
    }
  }
}