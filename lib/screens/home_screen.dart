import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:grocery_vendor_app/screens/dashboard_screen.dart';
import 'package:grocery_vendor_app/screens/login_screen.dart';
import 'package:grocery_vendor_app/services/drawer_services.dart';
import 'package:grocery_vendor_app/widgets/drawer_menu_widget.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  DrawerServices _services = DrawerServices();
  GlobalKey<SliderMenuContainerState> _key = new GlobalKey<SliderMenuContainerState>();
  String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, LoginScreen.id);
        },
        child: Icon(Icons.navigation),
        backgroundColor: Colors.green,
      ),
      body: SliderMenuContainer(
          appBarColor: Colors.white,
          appBarHeight: 80,
          key: _key,
          sliderMenuOpenSize: 250,
          title: Text('', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),),
          trailing: Row(
            children: [
              IconButton(onPressed: (){}, icon: Icon(CupertinoIcons.search)),
              IconButton(onPressed: (){}, icon: Icon(CupertinoIcons.bell)),
            ],
          ),
          sliderMenu: MenuWidget(
            onItemClick: (title) {
              _key.currentState.closeDrawer();
              setState(() {
                this.title = title;
              });
            },
          ),
          sliderMain: _services.drawerScreen(title)),
    );
  }
}
