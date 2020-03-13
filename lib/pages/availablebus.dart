import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:core';

class AvailablePageBus extends StatefulWidget {
  final String from;
  final String to;
  final String userId;
  final String datetime;
  final int seats;

  AvailablePageBus(this.from, this.to, this.userId, this.datetime,this.seats);
  @override
  _AvailablePageBusState createState() => _AvailablePageBusState();
}

class _AvailablePageBusState extends State<AvailablePageBus> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //if this fails to run then put it back into the onpressed function of each onbooking function
  void submitBooking(uid, busid, route, operatorid, price, time,seats) async {
    //(widget.userId,documentData['busid'],documentData['route'],documentData['operatorid'],documentData['price'],timex)
    //this is a placeholder map please put the proper map data
    var bookingid;
    final collRef = Firestore.instance.collection('Booking');
    DocumentReference documentReference = collRef.document();
    var map = {
      'userid': uid,
      'operatorid': operatorid,
      'route': route,
      'busid': busid,
      'timeDeparture': time,
      'price': price,
      'created': DateTime.now().toUtc().toString(),
      'seats':seats,
      'paid':false
    };
    documentReference.setData(map).then((doc) {
      print('hop ${documentReference.documentID}');
      bookingid = documentReference.documentID;
      print(bookingid);
    }).catchError((error) {
      print(error);
    });
    return bookingid;
  }

  Widget _buildRouteItem(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('operator_test').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return new Text('Error:${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text('Loading...');
            default:
              return ListView(
                  children: snapshot.data.documents
                      .map((DocumentSnapshot documentData) {
                return ((documentData['route'] ==
                            (widget.from + '-' + widget.to)&&
                        documentData['timeDeparture'].toString() ==
                            widget.datetime))
                    ? Card(
                        child: SingleChildScrollView(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: <
                                Widget>[
                          ListTile(
                            leading: Icon(Icons.card_travel),
                            title: Text(documentData['operatorid']),
                            subtitle: Text(documentData['route']),
                          ),
                          ListTile(
                            leading: Icon(Icons.card_travel),
                            title: Text('BusRegistration'),
                            subtitle: Text(documentData['busid']),
                          ),
                          ListTile(
                              leading: Icon(Icons.time_to_leave),
                              title: Text('Departure-Time'),
                              subtitle: Text(
                                //this fixed the int is not subtype of string error
                                '${documentData['timeDeparture']}',
                              )),
                          Row(
                            children: <Widget>[
                              Text('Price',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  )),
                              SizedBox(width: 25.0),
                              Text(
                                '${documentData['price']}',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.redAccent),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(children: <Widget>[
                            Text(
                              'Seats Remaining',
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(width: 25),
                            Text(
                              '${documentData['seats']}',
                              style: TextStyle(fontSize: 20),
                            )
                          ]),
                          ButtonTheme.bar(
                              child: ButtonBar(children: <Widget>[
                            FlatButton(
                                child: Text('Book bus'),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                            title: new Text('Proceed to book'),
                                            content: new Text(
                                                'Are you sure you want to book this bus?'),
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
                                                  //var val=documentData['status']['filled'];
                                                  debugPrint(
                                                      'Booking Implementation');
                                                  var timex = documentData[
                                                      'timeDeparture'];
                                                  var seats=widget.seats;    
                                                  print(
                                                      documentData.documentID);
                                                  Firestore.instance.runTransaction((transaction)async{
                                                      DocumentSnapshot freshSnap=
                                                      await transaction.get(documentData.reference);
                                                      await transaction.update(freshSnap.reference, {
                                                          'seats':freshSnap['seats']-seats,
                                                      });
                                                  });
                                                  var bookid = submitBooking(
                                                      widget.userId,
                                                      documentData['busid'],
                                                      documentData['route'],
                                                      documentData[
                                                          'operatorid'],
                                                      documentData['price'],
                                                      timex,
                                                      seats); //let submmit book get data and then pass it into the map
                                                Navigator.of(context).pop();
                                                },
                                              )
                                            ]);
                                      });
                                })
                          ]))
                        ]),
                      ))
                    : Center(
                        child: Text(''),//please implement the cases when someone does not match the requirements
                      );
              }).toList());
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(child: _buildRouteItem(context)));
  }
}
