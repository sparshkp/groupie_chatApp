import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupie_chat_app/auth/home_page.dart';
import 'package:groupie_chat_app/services/database_services.dart';
import 'package:groupie_chat_app/widgets/widgets.dart';

class GroupInfo extends StatefulWidget {
  final String groupName;
  final String groupId;
  final String adminName;
  const GroupInfo({super.key, required this.groupName, required this.groupId, required this.adminName});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}


class _GroupInfoState extends State<GroupInfo> {
  @override
  // ignore: override_on_non_overriding_member
  Stream? members;
  @override
  void initState() {
    getMembers();
    super.initState();
  }

  getMembers()async{
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
    .getGroupMembers(widget.groupId)
    .then((val){
    setState(() {
      members =val;
    });
    });
  }
  String getName(String r){
    return r.substring(r.indexOf("_")+1);
  }
  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group Info"),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(onPressed: (){
            showDialog(
                    barrierDismissible: false,
                    context: context, 
                    builder: ((context) {
                   return AlertDialog(
                    title: Text("Exit"),
                    content: Text("Are you sure you want to exit the group?"),
                    actions: [
                      IconButton(onPressed: (){
                        Navigator.pop(context);
                      }, icon: Icon(
                        Icons.cancel_rounded,
                      color: Colors.red,)
                      ),
                      IconButton(
                        onPressed: () async{
                        DatabaseService (uid: FirebaseAuth.instance.currentUser!.uid).
                        toggleGroupJoin(widget.groupId, getName(widget.adminName), widget.groupName).whenComplete(() {
                         nextScreenReplace(context, HomePage());
                        });
                      }, icon: Icon(
                        Icons.done_outlined,
                        color: Colors.green,
                        )),
                    ],
                   );
                  }));
          }, icon: Icon(Icons.exit_to_app))
          ],
    ),
    body: Container(
      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).primaryColor.withOpacity(0.2), 
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(widget.groupName.substring(0,1).toUpperCase(),
                  style: TextStyle(
                   fontWeight: FontWeight.bold,
                   color: Colors.white,
            ),),
                ),
                SizedBox(height: 20),
                Column(  
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Group: ${widget.groupName}",
                      style: TextStyle(
                        fontWeight: FontWeight.w500),),
                    ),
                      SizedBox(height: 5,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text("Admin: ${getName(widget.adminName)}"),
                      )
                  ],
                )
                ],
            ),
          ),
          membersList(),
        ],
      ),
    ),
    );
  }
  membersList(){
    return StreamBuilder(
      stream: members,
       builder: (context,  AsyncSnapshot snapshot) {
         if(snapshot.hasData){
         if(snapshot.data['members']!=null){
         if(snapshot.data['members'].length!=0){
         return ListView.builder(
          itemCount: snapshot.data['members'].length,
          shrinkWrap: true,
          itemBuilder: (context,index){
           return Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
            leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(getName(snapshot.data['members'][index]).substring(0,1).toUpperCase(),
                  style: TextStyle(
                   fontWeight: FontWeight.bold,
                   color: Colors.white,
            ),),
            ),
            title: Text(getName(snapshot.data['members'][index])),
            subtitle: Text(getId(snapshot.data['members'][index])),
            ),
           );
          });
         }
         else{
          return Center(child: Text("NO Members Present"),);
         }
         }
         else{
          return Center(child: Text("NO Members Present"),);
         }
         }
         else{
          return Center(
            child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),
          );
         }
       },);
  }
}