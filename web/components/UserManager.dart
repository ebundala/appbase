

import "dart:async";
import "package:firebase_dart/firebase_dart.dart";
import "package:logging/logging.dart";
import "package:redux/redux.dart";
import "package:dartson/dartson.dart";
//user Management component

import "../states/state.dart";
import "../states/actionsTypes.dart";
import "../states/user/userState.dart";

//import "../states/store.dart" show Store;


var dson=new Dartson.JSON();
enum SIGNIN_METHODS{
	CustomToken,
	GoogleProvider,
	FacebookProvider,
	TwitterProvider,
	GitHubProvider,
	EmailProvider
}

class UserManager {
	
	Store<AppState> store;
	final ref;
	var _usersRef;
	final secret;
	var _token;
final Logger log = new Logger('UserManager');
	
	UserManager({this.store,this.ref,this.secret="x"}){

		_usersRef=ref.child("users");
		
		// .onChildAdded.listen((e) {
		//             print(e.snapshot.val);
		//           });
	}


	Future<bool> login({User aUser,SIGNIN_METHODS provider,bool reg=false}) async{
		log.fine("Logging user in ");
		User authenticatedUser;
		try{
			switch(provider){
				case SIGNIN_METHODS.CustomToken:
				
				var authData = {
			        "uid": aUser.uid,
			        "debug": true,
			        "displayName":aUser.displayName,
			        "photoUrl":aUser.photoUrl,
			        "email":aUser.email,
			        "fcmId":aUser.fcmId,
			        "provider": "custom"
			      };
			      var codec = new FirebaseTokenCodec(secret);
			      _token = codec.encode(new FirebaseToken(authData));//todo  get real auth token here
			      var auth = await ref.authWithCustomToken(_token);
			      

			     
			     if(auth["uid"]!=null){
	             var userData=await _usersRef.child(auth["uid"]).get();
	                if(userData==null)
	                {
		                await _usersRef.child(auth["uid"]).set(
					     	{
					        "uid": auth["uid"],
					        "displayName":auth["displayName"],
					        "email":auth["email"],
					        "photoUrl":auth["photoUrl"],
					        "fcmId":auth["fcmId"],
					        "provider":auth["provider"]
					     		});
	            	}
	            	else
	            	{
				     	await _usersRef.child(auth["uid"]).update(
					     	{
					        "uid": auth["uid"],
					        "displayName":auth["displayName"],
					        "email":auth["email"],
					        "photoUrl":auth["photoUrl"],
					        "fcmId":auth["fcmId"],
					        "provider":auth["provider"]
					     		});
			     		
	                }
			    
	            userData=await _usersRef.child(auth["uid"]).get();
	            
	             authenticatedUser=_userInfoChanged(userData);
	             
	             
	             
	             
	            }else{
	            	throw new AppError(actionType:reg?ActionsTypes.register:ActionsTypes.login,payload:aUser,message:"error occurred during signin/register");
	            }

				break;
				case SIGNIN_METHODS.GoogleProvider:
				break;
				case SIGNIN_METHODS.FacebookProvider:
				break;
				case SIGNIN_METHODS.TwitterProvider:
				break;
				case SIGNIN_METHODS.GitHubProvider:
				break;
				case SIGNIN_METHODS.GitHubProvider:
				break;
				default:
				
				throw(new AppError(actionType:reg?ActionsTypes.register:ActionsTypes.login,payload:aUser,message:"un recognized SIGNIN_METHOD"));
				
			}
		}
	    catch(e,st){
	            //store.dispatch(new Action(type:ActionsTypes.onError,data:e));
	            logError(e,reg?ActionsTypes.register:ActionsTypes.login,st);
				return false;
	    }
       // print(dson.encode(authenticatedUser));
        store.dispatch(new Action(type:ActionsTypes.login,data:authenticatedUser)); 
       return true;
	}
    User _userInfoChanged(dynamic userData){
    	User newUser=(new User()
	            ..uid=userData["uid"]
	            ..displayName=userData["displayName"]
	            ..photoUrl=userData["photoUrl"]
	            ..email=userData["email"]
	            ..fcmId=userData["fcmId"]
	            );
	             
	             if(userData["permissions"]!=null){
	             	
	             	userData["permissions"].forEach((key, item) {
	             		newUser.permissions[key]=item["status"]?
	             		(new permission()
	             			..id=item["id"]
	             			..name=item["name"]
	             			):
	             		(new revokePermission()
	             			..id=item["id"]
	             			..name=item["name"]
	             			);
	             		});
	             }
	             //todo find a better way to handle following
	             if(userData["following"]!=null){
	             	
	             	userData["following"].forEach((key, item) {
	             		newUser.following[key]=item["status"]?
	             		(new follow()
	             			..uid=item["uid"]
	             			..userName=item["userName"]
	             			..avator=item["avator"]
	             			):
	             		(new unfollow()
	             			..uid=item["uid"]
	             			..userName=item["userName"]
	             			..avator=item["avator"]
	             			);
	             		});
	             }
	             return newUser;
    }
	Future<bool> register({User aUser,SIGNIN_METHODS provider}) async{
		
        return await login(aUser:aUser,provider:provider,reg:true);
        
	}
	
	Future<bool> givePermission(permission perm) async{
        User aUser=store.state.currentUser;

	    try{
			if(!(aUser.permissions.containsKey(perm.id)&&aUser.permissions[perm.id].status))
			{
				var permRef=_usersRef.child(aUser.uid).child("permissions").child(perm.id);
				await permRef.set(
					{
						"id":perm.id,
						"name":perm.name,
						"status":true
					}
					);
				var permVal = await permRef.get();
				if(permVal!=null&&permVal["status"]){
					var permInfo=(new permission()..id=permVal["id"]..name=permVal["name"]);
					store.dispatch(new Action(type:ActionsTypes.givePermission,data:permInfo));

				}
				else{

					throw(new AppError(actionType:ActionsTypes.givePermission,payload:perm,message:"failed to give permissions"));
				}
				
			
				store.dispatch(new Action(type:ActionsTypes.givePermission,data:perm));
			}
			
			return true;
			
		}catch(e){

				
				logError(e,ActionsTypes.givePermission);
				return false;

		}
	}
	Future<bool> revokeUserPermission(revokePermission perm) async{
        User aUser=store.state.currentUser;

	    try{
			if(!(aUser.permissions.containsKey(perm.id)&&aUser.permissions[perm.id].status==false))
			{
				var permRef=_usersRef.child(aUser.uid).child("permissions").child(perm.id);
				await permRef.set(
					{
						"id":perm.id,
						"name":perm.name,
						"status":false
					}
					);
				var permVal = await permRef.get();
				if(permVal!=null&&permVal["status"]==false){
					var permInfo=(new revokePermission()
										..id=permVal["id"]
										..name=permVal["name"]);
					store.dispatch(new Action(type:ActionsTypes.givePermission,data:permInfo));

				}
				else{

					throw(new AppError(actionType:ActionsTypes.revokePermission,payload:perm,message:"failed to revoke permission"));
				}
				
			
			store.dispatch(new Action(type:ActionsTypes.revokePermission,data:perm));
			}
			
			return true;
			
		}catch(e,st){

				
				logError(e,ActionsTypes.revokePermission,st);
				return false;

		}
		
	}
	Future<bool> followUser(follow info) async{
		User aUser=store.state.currentUser;

	    try{
			if(!(aUser.following.containsKey(info.uid)&&aUser.following[info.uid].status))
			{
				var followRef=_usersRef.child(aUser.uid).child("following").child(info.uid);
				await followRef.set(
					{
						"uid":info.uid,
						"userName":info.userName,
						"avator":info.avator,
						"status":true
					}
					);
				var followVal = await followRef.get();
				if(followVal!=null&&followVal["status"]){
					follow followInfo=(new follow()
										..avator=followVal["avator"]
										..uid=followVal["uid"]
										..userName=followVal["userName"]);
					store.dispatch(new Action(type:ActionsTypes.followUser,data:followInfo));

				}
				else{

					throw(new AppError(actionType:ActionsTypes.followUser,payload:info,message:"failed to follow user"));
				}
				
			
					store.dispatch(new Action(type:ActionsTypes.followUser,data:info));
			}
			
			return true;
			
		}catch(e){

				logError(e,ActionsTypes.followUser);
				return false;

		}
		
		
	}
	Future<bool> unfollowUser(unfollow info) async{
		User aUser=store.state.currentUser;

	    try{
			if((aUser.following.containsKey(info.uid)&&aUser.following[info.uid].status))
			{
				var unfollowRef=_usersRef.child(aUser.uid).child("following").child(info.uid);
				await unfollowRef.set(
					{
						"uid":info.uid,
						"userName":info.userName,
						"avator":info.avator,
						"status":false
					}
					);
				var followVal = await unfollowRef.get();
				if(followVal!=null&&(followVal["status"]==false))
				{
					unfollow unfollowInfo=(new unfollow()
										..avator=followVal["avator"]
										..uid=followVal["uid"]
										..userName=followVal["userName"]);
					store.dispatch(new Action(type:ActionsTypes.unfollowUser,data:unfollowInfo));

				}
				else{

					throw(new AppError(actionType:ActionsTypes.followUser,payload:info,message:"failed to unfollow user"));
				}
				
			
					store.dispatch(new Action(type:ActionsTypes.unfollowUser,data:info));
			}
			
			return true;
			
		}catch(e,st){

				logError(e,ActionsTypes.unfollowUser,st);
				return false;

		}
		
	}
	void onUserInfoChanged(User aUser){
		
		 store.dispatch(new Action(type:ActionsTypes.userInfoChanged,data:aUser));

	}
	Future<bool> logout() async{
		User aUser=store.state.currentUser;
		try{
			if(ref.auth!=null||aUser!=null){
				await ref.unauth();
				if(ref.auth==null){
				store.dispatch(new Action(type:ActionsTypes.logout));

				return true;
				}
				else{
					throw (new AppError(actionType:ActionsTypes.logout,payload:store.state.currentUser,message:"Error loging out user"));

				}
			}
			return true;
		}catch(e,st){
			
			
            logError(e,ActionsTypes.logout,st);
			
			return false;
		}
        
        
	}
	void deleteUser(){
		store.dispatch(new Action(type:ActionsTypes.deleteUser));
	    
	}
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