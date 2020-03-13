import '../helper/qrcodegen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

const URL = "https://paynowend.herokuapp.com";

class Bookings extends StatefulWidget {
  final String userId;

  Bookings(this.userId);
  @override
  _BookingsState createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _phoneNumber;
  String _email;
  String _name;
  var _docIDForKey;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _makePayment(
      phoneNumber, email, price, invoice, paymentMode, document,created) async {
    var myUrl = URL +
        '/' +
        'payment' +
        '/' +
        phoneNumber +
        '/' +
        email +
        '/' +
        price +
        '/' +
        invoice +
        '/' +
        'farebayment' +
        '/' +
        paymentMode;
    print(myUrl);
    final response = await http.get(myUrl);
    print('$response');
    if (response.statusCode == 200) {
      //parse the json object later on
      debugPrint(
          'worked'); //try to get the paynow reference and stuff include it into the secret key
      //create a function to post
      generateQRKey(invoice, widget.userId, _name,created);
      Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap = await transaction.get(document.reference);
        await transaction.update(freshSnap.reference, {
          'paid': true,
        });
      });
    } else {
      Navigator.of(context).pop();
      throw Exception('Failed to load post');
    }
  }

  getStatusOfPayment() {
    //this function will allow us to know the status of a function
    var statusObject = {
      'status': {'paid': true}
    };
    return statusObject;
  }

  generateQRKey(busid, userid, name,created) {
    var key = busid + userid;
    final collRef = Firestore.instance.collection('Paid');
    DocumentReference documentReference = collRef.document();
    var map = {
      'uid': widget.userId,
      'mykey': key,
      'created': DateTime.now().toUtc().toString(),
      'name': name,
      'timebooking':created
    };
    documentReference.setData(map).then((doc) {
      print('hop ${documentReference.documentID}');
      _docIDForKey = documentReference.documentID;
      print(_docIDForKey);
    }).catchError((error) {
      print(error);
    });
    // return keyy
  }

  Widget _showPhoneNumberInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.phone,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: '0775001001',
            icon: new Icon(
              Icons.phone,
              color: Colors.grey,
            )),
        validator: (value) =>
            value.isEmpty ? 'phoneNumber can\'t be empty' : null,
        onSaved: (value) => _phoneNumber = value,
      ),
    );
  }
  //vaidate the form data

  void _submitPayment(busid, price, document,created) {
    if (!_formKey.currentState.validate()) {
      print('In not saved $_phoneNumber and $_email');
      return;
    }
    print('form is working fine');
    _formKey.currentState.save();
    debugPrint('$_phoneNumber and $_email');
    print('$price $busid');
    _makePayment(_phoneNumber, _email, '$price', busid, 'ecocash', document,created);
    Navigator.of(context).pop();
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
            hintText: 'Email',
            icon: Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value,
      ),
    );
  }

  Widget _showNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
            hintText: 'Enter name',
            icon: Icon(
              Icons.person,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Name  can\'t be empty' : null,
        onSaved: (value) => _name = value,
      ),
    );
  }

  Future<void> _getPaymentDetails(busid, price, document,created) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, //user must enter data
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Please enter extra details for payment'),
            content: SingleChildScrollView(
              child: Container(
                child: Form(
                    key: _formKey,
                    child: ListBody(children: <Widget>[
                      //first form field
                      _showEmailInput(),
                      SizedBox(height: 5.0),
                      _showPhoneNumberInput(),

                      SizedBox(
                        height: 5.0,
                      ),
                      _showNameInput()
                    ])),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                  child: Text('Proceed'),
                  onPressed: () {
                    _submitPayment(busid, price, document,created);
                  })
            ],
          );
        });
  }

  Widget _buildInter(BuildContext context, busid, price, seats, document,created) {
    return Container(
        child: FlatButton(
            child: Text('Continue'),
            color: Colors.blueAccent,
            onPressed: () {
              var totalPrice = seats * price;
              _getPaymentDetails(busid, totalPrice, document,created);
            }));
  }

  Widget _buildBookingList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('Booking').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return new Text('Error:${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text('Loading...');
            default:
              return ListView(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                // return ListTile(
                //    title: new Text(document['busid']),
                //    subtitle: new Text(document['route']),
                // imlink clipart-library.com/images/pToA6ejAc.jpg
                // );
                return (widget.userId == document['userid'])
                    ? Card(
                        child: SingleChildScrollView(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: <
                                Widget>[
                          ListTile(
                            leading: Icon(Icons.verified_user),
                            title: Text('Booked by'),
                            subtitle: Text(document['userid']),
                          ),
                          ListTile(
                            leading: Icon(Icons.card_travel),
                            title: Text(document['operatorid']),
                            subtitle: Text(document['route']),
                          ),
                          ListTile(
                            leading: Icon(Icons.card_travel),
                            title: Text('BusRegistration'),
                            subtitle: Text(document['busid']),
                          ),
                          ListTile(
                            leading: Icon(Icons.time_to_leave),
                            title: Text('Departure'),
                            subtitle: Text('${document['timeDeparture']}'),
                          ),
                          ('${document['created']}' == '')
                              ? 'not available'
                              : ListTile(
                                  leading: Icon(Icons.access_time),
                                  title: Text('Created'),
                                  subtitle: Text('${document['created']}'),
                                ),
                          ('${document['seats']}' == '')
                              ? 'not available'
                              : ListTile(
                                  leading:
                                      Icon(Icons.airline_seat_legroom_normal),
                                  title: Text('Selected seats'),
                                  subtitle: Text('${document['seats']}'),
                                ),

                          Row(
                            children: <Widget>[
                              Text('Price',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  )),
                              SizedBox(width: 25.0),
                              Text(
                                '\$${document['price']}',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.redAccent),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // Row(children: <Widget>[
                          //   Text(
                          //     'Seats Remaining',
                          //     style: TextStyle(fontSize: 15),
                          //   ),
                          //   SizedBox(width: 25),
                          //   Text(
                          //     'Remaining Seats',
                          //     style: TextStyle(fontSize: 20),
                          //   )
                          // ]),
                          ButtonBarTheme(
                            data: null,
                              child: ButtonBar(children: <Widget>[
                            FlatButton(
                                child: Container(
                                  height: 35,
                                  width: 85,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                  child: Center(child: Text("GenerateTic")),
                                ),
                                onPressed: () {
                                  if(document['paid']){
                                    var mykey;  
                                  var val=Firestore.instance.collection('Paid').getDocuments();
                                   val.then((valu){
                                     var value=valu.documents;
                                    for (var doc in value) {
                                           print(doc.documentID);
                                            var information =
                                            '${doc.data['name']}\nNumberofseats${document['seats']}\nTotalPayed \$${document['seats'] * document['price']}';
                                    print(information);
                                    mykey = doc.data['mykey'];
                                      if ('${document['busid'] + widget.userId}' ==
                                        mykey&&'${document['created']}'=='${doc['timebooking']}'
                                        ) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                //if secret key is null try getting it from database
                                                GenerateScreen(information),
                                                
                                            // GenerateScreen((_SecretKey)),
                                          ));
                                    }
                                    }
                                   });
                                   

                                  
                                  // Firestore.instance
                                  //     .collection('Paid')
                                  //     .document(_docIDForKey)
                                  //     .get()
                                  //     .then((DocumentSnapshot ds) {
                                  //   // use ds as a snapshot
                                  //   print(ds.data['mykey']);
                                    
                                  //   mykey = ds.data['mykey'];
                                  //   print('My key is $mykey');
                                  //   var information =
                                  //       '${ds.data['name']}\nNumberofseats${document['seats']}\nTotalPayed \$${document['seats'] * document['price']}';
                                  //   print(information);
                                  //   if ('${document['busid'] + widget.userId}' ==
                                  //       mykey) {
                                  //     Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(
                                  //           builder: (context) =>
                                  //               //if secret key is null try getting it from database
                                  //               GenerateScreen(information),
                                  //           // GenerateScreen((_SecretKey)),
                                  //         ));
                                  //   }
                                  // });
                                }
                                  }
                                  ),
                            FlatButton(
                                child: Text('Pay'),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                            title:
                                                new Text('Proceed to Confirm'),
                                            content: _buildInter(
                                                context,
                                                document['busid'],
                                                document['price'],
                                                document['seats'],
                                                document,
                                                '${document['created']}'),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('Close'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              // FlatButton(
                                              //   child: Text('Proceed'),
                                              //   onPressed: () {
                                              //     debugPrint(
                                              //         'Confirmation implementation');

                                              //     Navigator.of(context).pop();
                                              //   },
                                              // )
                                            ]);
                                      });
                                })
                          ]))
                        ]),
                      ))
                    : Center(child: Text(''));
              }).toList());
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildBookingList(context),
    );
  }
}
