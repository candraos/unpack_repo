import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unpack/views/register.dart';
import 'package:unpack/web_services/authentication_service.dart';
import 'dashboard.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       automaticallyImplyLeading: false,

        flexibleSpace: Container(
          margin: EdgeInsets.only(top: 20),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

        Column(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'SIGN ',
                    style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 40,fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'IN',
                    style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 40,fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Text("Enter your email and password",style: TextStyle(
              color: Colors.grey,
              fontSize: 20
            ),)
          ],
        ),
            Column(
              children: [
                Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                            child: Text("Email",)),
                        Container(
                          margin: EdgeInsets.only(bottom: 30),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                                hintText: "Enter your email"
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                            child: Text("Password",)),
                        Container(
                          margin: EdgeInsets.only(bottom: 15),
                          child: TextFormField(
                            controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                  hintText: "Enter your password"
                              )
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
                          text: 'Don\'t have an account? ',
                          style: TextStyle(color: Colors.grey,fontSize: 20),
                        ),
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 20),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => Register()));
                            },
                        ),

                      ],
                    ),
                  ),
                ),
              ],
            ),

            Container(

              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor
                  ),
                    onPressed: () async{
                    try {
                      AuthenticationService _authenticationService = AuthenticationService();
                      var body = await _authenticationService.login(
                          _emailController.text.trim(),
                          _passwordController.text.trim());

                      if (body["message"] != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(body["message"])));
                        return;
                      }
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Dashboard()));
                          }
                          catch(e){
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));

                    }
                    },
                    child: Text("SIGN IN NOW")
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
