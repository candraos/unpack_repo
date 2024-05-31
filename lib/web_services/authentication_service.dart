import '../constants.dart';
import '../models/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService{
   Future login(String email, String password) async {

    final response = await http.post(
      Uri.parse('${Constants.BASE_URL}signin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: '{'
          '"email": "${email}",'
          '"password": "${password}"'
          '}',


    );
    var decodedBody = jsonDecode(response.body);

    if(decodedBody["token"] != null){
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('token', decodedBody["token"]);
      prefs.setString('type', decodedBody["type"]);
      prefs.setString('id', decodedBody["id"]);
    }
    return decodedBody;


  }

  Future register(User user) async{
    final response = await http.post(
      Uri.parse('${Constants.BASE_URL}signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: '{'
          '"name": "${user.name}",'
          '"email": "${user.email}",'
          '"password": "${user.password}",'
          '"type": "${user.type}"'
          '}',


    );
    var decodedBody = jsonDecode(response.body);
    if(decodedBody["user"] != null){
      await login(user.email, user.password);

    }
    return decodedBody;
  }

  logout() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}