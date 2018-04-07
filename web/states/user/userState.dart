
/*
* created by ebundala 
* states for the user
* 
* */
import "package:dartson/dartson.dart";

@Entity()
class userInfo {
	    String uid;
		String userName;
		String avator;
		//userInfo();
		//userInfo({this.uid,this.name,this.avator});
	}

@Entity()
class follow extends userInfo  {
		String uid;
		String userName;
		String avator;
		final bool status=true;
	
}
@Entity()
class unfollow extends follow {
		String uid;
		String userName;
		String avator;
		final bool status=false;
	
}
@Entity()
class permission {
	String id;
	String name;
	final bool status=true;
	//const permission({this.id,this.name});
	
}
@Entity()
class revokePermission extends permission {
	String id;
	String name;
	final bool status= false;
	
}

@Entity()
class User {
	String uid;
	String displayName;
	String photoUrl;
	String email;
	String fcmId;
	/*map <followedUserId,followedUserInfo>*/
	Map<String, follow> following={};
	/**/
	Map<String,permission> permissions={};
}
@Entity()
class userList {
	Map<String,User> users;
	
}