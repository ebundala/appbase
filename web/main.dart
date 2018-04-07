
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
 	



//instant messanger 


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
