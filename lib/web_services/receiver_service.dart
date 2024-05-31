import 'dart:convert';

import 'package:unpack/models/receiver.dart';

import '../constants.dart';
import '../models/warehouse.dart';
import 'package:http/http.dart' as http;

class ReceiverService{
  Future<List<Receiver>> fetchReceivers() async {
    final response = await http.get(Uri.parse('${Constants.BASE_URL}getReceivers'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Receiver.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load receivers');
    }
  }
}