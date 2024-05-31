import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/statistics.dart';
import 'package:http/http.dart' as http;

class StatisticsService with ChangeNotifier{

  Statistics statistics = Statistics(
      totalShipments: 0, statusCounts: {}, averageDeliveryTime: 0);
  Future getStatistics() async{



    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';
      String id = prefs.getString('id') ?? '';

      final response = await http.get(
        Uri.parse('${Constants.BASE_URL}statistics?userId=$id'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if(response.statusCode == 200){
        var decodedBody = jsonDecode(response.body);
        statistics = Statistics.fromJson(decodedBody);

      }

    }catch(e){
      throw Exception(e.toString());
    }
  }
}