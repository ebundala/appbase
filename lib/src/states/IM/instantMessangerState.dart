//import "package:dartson/dartson.dart";
import "../user/userState.dart" show userInfo;

class Participant extends userInfo {
  String uid;
  String userName;
  String avator;
  final bool status = true;
  //participant({uid,name,avator}):super(uid:uid,userName:name,avator:avator);
}

class NonParticipant extends Participant {
  String uid;
  String userName;
  String avator;
  final bool status = false;
  //nonParticipant({uid,name,avator}):super(uid:uid,name:name,avator:avator);
}

class Participate {
  String chatId;
  userInfo user;
  //participate({this.chatId,this.user});
}

class Message {
  int timestamp;
  String messageId;
  String messageText;
  String imageUrl;
  Map<String, dynamic> metadata = {};
  Participant sender;
  String chatId;
  //message({this.chatId,this.messageId,this.sender});

}

class Chat {
  String lastMessage;
  int timestamp;
  String type;
  String title;
  dynamic metadata;
  String chatId;
  Participant creator;
  Map<String, Participant> participants = {};
  // chat({this.chatId,this.creator}){
  // participants[creator.uid]=(new participant()
  // 							..uid=creator.uid
  // 							..name=creator.name
  // 							..avator=creator.avator	);
  // }
}
