import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_vendor_app/providers/product_provider.dart';
import 'package:grocery_vendor_app/widgets/category_list.dart';
import 'package:provider/provider.dart';

class AddNewProduct extends StatefulWidget {
  static const String id = 'addnewproduct-screen';

  @override
  State<AddNewProduct> createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {
  final _formKey = GlobalKey<FormState>();

  List<String> _collection = [
    'Featured Products',
    'Best Selling',
    'Recently Added'
  ];
  String dropdownValue;
  var _categoryTextController = TextEditingController();
  var _subcategoryTextController = TextEditingController();
  var _comparePriceTextController = TextEditingController();
  var _brandTextController = TextEditingController();
  var _lowStockTextController = TextEditingController();
  File _image;
  bool _visible = false;
  bool _track = false;

  String productName;
  String description;
  double price;
  double comparedPrice;
  String sku;
  String weight;
  double tax;
  int stockQty;

  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<ProductProvider>(context);

    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Material(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          child: Text('Products / Add'),
                        ),
                      ),
                      FlatButton.icon(
                        color: Theme.of(context).primaryColor,
                        icon: Icon(
                          Icons.save,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            if (_image != null) {
                              EasyLoading.show(status: 'Saving...');
                              _provider
                                  .uploadProductImage(_image.path, productName)
                                  .then((url) {
                                if (url != null) {
                                  EasyLoading.dismiss();
                                  _provider.saveProductDataToDb(
                                      context: context,
                                      comparedPrice: int.parse(_comparePriceTextController.text),
                                      brand: _brandTextController.text,
                                      collection: dropdownValue,
                                      description: description,
                                      lowStockQty: int.parse(_lowStockTextController.text),
                                      price: price,
                                      sku: sku,
                                      stockQty: stockQty,
                                      tax: tax,
                                      weight: weight,
                                      productName: productName);

                                  setState(() {
                                    _formKey.currentState.reset();
                                    _comparePriceTextController.clear();
                                    dropdownValue = null;
                                    _subcategoryTextController.clear();
                                    _categoryTextController.clear();
                                    _brandTextController.clear();
                                    _track = false;
                                    _image = null;
                                    _visible = false;
                                  });

                                } else {
                                  _provider.alertDialog(
                                      context: context,
                                      title: 'IMAGE UPLOAD',
                                      content:
                                          'Failed to upload product image');
                                }
                              });
                            } else {
                              _provider.alertDialog(
                                  context: context,
                                  title: 'PRODUCT NAME',
                                  content: 'Product Image not selected');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              TabBar(
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(text: 'GENERAL'),
                  Tab(text: 'INVENTORY'),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: TabBarView(
                      children: [
                        ListView(children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Enter Product Name';
                                    }
                                    setState(() {
                                      productName = value;
                                    });
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Product Name*',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Enter Description';
                                    }
                                    setState(() {
                                      description = value;
                                    });
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'About Product*',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      _provider.getProductImage().then((image) {
                                        setState(() {
                                          _image = image;
                                        });
                                      });
                                    },
                                    child: SizedBox(
                                      width: 150,
                                      height: 150,
                                      child: Card(
                                        child: Center(
                                          child: _image == null
                                              ? Text('Select Image')
                                              : Image.file(_image),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Enter Price';
                                    }
                                    setState(() {
                                      price = double.parse(value);
                                    });
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Price*',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  controller: _comparePriceTextController,
                                  validator: (value) {
                                    if (price > double.parse(value)) {
                                      return 'Compared Price should be higher than price';
                                    }
                                    setState(() {
                                      comparedPrice = double.parse(value);
                                    });
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Compared Price',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Row(children: [
                                    Text(
                                      'Collection',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    DropdownButton<String>(
                                      hint: Text('Select Collection'),
                                      value: dropdownValue,
                                      icon: Icon(Icons.arrow_drop_down),
                                      onChanged: (String value) {
                                        setState(() {
                                          dropdownValue = value;
                                        });
                                      },
                                      items: _collection
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    )
                                  ]),
                                ),
                                TextFormField(
                                  controller: _brandTextController,
                                  decoration: InputDecoration(
                                    labelText: 'Brand',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Enter SKU';
                                    }
                                    setState(() {
                                      sku = value;
                                    });
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'SKU',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Category',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: AbsorbPointer(
                                          absorbing: true,
                                          child: TextFormField(
                                            controller: _categoryTextController,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Select Category';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'not selected',
                                              labelStyle:
                                                  TextStyle(color: Colors.grey),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit_outlined),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CategoryList();
                                            },
                                          ).whenComplete(() {
                                            setState(() {
                                              _categoryTextController.text =
                                                  _provider.selectedCategory;
                                              _visible = true;
                                            });
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: _visible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 20),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Sub Category',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 16),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: AbsorbPointer(
                                            absorbing: true,
                                            child: TextFormField(
                                              controller:
                                                  _subcategoryTextController,
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return 'Select Sub Category';
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'not selected',
                                                labelStyle: TextStyle(
                                                    color: Colors.grey),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit_outlined),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return SubCategoryList();
                                              },
                                            ).whenComplete(() {
                                              setState(() {
                                                _subcategoryTextController
                                                        .text =
                                                    _provider
                                                        .selectedSubCategory;
                                              });
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Enter Weight';
                                    }
                                    setState(() {
                                      weight = value;
                                    });
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Weight eg - Kg, gm, etc',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Enter Tax';
                                    }
                                    setState(() {
                                      tax = double.parse(value);
                                    });
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Tax %',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: Text('Track Inventory'),
                                activeColor: Theme.of(context).primaryColor,
                                subtitle: Text(
                                  'Switch ON to track Inventory',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                value: _track,
                                onChanged: (selected) {
                                  setState(() {
                                    _track = !_track;
                                  });
                                },
                              ),
                              Visibility(
                                visible: _track,
                                child: SizedBox(
                                  height: 300,
                                  width: double.infinity,
                                  child: Card(
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            validator: (value) {
                                              if (_track) {
                                                if (value.isEmpty) {
                                                  return 'Enter Stock Quantity';
                                                }
                                                setState(() {
                                                  stockQty = int.parse(value);
                                                });
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'Inventory Quantity',
                                              labelStyle:
                                                  TextStyle(color: Colors.grey),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                          TextFormField(
                                            controller: _lowStockTextController,
                                            decoration: InputDecoration(
                                              labelText:
                                                  'Inventory low stock Quantity',
                                              labelStyle:
                                                  TextStyle(color: Colors.grey),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
