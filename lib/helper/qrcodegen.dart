import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class GenerateScreen extends StatefulWidget {
  final  String secretKey;
  GenerateScreen(this.secretKey);
  @override
  _GenerateScreenState createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;

  GlobalKey globalKey = new GlobalKey();
 // String _dataString=widget.secretKey ;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Scan')),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert,),
            onPressed:(){}// _captureAndSharePng,
          )
        ],
      ),
      body:_contentWidget()
    );
  }

  Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      final channel = const MethodChannel('channel:me.alfian.share/share');
      channel.invokeMethod('shareFile', 'image.png');
    } catch (e) {
      print(e.toString());
    }
  }

  _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: _topSectionTopPadding,
              left: 20.0,
              right: 10.0,
              bottom: _topSectionBottomPadding,
            ),
            child: Container(
              height: _topSectionHeight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child:Center(child:Text('Scan Ticket'
                    ,style: TextStyle(
                      fontSize: 35,
                      fontFamily: "Roboto"
                    ),))
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 10.0),
                  //   child: FlatButton(
                  //     child: Text("Enter key"),
                  //     onPressed: () {
                  //       setState(() {
                  //         _dataString = widget.secretKey;
                  //         _inputErrorText = null;
                  //       });
                  //     },
                  //   ),
                  // )
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: globalKey,
                child: QrImage(
                  data: widget.secretKey,
                  size: 0.5 * bodyHeight,

                  // onError: (ex) {
                  //   print("[QR] ERROR - $ex");
                  //   setState(() {
                  //     // _inputErrorText =
                  //     //     "Error! Maybe your input value is too long?";
                  //   });
                  // },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
