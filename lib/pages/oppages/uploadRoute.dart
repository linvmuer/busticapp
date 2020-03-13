import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class UploadRoutes extends StatefulWidget {
  @override
  _UploadRoutesState createState() => _UploadRoutesState();
}

class _UploadRoutesState extends State<UploadRoutes> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'busid': null,
    'operatorid': null,
    'price': null,
    'route': null,
    'seat': null,
    'timeDeparture': null,
  };

  Widget _buildBusidForm() {
    return TextFormField(
      decoration: InputDecoration(
          icon: Icon(Icons.train),
          labelText: 'Busid', filled: true, fillColor: Colors.white),
      validator: (String value) {
        if (value.isEmpty || value.length <5) {
          return 'please enter valid busid';
        }
      },
      onSaved: (String value) {
        _formData['busid'] = value;
      },
    );
  }
  void _submitForm(){
    if(!_formKey.currentState.validate()){

    }
      print('before save');
      print(_formData);
      _formKey.currentState.save();
      print('aftere save');
      print(_formData);
       final collref = Firestore.instance.collection('operator_test');
    DocumentReference documentReference = collref.document();
    var map = {
      
      'operatorid': _formData['operatorid'],
      'route': _formData['route'],
      'busid': _formData['busid'],
      'timeDeparture': _formData['timeDeparture'],
      'price': _formData['price'],
      
      'seats':_formData['seats'],
      
    };
    
    documentReference.setData(map).then((doc) {
      print('hop ${documentReference.documentID}');
      var docIDForKey = documentReference.documentID;
      print(docIDForKey);
    }).catchError((error) {
      print(error);
    });

  }
  Widget _buildOperatoridForm() {
    return TextFormField(
      decoration: InputDecoration(
        icon: Icon(Icons.account_box),
          labelText: 'Operatorid', filled: true, fillColor: Colors.white),
      validator: (String value) {
        if (value.isEmpty || value.length < 5) {
          return 'please enter valid operatorid';
        }
      },
      onSaved: (String value) {
        _formData['operatorid'] = value;
      },
    );
  }

  Widget _buildPriceForm() {
    return TextFormField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          icon: Icon(Icons.monetization_on),
          labelText: 'Price',
          filled: true,
          fillColor: Colors.white),
      validator: (String value) {
        if (value.isEmpty) {
          return 'please enter valid price';
        }
      },
      onSaved: (String value) {
        _formData['price'] = num.parse(value);
      },
    );
  }

  Widget _buildSeatForm() {
    return TextFormField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          icon: Icon(Icons.airline_seat_legroom_normal),
          labelText: 'Seat',
          filled: true,
          fillColor: Colors.white),
      validator: (String value) {
        if (value.isEmpty ) {
          return 'please enter valid seat capacity';
        }
      },
      onSaved: (String value) {
        _formData['seats'] = num.parse(value);
      },
    );
  }
  Widget _buildRouteForm(){
     return TextFormField(

      decoration: InputDecoration(
          icon: Icon(Icons.map),
          labelText: 'Route',
          hintText: 'mutare-hare',
          filled: true,
          fillColor: Colors.white),
      validator: (String value) {
        if (value.isEmpty || value.length < 5) {
          return 'please enter valid route';
        }
      },
      onSaved: (String value) {
        _formData['route'] =value;
      },
    );
  }
  Widget dateTime() {
    return FlatButton(
        onPressed: () {
          DatePicker.showDateTimePicker(context, showTitleActions: true,
              onChanged: (date) {
            print('change $date');
          }, onConfirm: (date) {
            print('confirm $date');
            setState(() {
              _formData['timeDeparture'] = date;
              print(_formData['timeDeparture']);
              print(
                  'type of _timedeparture is ${_formData['timeDeparture'].toString().length}');
            });
          }, currentTime: DateTime.now(), locale: LocaleType.en);
        },
        child: Text('Tap To Select', style: TextStyle(color: Colors.blue)));
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return Container(
      padding: EdgeInsets.all(10),
      child: Center(
        child: SingleChildScrollView(
            child: Container(
          width: targetWidth,
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text('Enter busid'),
                _buildBusidForm(),
                SizedBox(
                  height: 25,
                  child: Text('Enter operatorid'),
                ),
                _buildOperatoridForm(),
                SizedBox(
                  height: 25,
                  child: Text('Enter Price'),
                ),
                _buildPriceForm(),
                SizedBox(
                  height: 25,
                  child: Text('Enter Seat Capacity'),
                ),
                _buildSeatForm(),
                SizedBox(height: 25,
                child: Text('Enter route'),),
                _buildRouteForm(),
                Padding(
                  padding: EdgeInsets.all(7),
                  child: SizedBox(
                    height: 20,
                    child: Text(
                      'Please Enter Time of departure',
                    ),
                  ),
                ),
                    Center(
                    child: dateTime(),

                  ),
                SizedBox(height: 15,),
                Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(
                        left: 30.0, right: 30.0, top: 20.0),
                    alignment: Alignment.center,
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new FlatButton(
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0),
                            ),
                            color: Colors.blue,
                            onPressed: () {
                              _submitForm();
                              print('pressed upload');
                            },
                            child: new Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 20.0,
                              ),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new Expanded(
                                    child: Text(
                                      "Upload Route",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
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
              ],
            ),
          ),
        )),
      ),
    );
  
}}