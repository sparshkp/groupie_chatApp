import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groupie_chat_app/pages/group_info.dart';
import 'package:groupie_chat_app/services/database_services.dart';
import 'package:groupie_chat_app/widgets/message_tile.dart';
import 'package:groupie_chat_app/widgets/widgets.dart';

class ChatPage extends StatefulWidget {
  final String groupName;
  final String groupId;
  final String userName;
  const ChatPage({super.key, required this.groupName, required this.groupId, required this.userName});
 
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot> ? chats;
  String admin="";
  TextEditingController messagecontroller =TextEditingController();
  @override
  void initState() {
    super.initState();
    getChatandAdmin();
  }
  // get the chat and admin info 
  getChatandAdmin(){
    DatabaseService().getchats(widget.groupId).then((val){
      setState(() {
        chats=val;
      });
    });

    DatabaseService().getAdmin(widget.groupId).then((val){
      setState(() {
        admin=val;
      });
    });


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName,textAlign: TextAlign.left,),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(onPressed: (){
            nextScreen(context,GroupInfo(
              groupId: widget.groupId,
              groupName: widget.groupName,
              adminName: admin,
              ));
          }, icon: Icon(Icons.info_outlined,color: Colors.white,))
        ],
      ),
      
      body: Stack(
        children:<Widget> [
          //chat messages 
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 18),
              color: Colors.grey[500],
              width: MediaQuery.of(context).size.width,
              height: 80,
              child: Row(
                children: [
                  Expanded(child:TextFormField(
                    controller: messagecontroller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Send a message...",
                      hintStyle: TextStyle(fontSize: 17,color: Colors.white),
                      border: InputBorder.none
                    ),
                  )),
                  SizedBox(width: 12,),
                  GestureDetector(
                    onTap: () {
                      sendMessages();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(Icons.send_rounded,color: Colors.white,),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      )

    );
  }
  chatMessages() {
    return StreamBuilder(
      stream: chats, 
      builder: (context,  AsyncSnapshot snapshot) {
        return snapshot.hasData ?
        ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context,index){
          return MessageTile(
            sender: snapshot.data.docs[index]['sender'], 
            message: snapshot.data.docs[index]['message'], 
            sentByMe: widget.userName==snapshot.data.docs[index]['sender']);
          }
        )
        :Container();
      },
      );
}
sendMessages(){
  if(messagecontroller.text.isNotEmpty){
    Map<String ,dynamic> chatMessageMap= {
      "message" :messagecontroller.text,
      "sender" :widget.userName,
      "time" :DateTime.now().millisecondsSinceEpoch

    };
    DatabaseService().sendMessage(widget.groupId,chatMessageMap);
    setState(() {
      messagecontroller.clear();
    });
  }
}
}

