import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app/services/firebase_services.dart';


class PublishedProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    return Container(
      child: StreamBuilder(
        stream: _services.products.where('published', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('something went wrong...');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(),);
          }
          return SingleChildScrollView(
            child: DataTable(
              showBottomBorder: true,
              dataRowHeight: 60,
              headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
              columns: <DataColumn>[
                DataColumn(label: Expanded(child: Text('Product Name')),),
                DataColumn(label: Text('Image'),),
                DataColumn(label: Text('Actions'),),
              ],
              rows: _productDetails(snapshot.data),
            ),
          );
        },
      ),
    );
  }
  List<DataRow> _productDetails(QuerySnapshot snapshot) {
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document) {
      if (document != null) {
        return DataRow(
          cells: [
            DataCell(
              Container(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Name: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          document.data()['productName'],
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        'SKU: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        document.data()['sku'],
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            DataCell(
              Container(
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Image.network(document.data()['productImage']),
                  )),
            ),
            DataCell(
              popUpButton(
                document.data(),
              ),
            ),
          ],
        );
      }
    }).toList();
    return newList;
  }

  Widget popUpButton(data,{BuildContext context}){
    FirebaseServices _services = FirebaseServices();

    return PopupMenuButton<String>(
        onSelected: (String value){

          if(value == 'publish'){
            _services.unPublishProduct(
              id: data['productId'],
            );
          }

          if(value == 'delete'){
            _services.deleteProduct(
              id: data['productId'],
            );
          }
        },
        itemBuilder: (BuildContext context)=><PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'unpublish',
            child: ListTile(
              leading: Icon(Icons.check),
              title: Text('UnPublish'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'preview',
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Preview'),
            ),
          ),
        ]);
  }
}