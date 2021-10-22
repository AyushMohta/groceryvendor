import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app/providers/auth_provider.dart';
import 'package:grocery_vendor_app/screens/home_screen.dart';
import 'package:provider/provider.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  var _emailTextController = TextEditingController();
  var _passwordTextController = TextEditingController();
  var _cPasswordTextController = TextEditingController();
  var _addressTextController = TextEditingController();
  var _nameTextController = TextEditingController();
  var _dialogTextController = TextEditingController();
  String email;
  String password;
  String shopName;
  String mobile;
  bool _isLoading=false;


  Future<String> uploadFile(filePath) async {
    File file = File(filePath);

    FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      await _storage.ref('uploads/shopProfilePic/${_nameTextController.text}').putFile(file);
    } on FirebaseException catch(e) {
      print(e.code);
    }
    // now after upload file we need to file url path to save in database
    String downloadURL = await _storage.ref('uploads/shopProfilePic/${_nameTextController.text}').getDownloadURL();
    return downloadURL;
  }


  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);

    scaffoldMessage(message) {
      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }

    return _isLoading ? CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
    ) : Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter Shop Name';
                }
                setState(() {
                  _nameTextController.text = value;
                });
                setState(() {
                  shopName = value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.add_business),
                labelText: 'Business Name',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 2, color: Theme.of(context).primaryColor),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              maxLength: 10,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter Mobile Number';
                }
                setState(() {
                  mobile = value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixText: '+91',
                prefixIcon: Icon(Icons.phone_android),
                labelText: 'Mobile Number',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 2, color: Theme.of(context).primaryColor),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              controller: _emailTextController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if(value.isEmpty) {
                  return 'Enter Email';
                }
                final bool _isValid = EmailValidator.validate(_emailTextController.text);
                if(!_isValid) {
                  return 'Invalid Email Format';
                }
                setState(() {
                  email = value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                labelText: 'Email',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 2, color: Theme.of(context).primaryColor),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              controller: _passwordTextController,
              obscureText: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter Password';
                }
                if(value.length < 6) {
                  return 'Minimum 6 Characters';
                }
                setState(() {
                  password = value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.vpn_key_outlined),
                labelText: 'Password',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 2, color: Theme.of(context).primaryColor),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              controller: _cPasswordTextController,
              obscureText: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter Confirm Password';
                }
                if(value.length < 6) {
                  return 'Minimum 6 Characters';
                }
                if(_passwordTextController.text != _cPasswordTextController.text) {
                  return 'Password doesn\'t match';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.vpn_key_outlined),
                labelText: 'Confirm Password',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 2, color: Theme.of(context).primaryColor),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              maxLines: 6,
              controller: _addressTextController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter Address';
                }
                if(_authData.shopLatitude == null) {
                  return 'Please press Navigation Button';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.contact_mail_outlined),
                labelText: 'Address',
                suffixIcon: IconButton(
                  icon: Icon(Icons.location_searching),
                  onPressed: (){
                    _addressTextController.text = 'Locating... \n Please Wait...';
                    _authData.getCurrentAddress().then((address) {
                      if(address != null) {
                        setState(() {
                          _addressTextController.text = '$address';
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not find location.. Try again'),
                          ),
                        );
                      }
                    });
                  },
                ),
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 2, color: Theme.of(context).primaryColor),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              onChanged: (value) {
                _dialogTextController.text = value;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.comment),
                labelText: 'Shop Dialog',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 2, color: Theme.of(context).primaryColor),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: FlatButton(
                  child: Text('Register', style: TextStyle(color: Colors.white),),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    if(_authData.isPicAvail == true) {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          _isLoading = true;
                        });
                        _authData.registerVendor(email, password).then((credential) => {
                          if(credential.user.uid!=null) {
                            uploadFile(_authData.image.path).then((url){
                              if(url != null) {
                                // save vendor details to database..
                                _authData.saveVendorDataToDB(
                                  url: url,
                                  mobile: mobile,
                                  shopName: shopName,
                                  dialog: _dialogTextController.text
                                );
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Navigator.pushReplacementNamed(context, HomeScreen.id);
                              } else {
                                scaffoldMessage('Failed to upload Shop Profile Pic');
                              }
                            })
                          }
                        });
                      }
                      else {
                        // register failed
                        scaffoldMessage(_authData.error);
                      }
                    } else {
                      scaffoldMessage('Shop Profile pic need to be added');
                    }
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
