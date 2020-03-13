import 'package:flutter/material.dart';
import './services/authentication.dart';
import './pages/root_page.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {

  
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title:'bustick',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
        //  '/genQR':(BuildContext context)=>GenerateScreen(),

         },
        home: new RootPage(auth: new Auth()));
  }
}
