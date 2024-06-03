import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unpack/views/dashboard.dart';
import 'package:unpack/views/login.dart';

import '../models/user.dart';
import '../web_services/authentication_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  List<String> _roles = ["Customer","Receiver"];
  String? _selectedRole;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          margin: EdgeInsets.only(),
          child: Center(
            child: Row(
              children: [

                Container(
                  margin: EdgeInsets.only(left: 15),
                  child: SvgPicture.asset(
                    'assets/logo.svg',
                    width: 24,
                    height: 24,
                    color: Colors.white, // Color the icon in white
                  ),
                ),

                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: ' UN',
                          style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 25,fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'PACK',
                          style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),

      ),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 50,horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [

              Column(
                children: [
                  Text("REGISTER",style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 40,
                    fontWeight: FontWeight.bold
                  ),),
                  Text("Let's Get Started",style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20
                  ),)
                ],
              ),

              SizedBox(height: 30,),

              Column(
                children: [
                  Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text("Name",)),
                          Container(
                            margin: EdgeInsets.only(bottom: 30),
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                  hintText: "enter your name"
                              ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text("Email",)),
                          Container(
                            margin: EdgeInsets.only(bottom: 30),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                  hintText: "enter your email"
                              ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text("Password",)),
                          Container(
                            margin: EdgeInsets.only(bottom: 30),
                            child: TextFormField(
                              controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                    hintText: "enter your password"
                                )
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text("Confirm Password",)),
                          Container(
                            margin: EdgeInsets.only(bottom: 30),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                    hintText: "confirm your password"
                                ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text("Role",)),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: DropdownButton(
                              hint: Text("select"),
                              isExpanded: true,
                                value: _selectedRole,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedRole = newValue;
                                  });
                                },
                                items: _roles.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                ),
                          )
                        ],
                      )
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(color: Colors.grey,fontSize: 20),
                          ),
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 20),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => Login()));
                              },
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30,),

              Container(

                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor
                      ),
                      onPressed: () async{
                        AuthenticationService service = AuthenticationService();
                        User user = User(
                          email: _emailController.text.trim(),
                          name: _nameController.text.trim(),
                          password: _passwordController.text.trim(),
                          type: _selectedRole!,
                        );
                        var response = await service.register(user);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response["message"])));
                        if(response["user"] != null){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Dashboard()));
                        }
                      },
                      child: Text("REGISTER")
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
