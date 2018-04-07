
//import "dart:io";
import "states/actionsTypes.dart";
import "states/user/userState.dart";
import "states/IM/instantMessangerState.dart";
import "states/state.dart";
import "states/reducers.dart";
import "states/store.dart";
import "components/InstantMessanger.dart";
import 'components/UserManager.dart';
import "dart:html";






 main() {
 	print("Components Tests web");
 	
 	List<Function> middleware=[];
 	var initialState=(new AppState()
	                   // ..error=new AppError()
	                    ..currentUser=(new User()
	                    	    ..photoUrl="photoUrl" 
	                    	    ..displayName="Musa musa"
								.. email="eliaas@gmail.com")
								) ;
 	Store store= new Store(reducer:rootReducer,state:initialState,middleware:middleware);


//user user Management 
createSection("userManagement");
UserManager account=new UserManager(store:store);
   createButton("login",(e){
    	account.login();
    	});
   createButton("register",(e){
    	account.register();
    	});
   createButton("givePermission",(e){
    	account.givePermission();
    	});
   createButton("revokePermission",(e){
    	account.revokeUserPermission();
    	});
   createButton("follow",(e){
    	account.followUser();
    	});
   createButton("unfollow",(e){
    	account.unfollowUser();
    	});
   createButton("onUserInfoChanged",(e){
    	account.onUserInfoChanged();
    	});
   createButton("logout",(e){
    	account.logout();
    	});
   createButton("delete",(e){
    	account.delete();
    	});


//instant messanger 
createSection("InstantMessanger");
InstantMessanger messanger= new InstantMessanger(store:store);
	createButton("createChat",(e){
		messanger.createChat();
		});
	createButton("deleteChat",(e){
		messanger.deleteChat();
		});
	createButton("sendMessage",(e){
		messanger.sendMessage();
		});
	createButton("deleteMessage",(e){
		messanger.deleteMessage();
		});
	createButton("addParticipant",(e){
		messanger.addParticipant();
		});
	createButton("removeParticipant",(e){
		messanger.removeParticipant();
		});
	createButton("quoteMessage",(e){
		messanger.quoteMessage();
		});
	createButton("forwardMessage",(e){
		messanger.forwardMessage();
		});
	createButton("getContacts",(e){
		messanger.getContacts();
		});

//shopping cart  
createSection("shopping cart");

}








//utility functions
dynamic logger(state,action){
 		print("action\n ${action.toString()}\n prev state \n${state.toString()}");
 		return state;
 	}

void createButton(String name,dynamic callback){
	final div =document.getElementById("tester");
	var button = document.createElement("button");
	button.innerHtml=name;
	button.onClick.listen(callback);
	div.append(button);
}
void createSection(String title){
	final div =document.getElementById("tester");
	var br = document.createElement("br");
	var titleEl = document.createElement("h3");
	titleEl.innerHtml=title;
	
	div.append(br);
	div.append(titleEl);
}


void expect(String itDoes,dynamic val,dynamic exp){
	print(itDoes);
	assert(val==exp);
	val==exp?print("Passed\n"):print("\nFailled\n");
}
