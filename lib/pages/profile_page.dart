import 'package:flutter/material.dart';
import 'package:groupie_chat_app/auth/home_page.dart';
import 'package:groupie_chat_app/auth/login_page.dart';
import 'package:groupie_chat_app/services/auth_services.dart';
import 'package:groupie_chat_app/widgets/widgets.dart';


// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  String name="";
  String email="";
  ProfilePage({super.key, required this.name,required this.email});
 
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService=AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: Text("Profile",
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.bold,
          color: Colors.white)
          ),
      ),
      drawer: Drawer(
        elevation: 0,
        child: ListView(
          children:  <Widget>[
             Icon(Icons.account_circle,color: Colors.grey[700],size: 150,),
             SizedBox(height: 10,),
             Text(
              widget.name,
             textAlign: TextAlign.center,
             style: TextStyle(
              fontWeight: FontWeight.bold,),),
              SizedBox(height: 30,),
              Divider(
                height: 2,
              ),
              ListTile(
                onTap: () {
                  nextScreen(context, HomePage());
                },
                contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                leading: Icon(Icons.group),
                title: Text("Groups",style: TextStyle(color: Colors.black),),
              ),
              ListTile(
                onTap: () {},
                selected: true,
                selectedColor: Theme.of(context).primaryColor,
                contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                leading: Icon(Icons.person),
                title: Text("Profile",style: TextStyle(color: Colors.black),),
              ),
              ListTile(
                onTap: () async{
                  showDialog(
                    barrierDismissible: false,
                    context: context, 
                    builder: ((context) {
                   return AlertDialog(
                    title: Text("Logout"),
                    content: Text("Are you sure you want to logout?"),
                    actions: [
                      IconButton(onPressed: (){
                        Navigator.pop(context);
                      }, icon: Icon(
                        Icons.cancel_rounded,
                      color: Colors.red,)
                      ),
                      IconButton(
                        onPressed: () async{
                        await authService.signOut();
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: ((context) => LoginPage())), 
                        (route) => false);
                      }, icon: Icon(
                        Icons.done_outlined,
                        color: Colors.green,
                        )),
                    ],
                   );
                  }));
                 
                },
                contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                leading: Icon(Icons.exit_to_app),
                title: Text("Logout",style: TextStyle(color: Colors.black),),
              ),


          ],
        ),
       
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40,vertical: 70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
           Icon(Icons.account_circle,size: 200,color: Colors.grey,),
           SizedBox(height: 15,),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Name",style: TextStyle(fontSize: 17),),
             Text(widget.name,style: TextStyle(fontSize: 17),),
            ],
           ),
           Divider(
            height: 10,
           ),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Email",style: TextStyle(fontSize: 17),),
             Text(widget.email,style: TextStyle(fontSize: 17),),
            ],
           ),
          ],
        ) 
        ),
      
      
    );
  }
}