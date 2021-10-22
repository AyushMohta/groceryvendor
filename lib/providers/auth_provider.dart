import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class AuthProvider extends ChangeNotifier {
  File image;
  bool isPicAvail=false;
  String pickerError='';
  double shopLatitude;
  double shopLongitude;
  String shopAddress;
  String error='';
  String email;

  Future<File> getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      this.image = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickerError = 'No image Selected..';
      print('No image selected.');
      notifyListeners();
    }
    return this.image;
  }

  Future getCurrentAddress() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    this.shopLatitude = _locationData.latitude;
    this.shopLongitude = _locationData.longitude;
    notifyListeners();

    List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(shopLatitude, shopLongitude);
    this.shopAddress = placemarks[0].name + ', ' + placemarks[0].subLocality + ', ' + placemarks[0].locality;
    print(shopAddress);
    notifyListeners();

    return shopAddress;
  }

  Future<UserCredential> registerVendor(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      print('It is getting authenticated');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        this.error = 'The password provided is too weak.';
        notifyListeners();
      } else if (e.code == 'email-already-in-use') {
        this.error = 'The account already exists for that email.';
        notifyListeners();
      }
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e);
    }
    return userCredential;
  }

  Future<UserCredential> loginVendor(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.code;
      notifyListeners();
      print(e);
    }
    return userCredential;
  }

  // reset password
  Future<void> resetPassword(email) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.code;
      notifyListeners();
      print(e);
    }
    return userCredential;
  }

  Future<void> saveVendorDataToDB({String url, String shopName, String mobile, String dialog}){
    User user = FirebaseAuth.instance.currentUser;
    DocumentReference _vendors = FirebaseFirestore.instance.collection('vendors').doc(user.uid);
    _vendors.set({
      'uid': user.uid,
      'shopName': shopName,
      'mobile': mobile,
      'email': this.email,
      'dialog': dialog,
      'address': this.shopAddress,
      'location': GeoPoint(this.shopLatitude, this.shopLongitude),
      'shopOpen': true,
      'rating': 0.00,
      'totalRating': 0,
      'isTopPicked': false,
      'imageUrl': url,
      'accVerified': false,
    });
    return null;
  }

}