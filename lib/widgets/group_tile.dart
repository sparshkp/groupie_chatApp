import 'package:flutter/material.dart';
import 'package:groupie_chat_app/pages/chat_page.dart';
import 'package:groupie_chat_app/widgets/widgets.dart';


class GroupTile extends StatefulWidget {
  final String groupName;
  final String groupId;
  final String userName;

  const GroupTile({super.key, required this.groupName, required this.groupId, required this.userName});

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(context, ChatPage(
          groupName: widget.groupName,
          groupId: widget.groupId,
          userName: widget.userName,
        ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
        child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(widget.groupName.substring(0,1).toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            
          ),),
        ),
        title: Text(widget.groupName,style: TextStyle(fontWeight: FontWeight.bold),),
        subtitle: Text("Join the conversation as ${widget.userName}",style: TextStyle(fontSize: 13),),
        ),
    
      ),
    );
    
  }
}