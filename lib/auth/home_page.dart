// ignore_for_file: dead_code

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupie_chat_app/auth/login_page.dart';
import 'package:groupie_chat_app/auth/search_page.dart';
import 'package:groupie_chat_app/helper/helper_function.dart';
import 'package:groupie_chat_app/pages/profile_page.dart';
import 'package:groupie_chat_app/services/auth_services.dart';
import 'package:groupie_chat_app/services/database_services.dart';
import 'package:groupie_chat_app/widgets/group_tile.dart';
import 'package:groupie_chat_app/widgets/widgets.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username ="";
  String email="";
  AuthService authServices =AuthService();
  Stream? groups;
  bool _isloading= false;
  String groupname="";

  // string manipulation
  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }
  String getName(String res){
    return res.substring(res.indexOf("_")+1);
  }

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  gettingUserData() async{
    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
      username =value!;
    });
    });
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
      email =value!;
    });
    });
    // getting the list of snapshots in the stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getUserGroups().then((snapshot){
      setState(() {
        groups=snapshot;
      });
    });
  }
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        elevation: 0,
        actions:  [
          IconButton(onPressed: (){
            nextScreen(context, SearchPage());
          }, icon: Icon(Icons.search))
        ],
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Groups",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
       ),
       drawer: Drawer(
        elevation: 0,
        child: ListView(
          children:  <Widget>[
             Icon(Icons.account_circle,color: Colors.grey[700],size: 150,),
             SizedBox(height: 10,),
             Text(username,
             textAlign: TextAlign.center,
             style: TextStyle(
              fontWeight: FontWeight.bold,),),
              SizedBox(height: 30,),
              Divider(
                height: 2,
              ),
              ListTile(
                onTap: () {},
                contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                selected: true,
                selectedColor: Theme.of(context).primaryColor,
                leading: Icon(Icons.group),
                title: Text("Groups",style: TextStyle(color: Colors.black),),
              ),
              ListTile(
                onTap: () {
                    nextScreenReplace(context, ProfilePage(name: username,email:email));
                },
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
                        await authServices.signOut();
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
        body: groupList(),
        floatingActionButton: FloatingActionButton(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: (){
           popUpDialogue(context);
            
          },
          child: Icon(Icons.add,size: 30,)),
    );
  }

    popUpDialogue(BuildContext context){
    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: ((context) {
         return StatefulBuilder(
          builder: (context, setState) {
           return AlertDialog(
                 title: Text("Create a new group",textAlign: TextAlign.left,),
           content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isloading == true ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),):
              TextField(
                onChanged: (value) {
                  groupname =value;
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(20),
                  ),),
         
              )
            ],
           ),
           actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              
              onPressed: (){
                Navigator.pop(context);
              }, child: Text("CANCEL")),
              ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              
              onPressed: ()async{
                if(groupname !=""){
                 setState(() {
                   _isloading =true;
                 });
                 DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).
                 createGroups(username, FirebaseAuth.instance.currentUser!.uid, groupname).
                 whenComplete(() {
                  _isloading=false;
                 });
                 Navigator.pop(context);
                 showSnackbar(context, Colors.green, "Group created successfully");
                }
              
              }, child: Text("CREATE")),
         
           ],
            );
            }
         );
      }));
    }
    
    groupList(){
     return StreamBuilder(
      stream: groups,
       builder: (context , AsyncSnapshot snapshot){
        // make some checks
        if(snapshot.hasData){
         if(snapshot.data['groups']!=null){
         if(snapshot.data['groups'].length!=0){
           return ListView.builder(
            itemCount: snapshot.data['groups'].length,
            itemBuilder: (context, index) {
              int revIndex = snapshot.data['groups'].length -index-1;
              return GroupTile(
              groupName:getName(snapshot.data['groups'][revIndex]), 
              groupId: getId(snapshot.data['groups'][revIndex]), 
              userName: snapshot.data['fullName'],
              );
            });
         }else{
          return noGroupWidget();
         }
         }
         else{
          return noGroupWidget();
         }
        }
        else{
          return Center(
            child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),
          );
        }
       }
       );
    }
    noGroupWidget(){
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                popUpDialogue(context);
              },
              child: Icon(Icons.add_circle_outlined,
              size: 75,
              color: Colors.grey[700]
              ),
            ),
            SizedBox(height: 20,),
            Text("You haven't joined any groups ,tap on the icon to create a group or search from the top search bar ",
            textAlign: TextAlign.center,)
          ],
        ),
      );
    }
  }
