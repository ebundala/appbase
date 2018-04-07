import 'dart:async';
import "package:test/test.dart";
import "package:dartson/dartson.dart";
import "package:redux/redux.dart";
import 'package:logging/logging.dart';
import 'package:firebase_dart/firebase_dart.dart';

import "../lib/src//states/actionsTypes.dart";
import "../lib/src/states/user/userState.dart";
import "../lib/src/states/IM/instantMessangerState.dart";
import "../lib/src/states/state.dart";
import "../lib/src/states/reducers.dart";
import "../lib/src/states/shoppingCart/ShoppingCartState.dart";

//import "../lib/src/states/store.dart";
import "../lib/src/components/UserManager.dart";
import "../lib/src/components/InstantMessanger.dart";
import "../lib/src/components/ShoppingCart.dart";
import "../lib/src/components/BillingManager.dart";
import "../lib/src/components/ContentManager.dart";
import "../lib/src/components/AdsManager.dart";


//import "secrets.dart";
import "secretsMem.dart";


 void main() {
    var dson=new Dartson.JSON();
    void loggerMiddleware(Store<AppState> store,action,NextDispatcher next){
       // print("[ACTION]:\n ${dson.encode(action).replaceAll(",",",\n").replaceAll(":{",":{\n").replaceAll("{{","{\n{").replaceAll("}}","}\n}")}\n\n"
              //"[STATE]:\n ${dson.encode(store.state).replaceAll(",",",\n").replaceAll(":{",":{\n").replaceAll("{{","{\n{").replaceAll("}}","}\n}")}\n\n"
            //  );
        next(action);
        }
	StreamSubscription logSubscription;

	var initialState=(new AppState()
		                   // ..errors=[]
		                    //..currentUser=(new User()
		                    //	    ..photoUrl="photoUrl" 
		                    //	    ..displayName="Musa musa"
								//	.. email="eliaas@gmail.com")
									) ;

 	final store = new Store<AppState>(rootReducer,initialState:initialState,middleware:[loggerMiddleware]);;
 	UserManager  account;
 	InstantMessanger messanger;
 	ShoppingCart cart;
 	BillingManager billing;
 	ContentManager cms;
 	AdsManager ads;
    String uid="cvbg8989";
    var appRootRef= new Firebase(secrets["host"]);



/*

* initial setup
*/
setUp(()
 {
         
    Logger.root.level = Level.ALL;
    logSubscription = Logger.root.onRecord.listen(print);
       
     
     // store.onChange.listen((state){
     //    dbReference.child("test").set({"state":dson.encode(state)});
     //    });
	
	account = new UserManager(store:store,ref:appRootRef,secret:secrets["secret"]);
	messanger = new InstantMessanger(store:store,ref:appRootRef);
	cart = new ShoppingCart(store:store);
 	billing = new BillingManager();
 	cms = new ContentManager();
 	ads = new AdsManager();

 });

tearDown(()async {
    await logSubscription.cancel();

        //store=null;
        });

/*
* 
* user management tests
*/
group("[USER_MANAGER]:-",(){

    	test("register user",() async{
            User aUser=(new User()
          ..uid="cvbg8989"
          ..displayName="Elias joachim"
          ..email="ebundalaxxx@gmail.com"
          ..photoUrl="somethingxx.jpg");
            await account.register(aUser:aUser,provider:SIGNIN_METHODS.CustomToken);

    		expect(aUser.uid,equals(store.state.currentUser.uid));
            expect(aUser.displayName,equals(store.state.currentUser.displayName));
            expect(aUser.email,equals(store.state.currentUser.email));
            expect(aUser.photoUrl,equals(store.state.currentUser.photoUrl));
            expect(aUser.following.length,equals(0));
            expect(aUser.permissions.length,equals(0));
    		});
        test("givePermission",() async{

            String name="posting";
            permission perm =(new permission()
                                    ..id=name
                                    ..name=name);
            await account.givePermission(perm);
            expect(perm.status,equals(store.state.currentUser.permissions[perm.id].status));
            expect(perm.name,equals(store.state.currentUser.permissions[perm.id].name));
            expect(perm.id,equals(store.state.currentUser.permissions[perm.id].id));
            //expect(store.state.currentUser.following.length,equals(0));
            expect(store.state.currentUser.permissions.length,equals(1));

            });
        test("followUser",() async{

            follow info =(new follow()
                            ..uid="vbnmmkl"
                            ..userName="John doe"
                            ..avator="avator.png"
                            );
            await account.followUser(info);
            //print(dson.encode(store.state.currentUser.following));
            expect(info.status,equals(store.state.currentUser.following[info.uid].status));
            expect(info.userName,equals(store.state.currentUser.following[info.uid].userName));
            expect(info.avator,equals(store.state.currentUser.following[info.uid].avator));
            expect(info.uid,equals(store.state.currentUser.following[info.uid].uid));
            expect(store.state.currentUser.following.length,equals(1));

            });
        test("logout ",() async{
                await account.logout();
               // print(dson.encode(store.state.errors));
               // print(dson.encode(ActionsTypes.logout));
                if(store.state.errors.isNotEmpty)
                expect(true,isNot(store.state.errors.last.actionType==ActionsTypes.logout));
                //expect(store.state.currentUser,isNull);
                });
    	test("login",() async{
            User aUser=(new User()
            ..uid="cvbg8989"
            ..displayName="Elias bundala"
            ..email="ebundala@gmail.com"
            ..photoUrl="something.jpg"
            );
            await account.login(aUser:aUser,provider:SIGNIN_METHODS.CustomToken);
    		expect(aUser.uid,equals(store.state.currentUser.uid));
            expect(aUser.displayName,equals(store.state.currentUser.displayName));
            expect(aUser.email,equals(store.state.currentUser.email));
            expect(aUser.photoUrl,equals(store.state.currentUser.photoUrl));
            expect(store.state.currentUser.following.length,equals(1));
            expect(store.state.currentUser.permissions.length,equals(1));
    		});
   	
    	test("revokeUserPermission",() async{
            String name="posting";
            revokePermission perm =(new revokePermission()
                                        ..id=name
                                        ..name=name);
            await account.revokeUserPermission(perm);
           // print(dson.encode(store.state.currentUser.permissions));
    		expect(perm.status,equals(store.state.currentUser.permissions[perm.id].status));
            expect(perm.name,equals(store.state.currentUser.permissions[perm.id].name));
            expect(perm.id,equals(store.state.currentUser.permissions[perm.id].id));

    		});
    	
    	test("unfollowUser",() async{
            unfollow info =(new unfollow()
                             ..uid="vbnmmkl"
                            ..userName="John doe"
                            ..avator="avator.png"
                            );

    		await account.unfollowUser(info);

            if(store.state.errors.isNotEmpty){
                expect(true,isNot(store.state.errors.last.actionType==ActionsTypes.unfollowUser));
            }
            
    		expect(info.status,equals(store.state.currentUser.following[info.uid].status));
            expect(info.userName,equals(store.state.currentUser.following[info.uid].userName));
            expect(info.avator,equals(store.state.currentUser.following[info.uid].avator));
            expect(info.uid,equals(store.state.currentUser.following[info.uid].uid));
    		});

/*
        
        test("onUserInfoChanged",(){
            User aUser=(new User()
                  ..displayName="Elias joachim"
                  ..email="ebundalaxxx@gmail.com"
                  ..photoUrl="somethingagag");
                account.onUserInfoChanged(aUser);

            expect(aUser,equals(store.state.currentUser));
            });
        test("delete ",(){
            account.deleteUser();
            expect(null,equals(store.state.currentUser));
            });
*/
    	});
	    
/*
* 
* instant messaging
*/

group("[INSTANT_MESSANGER]:-",(){

        test("create chat",()async{
            Chat mychat=(new Chat()
                            ..chatId="hellow"
                            ..creator=(new Participant()
                                        ..uid=store.state.currentUser.uid
                                        ..userName=store.state.currentUser.displayName
                                        ..avator=store.state.currentUser.photoUrl));
            Chat newChat=await messanger.createChat(mychat);
            expect(mychat.chatId,equals(newChat.chatId));
            expect(mychat.creator.uid,equals(newChat.creator.uid));
            expect(mychat.creator.status,equals(newChat.creator.status));
            expect(mychat.creator.avator,equals(newChat.creator.avator));
            expect(mychat.creator.userName,equals(newChat.creator.userName));
            expect(newChat.participants.length,equals(1));
            expect(newChat.timestamp is int,isTrue);

            expect(mychat.chatId,equals(store.state.chats[mychat.chatId].chatId));
            expect(mychat.creator.uid,equals(store.state.chats[mychat.chatId].creator.uid));
            expect(mychat.creator.status,equals(store.state.chats[mychat.chatId].creator.status));
            expect(mychat.creator.avator,equals(store.state.chats[mychat.chatId].creator.avator));
            expect(mychat.creator.userName,equals(store.state.chats[mychat.chatId].creator.userName));
            expect(mychat.creator.userName,equals(store.state.chats[mychat.chatId].creator.userName));
            expect(store.state.chats[mychat.chatId].participants.length,equals(1));
            expect(store.state.chats[mychat.chatId].timestamp is int,isTrue);
            //when a chat exists
           Chat newChat1=await messanger.createChat(mychat);
            expect(mychat.chatId,equals(newChat1.chatId));
            expect(mychat.creator.uid,equals(newChat1.creator.uid));
            expect(mychat.creator.status,equals(newChat1.creator.status));
            expect(mychat.creator.avator,equals(newChat1.creator.avator));
            expect(mychat.creator.userName,equals(newChat1.creator.userName));
            expect(newChat1.participants.length,equals(1));
            expect(newChat1.timestamp is int,isTrue);
            expect(newChat.timestamp,equals(newChat1.timestamp));

            expect(mychat.chatId,equals(store.state.chats[mychat.chatId].chatId));
            expect(mychat.creator.uid,equals(store.state.chats[mychat.chatId].creator.uid));
            expect(mychat.creator.status,equals(store.state.chats[mychat.chatId].creator.status));
            expect(mychat.creator.avator,equals(store.state.chats[mychat.chatId].creator.avator));
            expect(mychat.creator.userName,equals(store.state.chats[mychat.chatId].creator.userName));
            expect(mychat.creator.userName,equals(store.state.chats[mychat.chatId].creator.userName));
            expect(store.state.chats[mychat.chatId].participants.length,equals(1));
            expect(store.state.chats[mychat.chatId].timestamp is int,isTrue);
			expect(store.state.chats[mychat.chatId].timestamp,equals(newChat1.timestamp));
            }); 

        test("send message",()async{
            String chatId=store.state.chats["hellow"].chatId;
            User currentUser=store.state.currentUser;
            Message msg=(new Message()
                            ..chatId=chatId
                            ..messageId="hello"
                            ..sender=(new Participant()
                                        ..uid=currentUser.uid
                                        ..userName=currentUser.displayName
                                        ..avator=currentUser.photoUrl)
                                ..messageText="action.data.messageText"
                                ..imageUrl="action.data.imageUrl"
                                ..metadata={"key":"action.data.metadata.value"}
                                );
            await messanger.sendMessage(msg);
            expect(msg.chatId,equals(store.state.chats["hellow"].chatId));
            expect(store.state.messages[msg.messageId].timestamp is int,isTrue);
            expect(msg.metadata["key"],equals(store.state.messages[msg.messageId].metadata["key"]));
            expect(msg.imageUrl,equals(store.state.messages[msg.messageId].imageUrl));
            expect(msg.messageText,equals(store.state.messages[msg.messageId].messageText));
            expect(msg.sender.uid,equals(store.state.messages[msg.messageId].sender.uid));
            expect(msg.sender.userName,equals(store.state.messages[msg.messageId].sender.userName));
            expect(msg.sender.avator,equals(store.state.messages[msg.messageId].sender.avator));
            expect(msg.sender.status,equals(store.state.messages[msg.messageId].sender.status));
            
            

            });
        test("add participants",()async{
            Participant user2= (new Participant()
                                    ..uid="uuifghj"
                                    ..userName="john doe"
                                    ..avator="somethingagag.jpg");

            String chatId=store.state.chats["hellow"].chatId;
            Participate _participation=(new Participate()
                                            ..chatId=chatId
                                            ..user=user2);
            await messanger.addParticipant(_participation);
            expect(true,equals(store.state.chats[chatId].participants[user2.uid].status));
            expect(user2.uid,equals(store.state.chats[chatId].participants[user2.uid].uid));
            expect(user2.userName,equals(store.state.chats[chatId].participants[user2.uid].userName));
            expect(user2.avator,equals(store.state.chats[chatId].participants[user2.uid].avator));
            expect(user2.status,equals(store.state.chats[chatId].participants[user2.uid].status));


            });
        test("remove participants",() async{
            NonParticipant user2= (new NonParticipant()
                                        ..uid="uuifghj"
                                        ..userName="john doe"
                                        ..avator="something.jpg");
            String chatId=store.state.chats["hellow"].chatId;
            Participate _participation=(new Participate()
                                            ..chatId=chatId
                                            ..user=user2);
           await messanger.removeParticipant(_participation);
            expect(false,equals(store.state.chats[chatId].participants[user2.uid].status));
            expect(user2.uid,equals(store.state.chats[chatId].participants[user2.uid].uid));
            expect(user2.userName,equals(store.state.chats[chatId].participants[user2.uid].userName));
            expect(user2.avator,equals(store.state.chats[chatId].participants[user2.uid].avator));
            expect(user2.status,equals(store.state.chats[chatId].participants[user2.uid].status));
            });
        test("delete message",()async{
            String chatId=store.state.chats["hellow"].chatId;
            User currentUser=store.state.currentUser;
            Message msg=(new Message()
                            ..chatId=chatId
                            ..messageId="hello"
                            ..sender=(new Participant()
                                        ..uid=currentUser.uid
                                        ..userName=currentUser.displayName
                                        ..avator=currentUser.photoUrl)
                                ..messageText="action.data.messageText"
                                ..imageUrl="action.data.imageUrl"
                                ..metadata={"key":"action.data.metadata"}
                                ..timestamp=89888900);

           await messanger.deleteMessage(msg);
            expect(store.state.messages[msg.messageId],isNull);
            });
        test("delete chat",()async{
            Chat mychat=(new Chat()
                            ..chatId="hellow"
                            ..creator=(new Participant()
                                    ..uid="898fvn"
                                    ..userName="Elias bundala"
                                    ..avator="profilepic.jpg"));
            await messanger.deleteChat(mychat);
            expect(store.state.chats[mychat.chatId],isNull);
            });

    	});

/*
* 
* shopping cart
* 
*/

group("[SHOPPING_CART]:-",(){
        test("createItem",(){
            Item item= (new Item()
                            ..itemId="xcvbbnbj89jk"
                            ..seller=(new userInfo()
                                ..uid=store.state.currentUser.uid
                                ..userName=store.state.currentUser.displayName
                                ..avator=store.state.currentUser.photoUrl
                                 )
                            ..title="some product"
                            ..priceUnit=98989889.00
                            ..quantity=90
                            ..quantitySold=0
                            ..qUnits="pieces"
                            ..condition=ItemCondition.brandNew
                            ..type=ItemType.physical
                            ..mode=SellMode.directSell
                            ..description="something description"
                            ..featuredImage="someItemphoto.jpg"
                            ..additionalImages=["someAditionalPhoto.jpg","secondPhoto.jpg"]
                            ..categories={"123":(new Category()..name="electronic"..catId="123")}
                            ..subCategories={"456":(new SubCategory()..parentId="123"..catId="456"..name="smartphones")}
                            ..auctionInfo=null

                   );
                cart.createItem(item);
                expect(store.state.items[item.itemId].itemId,equals(item.itemId));
                expect(store.state.items[item.itemId].seller.uid,equals(item.seller.uid));
                expect(store.state.items[item.itemId].seller.userName,equals(item.seller.userName));
                expect(store.state.items[item.itemId].seller.avator,equals(item.seller.avator));
                expect(store.state.items[item.itemId].title,equals(item.title));
                expect(store.state.items[item.itemId].priceUnit,equals(item.priceUnit));
                expect(store.state.items[item.itemId].quantity,equals(item.quantity));
                expect(store.state.items[item.itemId].quantitySold,equals(item.quantitySold));
                expect(store.state.items[item.itemId].qUnits,equals(item.qUnits));
                expect(store.state.items[item.itemId].condition,equals(item.condition));
                expect(store.state.items[item.itemId].type,equals(item.type));
                expect(store.state.items[item.itemId].mode,equals(item.mode));
                expect(store.state.items[item.itemId].description,equals(item.description));
                expect(store.state.items[item.itemId].additionalImages[1],equals(item.additionalImages[1]));
                expect(store.state.items[item.itemId].featuredImage,equals(item.featuredImage)); 
                expect(store.state.items[item.itemId].categories["123"].name,equals(item.categories["123"].name)); 
                expect(store.state.items[item.itemId].categories["123"].catId,equals(item.categories["123"].catId)); 
                expect(store.state.items[item.itemId].subCategories["456"].parentId,equals(item.subCategories["456"].parentId)); 
                expect(store.state.items[item.itemId].subCategories["456"].name,equals(item.subCategories["456"].name)); 
                expect(store.state.items[item.itemId].subCategories["456"].catId,equals(item.subCategories["456"].catId)); 
            }); 
        test("editItem",(){
            userInfo aUser=(new userInfo()
                                ..uid=store.state.currentUser.uid
                                ..userName=store.state.currentUser.displayName
                                ..avator=store.state.currentUser.photoUrl
                                 );
            Item item= (new Item()
                            ..itemId="xcvbbnbj89jk"
                            ..seller=aUser
                            ..title="some product"
                            ..priceUnit=98989889.00
                            ..quantity=90
                            ..quantitySold=80
                            ..qUnits="pieces"
                            ..condition=ItemCondition.brandNew
                            ..type=ItemType.physical
                            ..mode=SellMode.directSell
                            ..description="something description"
                            ..featuredImage="someItemphoto.jpg"
                            ..additionalImages=["someAditionalPhoto.jpg","secondPhoto.jpg"]
                            ..categories={"123":(new Category()..name="electronic"..catId="123")}
                            ..subCategories={"456":(new SubCategory()..parentId="123"..catId="456"..name="smartphones")}
                            ..auctionInfo=null
                   );
            cart.editItem(item);
            expect(store.state.items[item.itemId].itemId,equals(item.itemId));
            expect(store.state.items[item.itemId].seller.uid,equals(item.seller.uid));
            expect(store.state.items[item.itemId].seller.userName,equals(item.seller.userName));
            expect(store.state.items[item.itemId].seller.avator,equals(item.seller.avator));
            expect(store.state.items[item.itemId].title,equals(item.title));
           expect(store.state.items[item.itemId].priceUnit,equals(item.priceUnit));
           expect(store.state.items[item.itemId].quantity,equals(item.quantity));
           expect(store.state.items[item.itemId].quantitySold,equals(item.quantitySold));
           expect(store.state.items[item.itemId].qUnits,equals(item.qUnits));
           expect(store.state.items[item.itemId].condition,equals(item.condition));
           expect(store.state.items[item.itemId].type,equals(item.type));
           expect(store.state.items[item.itemId].mode,equals(item.mode));
           expect(store.state.items[item.itemId].description,equals(item.description));
           expect(store.state.items[item.itemId].additionalImages[1],equals(item.additionalImages[1]));
           expect(store.state.items[item.itemId].featuredImage,equals(item.featuredImage)); 
           expect(store.state.items[item.itemId].categories["123"].name,equals(item.categories["123"].name)); 
           expect(store.state.items[item.itemId].categories["123"].catId,equals(item.categories["123"].catId)); 
           expect(store.state.items[item.itemId].subCategories["456"].parentId,equals(item.subCategories["456"].parentId)); 
           expect(store.state.items[item.itemId].subCategories["456"].name,equals(item.subCategories["456"].name)); 
           expect(store.state.items[item.itemId].subCategories["456"].catId,equals(item.subCategories["456"].catId)); 
            
            }); 
        
        

        test("addToCart",(){
            CartItemInfo item= (new CartItemInfo()
                            ..itemId="xcvbbnbj89jk"
                            ..seller=(new userInfo()
                                ..uid=store.state.currentUser.uid
                                ..userName=store.state.currentUser.displayName
                                ..avator=store.state.currentUser.photoUrl
                                 )
                            ..title="some product"
                            ..priceUnit=98989889.00
                            ..quantity=89

                   );


            cart.addToCart(item);
            expect(store.state.shoppingCart.userName,equals(store.state.currentUser.displayName));
            expect(store.state.shoppingCart.uid,equals(store.state.currentUser.uid));
            expect(store.state.shoppingCart.items[item.itemId].priceUnit,equals(item.priceUnit));
            expect(store.state.shoppingCart.items[item.itemId].quantity,equals(item.quantity));
            expect(store.state.shoppingCart.items[item.itemId].title,equals(item.title));
            expect(store.state.shoppingCart.items[item.itemId].seller.uid,equals(item.seller.uid));

            }); 
        test("editCart",(){
           CartItemInfo item= (new CartItemInfo()
                            ..itemId="xcvbbnbj89jk"
                            ..seller=(new userInfo()
                                ..uid=store.state.currentUser.uid
                                ..userName=store.state.currentUser.displayName
                                ..avator=store.state.currentUser.photoUrl
                                 )
                            ..title="some product again"
                            ..priceUnit=989.00
                            ..quantity=99

                   );
           


            cart.editCart(item);
            expect(store.state.shoppingCart.userName,equals(store.state.currentUser.displayName));
            expect(store.state.shoppingCart.uid,equals(store.state.currentUser.uid));
            expect(store.state.shoppingCart.items[item.itemId].priceUnit,equals(item.priceUnit));
            expect(store.state.shoppingCart.items[item.itemId].quantity,equals(item.quantity));
            expect(store.state.shoppingCart.items[item.itemId].title,equals(item.title));
            expect(store.state.shoppingCart.items[item.itemId].seller.uid,equals(item.seller.uid));

            
            }); 
        test("saveCart",(){
            
            expect(true,equals(true));
            }); 
        test("removeFromCart",(){
            CartItemInfo item= (new CartItemInfo()
                            ..itemId="xcvbbnbj89jk"
                            ..seller=(new userInfo()
                                ..uid=store.state.currentUser.uid
                                ..userName=store.state.currentUser.displayName
                                ..avator=store.state.currentUser.photoUrl
                                 )
                            ..title="some product"
                            ..priceUnit=98989889.00
                            ..quantity=89

                   );
            cart.removeFromCart(item);
            expect(store.state.shoppingCart.items.containsKey(item.itemId),isFalse);
            }); 
        
        test("deleteCart",(){
            cart.deleteCart();
            expect(store.state.shoppingCart.items.isEmpty,isTrue);
            }); 
        test("createAuction",(){
            Item item= (new Item()
                            ..itemId="xcvbbnbj89jk"
                            ..seller=(new userInfo()
                                ..uid=store.state.currentUser.uid
                                ..userName=store.state.currentUser.displayName
                                ..avator=store.state.currentUser.photoUrl
                                 )
                            ..title="some product"
                            ..priceUnit=98989889.00
                            ..quantity=90
                            ..quantitySold=0
                            ..qUnits="pieces"
                            ..condition=ItemCondition.brandNew
                            ..type=ItemType.physical
                            ..mode=SellMode.directSell
                            ..description="something description"
                            ..featuredImage="someItemphoto.jpg"
                            ..additionalImages=["someAditionalPhoto.jpg","secondPhoto.jpg"]
                            ..categories={"123":(new Category()..name="electronic"..catId="123")}
                            ..subCategories={"456":(new SubCategory()..parentId="123"..catId="456"..name="smartphones")}
                            ..auctionInfo=null

                   );
            AuctionInfo info=(new AuctionInfo()
                        ..seller=item.seller
                        ..item=(new ItemInfo()
                            ..title=item.title
                            ..priceUnit=item.priceUnit
                            ..itemId=item.itemId
                            ..seller=item.seller)
                        ..auctionId=item.itemId
                        ..start=888
                        ..end=9000000
                        ..status=true
                        ..highestBid=(new Bid()
                                        ..bidValue=(item.priceUnit*5)
                                        ..item=(new ItemInfo()
                                                ..title=item.title
                                                ..priceUnit=item.priceUnit
                                                ..itemId=item.itemId
                                                ..seller=item.seller))
                        ..minimumBid=(new Bid()
                                        ..bidValue=item.priceUnit
                                        ..item=(new ItemInfo()
                                        ..title=item.title
                                        ..priceUnit=item.priceUnit
                                        ..itemId=item.itemId
                                        ..seller=item.seller))
                        );
            cart.createAuction(info:info,item:item);
                expect(store.state.auctions[item.itemId].auctionId,equals(item.itemId));
                expect(store.state.auctions[item.itemId].seller.uid,equals(item.seller.uid));
                expect(store.state.auctions[item.itemId].seller.userName,equals(item.seller.userName));
                expect(store.state.auctions[item.itemId].seller.avator,equals(item.seller.avator));
                expect(store.state.auctions[item.itemId].item.title,equals(item.title));
                expect(store.state.auctions[item.itemId].item.priceUnit,equals(item.priceUnit));
                expect(store.state.auctions[item.itemId].start,equals(info.start));
                expect(store.state.auctions[item.itemId].end,equals(info.end));
                expect(store.state.auctions[item.itemId].status,equals(info.status));
                expect(store.state.auctions[item.itemId].highestBid.bidValue,equals(info.highestBid.bidValue));
                expect(store.state.auctions[item.itemId].minimumBid.bidValue,equals(info.minimumBid.bidValue));
            }); 
        test("placeBid",(){
          var aUser=store.state.currentUser;
          var item=store.state.items["xcvbbnbj89jk"];
          Bid aBid=(new Bid()
            ..auctionId=item.itemId
            ..bidValue=500000.00
            ..uid=aUser.uid
            ..userName=aUser.displayName
            ..avator=aUser.photoUrl
            ..item=(new ItemInfo()
              ..itemId=item.itemId
              ..featuredImage=item.featuredImage
              ..seller=(new userInfo()..userName=item.seller.userName..avator=item.seller.avator..uid=item.seller.uid))
            );
          cart.placeBid(aBid);
            
          expect(store.state.auctions["xcvbbnbj89jk"].bids.length,equals(1));
          expect(store.state.auctions["xcvbbnbj89jk"].bids.containsKey(aUser.uid),isTrue);
          expect(store.state.auctions["xcvbbnbj89jk"].bids[aUser.uid].bidValue,equals(aBid.bidValue));
          expect(store.state.auctions["xcvbbnbj89jk"].bids[aUser.uid].uid,equals(aUser.uid));
          expect(store.state.auctions["xcvbbnbj89jk"].bids[aUser.uid].item.itemId,equals(item.itemId));
          expect(store.state.auctions["xcvbbnbj89jk"].bids[aUser.uid].item.seller.uid,equals(item.seller.uid));
          expect(store.state.auctions["xcvbbnbj89jk"].bids[aUser.uid].item.featuredImage,equals(item.featuredImage));


        });
        
        test("updateBid",(){

          var aUser=store.state.currentUser;
          var item=store.state.items["xcvbbnbj89jk"];
          Bid aBid=(new Bid()
            ..auctionId=item.itemId
            ..bidValue=900000.00
            ..uid=aUser.uid
            ..userName=aUser.displayName
            ..avator=aUser.photoUrl
            ..item=(new ItemInfo()
              ..itemId=item.itemId
              ..featuredImage=item.featuredImage
              ..seller=(new userInfo()..userName=item.seller.userName..avator=item.seller.avator..uid=item.seller.uid))
          );
          cart.updateBid(aBid);

          expect(store.state.auctions["xcvbbnbj89jk"].bids.length,equals(1));
          expect(store.state.auctions["xcvbbnbj89jk"].bids.containsKey(aUser.uid),isTrue);
          expect(store.state.auctions["xcvbbnbj89jk"].bids[aUser.uid].bidValue,equals(aBid.bidValue));
          expect(store.state.auctions["xcvbbnbj89jk"].bids[aUser.uid].uid,equals(aUser.uid));
          expect(store.state.auctions["xcvbbnbj89jk"].bids[aUser.uid].item.itemId,equals(item.itemId));
          expect(store.state.auctions["xcvbbnbj89jk"].bids[aUser.uid].item.seller.uid,equals(item.seller.uid));
          expect(store.state.auctions["xcvbbnbj89jk"].bids[aUser.uid].item.featuredImage,equals(item.featuredImage));
            }); 
        test("removeBid",(){
          var aUser=store.state.currentUser;
          var item=store.state.items["xcvbbnbj89jk"];
          Bid aBid=(new Bid()
            ..auctionId=item.itemId
            ..bidValue=900000.00
            ..uid=aUser.uid
            ..userName=aUser.displayName
            ..avator=aUser.photoUrl
            ..item=(new ItemInfo()
              ..itemId=item.itemId
              ..featuredImage=item.featuredImage
              ..seller=(new userInfo()..userName=item.seller.userName..avator=item.seller.avator..uid=item.seller.uid))
          );
           cart.removeBid(aBid);
          expect(store.state.auctions["xcvbbnbj89jk"].bids.length,equals(0));
          expect(store.state.auctions["xcvbbnbj89jk"].bids.containsKey(aUser.uid),isFalse);
            }); 
        test("checkout",(){
            
           // expect(true,equals(false));
            }); 
        test("confirmOrder",(){
            
          //  expect(true,equals(false));
            }); 
        test("cancelOrder",(){
            
           // expect(true,equals(false));
            }); 
        test("deleteAuction",(){
            
          //  expect(true,equals(false));
            }); 

        test("deleteItem",(){
            ItemInfo itemInfo= (new Item()
                            ..itemId="xcvbbnbj89jk"
                            ..seller=(new userInfo()
                                ..uid="12345890"
                                ..userName="john wink"
                                ..avator="somepic.jp"
                                 )
                            ..title="some product"
                            ..priceUnit=98989889.00     

                   );
           // cart.deleteItem(itemInfo);
           // expect(store.state.items[itemInfo],equals(null));
            }); 
    	});
/*
* billing management
*/

group("[BILLING_MANAGER]:-",(){

    	});



/*
* content management
*/
group("[CONTENT_MANAGER]",(){

    	});
/*	
* ads management
* 
*/
group("[ADS_MANAGER]",(){


    	});
/*
* clean up
*/


}
