import '../pages/bookings.dart';
import '../pages/oppages/scan_screen.dart';
import '../pages/oppages/uploadRoute.dart';
import '../pages/searchContainer.dart';
import 'package:flutter/material.dart';
import '../services/authentication.dart';







class OHomePage extends StatefulWidget {
  OHomePage({Key key, this.auth, this.userId, this.onSignedOut,this.email})
      : super(key: key);
  final String email;
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;
  

  @override
  State<StatefulWidget> createState() => new _OHomePageState();
}

class _OHomePageState extends State<OHomePage> with SingleTickerProviderStateMixin{
  

 
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

 
  final List<Tab> myTabs=<Tab>[
    Tab(
             text: 'Upload Routes',),
             
             Tab(
             text:'Monitor Routes'),
        
  ];
  TabController _tabController;
  //Query _todoQuery;

  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    _checkEmailVerification();

    _tabController=TabController(vsync:this,length:myTabs.length);
  }
  @override
  void dispose(){
    _tabController.dispose();
    super.dispose();
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      
        appBar: new AppBar(
          title:  Text('dashboard'),
         bottom: TabBar(
           controller: _tabController,
           tabs:myTabs
         ),
        ),
        drawer: Drawer(
          
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName:Text("Placeholder name"),
                accountEmail: Text("Placehoder email"),
                currentAccountPicture: CircleAvatar(
                  backgroundColor:Colors.orangeAccent,
                  child:Text('MyA/C')
                ),
              ),
             
              // ListTile(title: Text('TestQRgen'), onTap: () {
              //   // Navigator.of(context).pushNamed('/genQR');
              //   Navigator.push(context,MaterialPageRoute(builder:(context)=>GenerateScreen("Test String x")), );
              // }),
              ListTile(
                leading: Icon(Icons.card_travel),
                title: Text('Scan Ticket'),
                
                onTap: (){
                  Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
             ScanScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.close),
                title: Text('LogOut'),
                onTap: () {
                  // Update the stater of the app
                  // ...
                  _signOut();
                },
              ),
            ],
          ),
        ),
        body:TabBarView(
          controller: _tabController,
          children:<Widget>[
            
             UploadRoutes(),
             Placeholder()
          
          ]
        )
        );
  }
}
class Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child:Center(
        child:Text('Monitor Routes Will Go Here')
      )
    );
  }
}