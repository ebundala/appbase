
import "dart:async";
import "package:logging/logging.dart";
import "package:redux/redux.dart";
import "package:firebase_dart/firebase_dart.dart";

// instant messanger component
import "../states/state.dart";
import "../states/actionsTypes.dart";
//import "../states/user/userState.dart";
import "../states/IM/instantMessangerState.dart";
//import "../states/store.dart";


class InstantMessanger {
	Store<AppState> store;
	final Logger log = new Logger('InstantMessanger');
	final ref;
	var _chatRef;
	var _messagesRef;
	InstantMessanger({this.store,this.ref}){
		_chatRef=ref.child("chats");
		_messagesRef=ref.child("messages");
	}
	

	Future<Chat> createChat(Chat chat) async{
		var chatRef=_chatRef.child(chat.chatId);
		Chat newChat;
		try{

			var chatVal =await chatRef.get();
			if(chatVal==null){
              await chatRef.set({
              		"lastMessage":chat.lastMessage,
					"timestamp":ServerValue.timestamp,
					"type":chat.type,
					"title":chat.title,
					"metadata":chat.metadata,
					"chatId":chat.chatId,
					"creator":{
						"uid":chat.creator.uid,
						"userName":chat.creator.userName,
						"avator":chat.creator.avator,
						"status":true
					},
					"participants":{
						"${chat.creator.uid}":{
										"uid":chat.creator.uid,
										"userName":chat.creator.userName,
										"avator":chat.creator.avator,
										"status":true
									},
									
					}

              	});
              chatVal =await chatRef.get();
              if(chatVal==null){
              	throw(new AppError(actionType:ActionsTypes.createChat,message:"failed to create new chat",payload:chat,));
              }
			}
             newChat=_chatInfoChanged(chatVal);

			store.dispatch(new Action(type:ActionsTypes.createChat,data:newChat));
			return newChat;
			}catch(e,st){
			logError(e,ActionsTypes.createChat,st);
				return new Chat();
		}
     
      
     
	}

	Chat _chatInfoChanged(dynamic chatData){
	    	Chat newChat=(new Chat()
	                            ..chatId=chatData["chatId"]
	                            ..timestamp=chatData["timestamp"]
	                            ..type=chatData["type"]
	                            ..lastMessage=chatData["lastMessage"]
	                            ..metadata=chatData["metadata"]
	                            );
	    	        
		             if(chatData["creator"]!=null){
		             	newChat.creator=(new Participant()
	                                        ..uid=chatData["creator"]["uid"]
	                                        ..userName=chatData["creator"]["userName"]
	                                        ..avator=chatData["creator"]["avator"]);
		             }
		             if(chatData["participants"]!=null){
		             	
		             	chatData["participants"].forEach((key, item) {
		             		newChat.participants[key]=item["status"]?
		             		(new Participant()
		             			..uid=item["uid"]
	                            ..userName=item["userName"]
	                            ..avator=item["avator"]
		             			):
		             		(new NonParticipant()
		             			..uid=item["uid"]
	                            ..userName=item["userName"]
	                            ..avator=item["avator"]
		             			);
		             		});
		             }
		            
		             return newChat;
		         }
	Message _messageInfoChanged(dynamic messageData){
		Message newMessage=(new Message()
	                            ..chatId=messageData["chatId"]
	                            ..timestamp=messageData["timestamp"]
	                            ..metadata=messageData["metadata"]
	                            ..messageId=messageData["messageId"]
	                            ..messageText=messageData["messageText"]
	                            ..imageUrl=messageData["imageUrl"]                          
	                            );
	    	        // if(chatData["lastMessage"]!=null){

	    	        // }
		             if(messageData["sender"]!=null){
		             	newMessage.sender=(new Participant()
	                                        ..uid=messageData["sender"]["uid"]
	                                        ..userName=messageData["sender"]["userName"]
	                                        ..avator=messageData["sender"]["avator"]);
		             }
		             
		            
		             return newMessage;
	}
	Future<bool> deleteChat(Chat chat) async{
		try{
       await _chatRef.child(chat.chatId).set(null);
      var deletedChat= await _chatRef.child(chat.chatId).get();
      if(deletedChat!=null){
        throw new AppError(actionType: ActionsTypes.deleteChat,payload: chat,message: "failed to delete chat");
      }

       store.dispatch(new Action(type:ActionsTypes.deleteChat,data:chat));
			return true;
			}catch(e,st){
			logError(e,ActionsTypes.createChat,st);
				return false;
		}
	}
	void getContacts(){
	}
	Future<bool> sendMessage(Message msg)async{
		var msgData;
      try{
 
   			await _messagesRef.child(msg.messageId).set({
							    "timestamp":ServerValue.timestamp,
								"messageId":msg.messageId,
								"messageText":msg.messageText,
								"imageUrl":msg.imageUrl,
								"metadata":msg.metadata,
								"chatId":msg.chatId,
								"sender":{
										"uid":msg.sender.uid,
										"userName":msg.sender.userName,
										"avator":msg.sender.avator,
										"status":true
										},
    						});
  /*msgData=_messagesRef.child(msg.messageId).get();
 	if(msgData==null){ }else{
   	await _messagesRef.child(msg.messageId).update({
							    "timestamp":msg.timestamp,
								"messageId":msg.messageId,
								"messageText":msg.messageText,
								"imageUrl":msg.imageUrl,
								"metadata":msg.metadata,
								"chatId":msg.chatId,
								"sender":{
										"uid":msg.sender.uid,
										"userName":msg.sender.userName,
										"avator":msg.sender.avator,
										"status":true
										},
    						});
   }*/

    msgData=await _messagesRef.child(msg.messageId).get();
    if(msgData==null){
    	throw new AppError(actionType:ActionsTypes.sendMessage,payload:msg,message:"failed to send message to chat ${msg.chatId}");
    }
    
   Message message=_messageInfoChanged(msgData);
      store.dispatch(new Action(type:ActionsTypes.sendMessage,data:message));
			return true;
			}catch(e,st){
			logError(e,ActionsTypes.createChat,st);
				return false;
		}
	}
	
	Future<bool> deleteMessage(Message msg)async{
		try{
      await _messagesRef.child(msg.messageId).set(null);
      var deletedMsg=await _messagesRef.child(msg.messageId).get();

      if(deletedMsg!=null)
      {
       throw new AppError(actionType: ActionsTypes.deleteMessage,payload: msg,message: "failed to delete message");
      }
      store.dispatch(new Action(type:ActionsTypes.deleteMessage,data:msg));
			return true;
			}catch(e,st){
			logError(e,ActionsTypes.deleteMessage,st);
				return false;
		}
	  
	}
	Future<bool> addParticipant(Participate participation)async{
		var _participation,participantInfo;

		try{

      participantInfo=await _chatRef.child(participation.chatId).get();
			if(participantInfo!=null){
        await _chatRef.child(participation.chatId).child("participants")
            .child(participation.user.uid).set({
          "userName":participation.user.userName,
          "avator":participation.user.avator,
          "uid":participation.user.uid,
          "status":true
        });
			}
			else{
        throw new AppError(actionType: ActionsTypes.addParticipant,payload: participation,message:"chat not found ");

      }
      participantInfo=await _chatRef.child(participation.chatId).child("participants")
          .child(participation.user.uid).get();
      _participation=new Participate()
        ..user=_participantInfoChanged(participantInfo)
			  ..chatId=participation.chatId;

        store.dispatch(new Action(type:ActionsTypes.addParticipant,data:_participation));
			return true;
			}catch(e,st){
			logError(e,ActionsTypes.addParticipant,st);
				return false;
		}
	}
	Participant _participantInfoChanged(participantInfo){
	  Participant ps=participantInfo["status"]?
                        (new Participant()
                        ..userName=participantInfo["userName"]
                        ..avator=participantInfo["avator"]
                        ..uid=participantInfo["uid"]):
                        (new NonParticipant()
                          ..userName=participantInfo["userName"]
                          ..avator=participantInfo["avator"]
                          ..uid=participantInfo["uid"]);
	  return ps;
  }
	
	Future<bool> removeParticipant(Participate participation) async{
    var _participation,participantInfo;

    try{

      participantInfo=await _chatRef.child(participation.chatId).get();
      if(participantInfo!=null){
        await _chatRef.child(participation.chatId).child("participants")
            .child(participation.user.uid).set({
          "userName":participation.user.userName,
          "avator":participation.user.avator,
          "uid":participation.user.uid,
          "status":false
        });
      }
      else{
        throw new AppError(actionType: ActionsTypes.removeParticipant,payload: participation,message:"chat not found ");

      }
      participantInfo=await _chatRef.child(participation.chatId).child("participants")
          .child(participation.user.uid).get();
      _participation=new Participate()
        ..user=_participantInfoChanged(participantInfo)
        ..chatId=participation.chatId;

        store.dispatch(new Action(type:ActionsTypes.removeParticipant,data:_participation));
			return true;
			}catch(e,st){
			logError(e,ActionsTypes.removeParticipant,st);
				return false;
		}
	
	}
	void quoteMessage(){}
	void forwardMessage(){}
	void logError(dynamic e,[ActionsTypes actionType,dynamic stackTrace]){
		log.severe('error encountered!', e, stackTrace);
		store.dispatch(new Action(type:ActionsTypes.onError,
				data:(e is! AppError?
				{
				"payload":e,
				"actionType":actionType}
				:e)));
	}
	
}