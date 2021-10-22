import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_vendor_app/screens/home_screen.dart';
import 'package:grocery_vendor_app/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash-screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    Timer(
      Duration(
        seconds: 2
      ),(){
        FirebaseAuth.instance.authStateChanges().listen((User user) {
          if(user == null) {
            Navigator.pushReplacementNamed(context, LoginScreen.id);
          }
          else {
            print(user);
            Navigator.pushReplacementNamed(context, HomeScreen.id);
          }
        });
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('images/3.jpeg', height: 200, width: 200,),
            Text('Grocery Store - Vendor App', style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15
            ),)
          ],
        )
      ),
    );
  }
}
