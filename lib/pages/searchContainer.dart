import 'package:flutter/material.dart';
import 'availablebus.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class SearchContainer extends StatefulWidget {
  final String userId;
  SearchContainer(this.userId);
  @override
  _SearchContainerState createState() => _SearchContainerState();
}

class _SearchContainerState extends State<SearchContainer> {
  final Map<String, dynamic> _formData = {'from': null, 'seats': null};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _fromFocusNode = FocusNode();
  final _toFocusNode = FocusNode();
  

  var _mockLocations = [
    "mutare",
    "beitbridge",
    "bulawayo",
    "chipinge",
    "chiredzi",
    "gweru",
    "harare"
  ];
  var _mockTo = "mutare";
  var _mockFrom = "harare";
  String _departureTime;
  Widget _buildFromTextField() {
    return Container(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 20.0,
        ),
        child: TextFormField(
          focusNode: _fromFocusNode,
          decoration: InputDecoration(
            icon: Icon(Icons.location_city),
            labelText: 'From',
            hintText: 'mutare',
            fillColor: Colors.white,
            filled: true,
          ),
          validator: (String value) {
            if (value.isEmpty || value.length < 4) {
              return 'From is required, you have to start somewhere';
            }
          },
          onSaved: (String value) {
            _formData['from'] = value;
          },
        ));
  }

  Widget dateTime() {
    return FlatButton(
        onPressed: () {
         
          DatePicker.showDateTimePicker(context,
              showTitleActions: true,
             onChanged: (date) {
            print('change $date');
          }, onConfirm: (date) {
            print('confirm $date');
            setState(() {
                          this._departureTime=date.toString();
                          print(_departureTime);
                          print('type of _timedeparture is ${_departureTime.length}');
                        });
          }, currentTime: DateTime.now(), locale: LocaleType.en);
        },
        child: Text('Tap To Select',
            style: TextStyle(color: Colors.blue.shade100,fontSize: 20)));
  }

  Widget _buildNumberofSeatsTextField() {
    return Container(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 20.0,
        ),
        child: TextFormField(
          focusNode: _toFocusNode,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            icon: Icon(Icons.airline_seat_legroom_normal),
            hintText: '1',
            labelText: '',
          ),
          validator: (String value) {
            if (value.isEmpty ) {
              return 'Please enter number of seats ';
            }
          },
          onSaved: (String value) {
            _formData['seats'] = int.parse(value);
          },
        ));
  }

  void _SubmitSearchForm() {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                AvailablePageBus(_mockFrom, _mockTo, widget.userId,_departureTime,_formData['seats'])));
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    final Widget pageContent = GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          margin: EdgeInsets.all(10.0),
          child: Form(
              key: _formKey,
              child: ListView(
                //padding: EdgeInsets.symmetric(horizontal:targetPadding/2),
                children: <Widget>[
                  // _buildFromTextField(),
                  // SizedBox(
                  //   height: 5.0,
                  // ),
                  // _buildToTextField(),
                  Text(
                    'Select current location',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Center(
                    child: DropdownButton<String>(
                      items: _mockLocations.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          //  child: Text(dropDownStringItem),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Icon(Icons.location_city),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(dropDownStringItem)
                              ]),
                        );
                      }).toList(),
                      onChanged: (String newValue) {
                        setState(() {
                          this._mockFrom = newValue;
                        });
                      },
                      value: _mockFrom,
                    ),
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  Text(
                    'Where would \nyou want to go?',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  //the to dropdown
                  Center(
                    child: DropdownButton<String>(
                      items: _mockLocations.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          //  child: Text(dropDownStringItem),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Icon(Icons.location_city),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(dropDownStringItem)
                              ]),
                        );
                      }).toList(),
                      onChanged: (String newValue) {
                        setState(() {
                          this._mockTo = newValue;
                        });
                      },
                      value: _mockTo,
                    ),
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  Text(
                    'Select Time',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Center(
                    child: dateTime(),

                  ),
                  SizedBox(height:8),
                  Text(
                    'Enter number of seats \nyou want',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Center(
                      child:  _buildNumberofSeatsTextField(),
                  ),

                      
                  new Container(
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
                              // _temperalRoute();
                              _SubmitSearchForm();
                              print('pressed search');
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
                                      "SEARCH",
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
              )),
        ));
    return Container(
      //appBar:AppBar(title: Text('Search Route'),),

      child: pageContent,
    );
  }
}
