/*
* created by ebundala 
* states for the user
* 
* */
//import "package:dartson/dartson.dart";

class userInfo {
  String uid;
  String userName;
  String avator;
  //userInfo();
  //userInfo({this.uid,this.name,this.avator});
}

class follow extends userInfo {
  String uid;
  String userName;
  String avator;
  final bool status = true;
}

class unfollow extends follow {
  String uid;
  String userName;
  String avator;
  final bool status = false;
}

class permission {
  String id;
  String name;
  final bool status = true;
  //const permission({this.id,this.name});

}

class revokePermission extends permission {
  String id;
  String name;
  final bool status = false;
}

class User {
  String uid;
  String displayName;
  String photoUrl;
  String email;
  String fcmId;
  /*map <followedUserId,followedUserInfo>*/
  Map<String, follow> following = {};
  /**/
  Map<String, permission> permissions = {};
}

class userList {
  Map<String, User> users;
}
