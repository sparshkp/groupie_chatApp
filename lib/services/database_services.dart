import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  // saving the userdata
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  // getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }
  // getting user groups
  getUserGroups() async{
  return userCollection.doc(uid).snapshots();
  }

  // creating the groups 
  Future createGroups(String username,String id,String groupName) async{
   DocumentReference groupdocumentReference =await groupCollection.add({
    "groupname" : groupName,
    "groupIcon" :"",
    "admin":"${id}_$username",
    "groupId":[],
    "members":[],
    "recentmessage":"",
    "recentmessageSender":"",
   });
   //update the memebers
   await groupdocumentReference.update({
   "members":FieldValue.arrayUnion(["${uid}_$username"]),
   "groupId":groupdocumentReference.id
   });

   DocumentReference userdocumentReference = userCollection.doc(uid);
   return await userdocumentReference.update({
    "groups": FieldValue.arrayUnion(["${groupdocumentReference.id}_$groupName"])
   });
  }

  // getting the chats 
  getchats(String groupId) async {
    return groupCollection
    .doc(groupId)
    .collection("messages")
    .orderBy("time")
    .snapshots();
  }
  // getting the admin info
  Future getAdmin(String groupId) async{
     DocumentReference d =groupCollection.doc(groupId);
     DocumentSnapshot documentSnapshot =await d.get();
     return documentSnapshot['admin'];

  }

  // get the memebers
  getGroupMembers(String groupId) async{
  return groupCollection.doc(groupId).snapshots();
  }
  // search 
  searchByName(String groupName){
  return groupCollection.where(groupName,isEqualTo: groupName).get();
  }
  // function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }
  // send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }
}