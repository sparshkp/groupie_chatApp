import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:groupie_chat_app/auth/login_page.dart';
import 'package:groupie_chat_app/helper/helper_function.dart';
import 'package:groupie_chat_app/auth/home_page.dart';
import 'package:groupie_chat_app/shared/constants.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb)
  {
    // initialize the firebase for web
    await Firebase.initializeApp(
       options :FirebaseOptions(
      apiKey: "AIzaSyBB856lHY44f7riD-V9MfX2-EEWOsQPZAg", 
      appId: "1:792861245990:web:d341daacdab4d300f1dce7", 
      messagingSenderId: "792861245990", 
      projectId: "chatappgroupie-21410"
      ));
    
    
    
  }
  else{
    // initialize the firebase for the android and ios
   await Firebase.initializeApp();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
   bool _isSignedIn =false;
  @override
  void initState() {
  
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async{
  await HelperFunctions.getUserLoggedInStatus().then((value) {
    if(value!=null){
      setState(() {
        _isSignedIn = value;
      });
    }
  });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Constants().primaryColor,
        scaffoldBackgroundColor: Colors.white
      ),
      debugShowCheckedModeBanner: false,
      home: _isSignedIn ? HomePage(): LoginPage(),
    );
  }
}