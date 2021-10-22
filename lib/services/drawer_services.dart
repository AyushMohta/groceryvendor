import 'package:flutter/material.dart';
import 'package:grocery_vendor_app/screens/dashboard_screen.dart';
import 'package:grocery_vendor_app/screens/product_screen.dart';

class DrawerServices {
  Widget drawerScreen(title) {
    if(title == 'Dashboard') {
      return MainScreen();
    }if(title == 'Product') {
      return ProductScreen();
    }if(title == 'Coupons') {
      return MainScreen();
    }if(title == 'Orders') {
      return MainScreen();
    }if(title == 'Reports') {
      return MainScreen();
    }if(title == 'Setting') {
      return MainScreen();
    }if(title == 'Logout') {
      return MainScreen();
    }
    return MainScreen();
  }
}