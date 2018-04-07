
import "state.dart";
import "user/userState.dart";
import "IM/instantMessangerState.dart";
import "shoppingCart/shoppingCartState.dart";
import "actionsTypes.dart";






AppState rootReducer(AppState prevState,dynamic<Action> action){
	switch(action.type){
/*

* general actions reducers
* 
* 
* */

		case ActionsTypes.onError:
		//todo handle capturing error
		AppState state= prevState;
		if(action.data is AppError){
		state.errors.add(new AppError(
			               actionType:action.data.actionType,
			               payload:action.data.payload,
			               message:action.data.message));
		}
		else{
			state.errors.add(new AppError(message:"unknown error occured",payload:action.data["payload"],actionType:action.data["actionType"]));
		}
		return state;
		break;
		case ActionsTypes.clearError:
		AppState state= prevState;
		state.errors.clear();
		return state;
		break;
/*

* user management states reducers
* 
* 
* 
* */
		case ActionsTypes.register:
        case ActionsTypes.userInfoChanged:
		case ActionsTypes.login:
		AppState state= prevState;
		state.currentUser=action.data;
		return state;
		break;

		case ActionsTypes.deleteUser:
		case ActionsTypes.logout:
		AppState state= prevState;
		state.currentUser=null;
		return state;
		break;
		
		case ActionsTypes.followUser:
		AppState state= prevState;
		if(state.currentUser.uid!=null){
		state.currentUser.following[action.data.uid]= (new follow()
															..uid=action.data.uid
												            ..userName=action.data.userName
												            ..avator=action.data.avator
												            );
			return state;
		}
		return prevState;
		break;

		case ActionsTypes.unfollowUser:
        AppState state= prevState;
        if(state.currentUser.uid!=null){
		state.currentUser.following[action.data.uid]=(new unfollow()
															..uid=action.data.uid
												            ..userName=action.data.userName
												            ..avator=action.data.avator);
		return state;
		}
		return prevState;
		break;
		
        
		case ActionsTypes.givePermission:
	    AppState state= prevState;
	    if(state.currentUser.uid!=null){
		state.currentUser.permissions[action.data.id]=(new permission()
															..id=action.data.id
															..name=action.data.name);
		return state;
		}
		return prevState;
		break;

		case ActionsTypes.revokePermission:
		AppState state= prevState;
		if(state.currentUser.uid!=null){
		state.currentUser.permissions[action.data.id]=(new revokePermission()
															..id=action.data.id
															..name=action.data.name);
		return state;
		}
		return prevState;
		break;

		case ActionsTypes.redirectUser:
		break;

		case ActionsTypes.setUserMetadata:
		break;

/*

* Instant messaging states reducers
* 
* 
* */
		case ActionsTypes.createChat:
		AppState state= prevState;
		if(state.currentUser.uid!=null){
		state.chats[action.data.chatId]=(new Chat()
												..chatId=action.data.chatId
												..creator=action.data.creator
												..participants=action.data.participants
												..lastMessage=action.data.lastMessage
												..timestamp=action.data.timestamp
												..type=action.data.type
												..title=action.data.title
												..metadata=action.data.metadata);
		return state;
	     }
	     return prevState;
		break;
		case ActionsTypes.deleteChat:
		AppState state= prevState;
		if(state.currentUser.uid!=null){
		state.chats[action.data.chatId]=null;
		return state;
	    }
	    return prevState;
		break;
		case ActionsTypes.sendMessage:
		AppState state= prevState;
		if(state.currentUser.uid!=null){
		state.messages[action.data.messageId]=(new Message()
													..chatId=action.data.chatId
													..sender=action.data.sender
													..messageText=action.data.messageText
													..imageUrl=action.data.imageUrl
													..metadata=action.data.metadata
													..timestamp=action.data.timestamp);
		return state;
	   }
	   return prevState;
		break;
		case ActionsTypes.deleteMessage:
		AppState state= prevState;
		if(state.currentUser.uid!=null){
		state.messages[action.data.messageId]=null;

			return state;
		}
		return prevState;
		break;
		case ActionsTypes.quoteMessage:
		break;
		case ActionsTypes.forwardMessage:
		break;
		case ActionsTypes.getContacts:
		break;

		case ActionsTypes.addParticipant:
		AppState state= prevState;
		if(state.currentUser.uid!=null){
		state.chats[action.data.chatId].participants[action.data.user.uid]=(new Participant()
																				..uid=action.data.user.uid
																				..userName=action.data.user.userName
																				..avator=action.data.user.avator);
			return state;
		}
		return prevState;
		break;

		case ActionsTypes.removeParticipant:
		AppState state= prevState;
		if(state.currentUser.uid!=null){
		state.chats[action.data.chatId].participants[action.data.user.uid]=(new NonParticipant()
																				..uid=action.data.user.uid
																				..userName=action.data.user.userName
																				..avator=action.data.user.avator);
			return state;
		}
		return prevState;
		break;
/*

* shopping cart state reducers
* 
*/
		case ActionsTypes.createItem:
		case ActionsTypes.editItem:
		AppState state= prevState;
		//modify state here
		if(state.currentUser.uid!=null){
		Item item=(new Item()
                            ..itemId=action.data.itemId
                            ..seller=(new userInfo()
                                ..uid=action.data.seller.uid
                                ..userName=action.data.seller.userName
                                ..avator=action.data.seller.avator
                                 )
                            ..title=action.data.title
                            ..priceUnit=action.data.priceUnit
                            ..quantity=action.data.quantity
                            ..quantitySold=action.data.quantitySold
                            ..qUnits=action.data.qUnits
                            ..condition=action.data.condition
                            ..type=action.data.type
                            ..mode=action.data.mode
                            ..description=action.data.description
                            ..featuredImage=action.data.featuredImage
                            ..additionalImages=action.data.additionalImages
                            ..categories=action.data.categories
                            ..subCategories=action.data.subCategories
                            ..auctionInfo=action.data.auctionInfo

                   );
		state.items[item.itemId]=item;
		return state;}
		return prevState;
		break;
		case ActionsTypes.deleteItem:
		AppState state= prevState;
		//modify state here
		if(state.currentUser.uid!=null){
		state.items.remove(action.data.itemId);
		return state;
	    }
		return prevState;
		break;
		case ActionsTypes.editCart:
		case ActionsTypes.addToCart:
			AppState state= prevState;
			//modify state here
			if(state.currentUser.uid!=null){
			CartItemInfo itemInfo=(new CartItemInfo()
	                            ..itemId=action.data.itemId
	                            ..seller=(new userInfo()
	                                ..uid=action.data.seller.uid
	                                ..userName=action.data.seller.userName
	                                ..avator=action.data.seller.avator
	                                 )
	                            ..title=action.data.title
	                            ..priceUnit=action.data.priceUnit
	                            ..quantity=action.data.quantity);
			
			if(state.shoppingCart==null){
				state.shoppingCart=new Cart();
			}
			state.shoppingCart.userName=state.currentUser.displayName;
			state.shoppingCart.avator=state.currentUser.photoUrl;
			state.shoppingCart.uid=state.currentUser.uid;
			state.shoppingCart.items[itemInfo.itemId]=itemInfo;
			return state;
			}
			return prevState;
		break;
		case ActionsTypes.removeFromCart:
			AppState state= prevState;
			//modify state here
			if((state.currentUser.uid!=null)&&(state.shoppingCart!=null)){
			state.shoppingCart.items.remove(action.data.itemId);
			return state;
			}
			return prevState;
		
		break;
		

		case ActionsTypes.saveCart:
		AppState state= prevState;
		//modify state here
		if(state.currentUser.uid!=null){
			//todo save cart here
		return state;
	    }
	    return prevState;
		break;
		case ActionsTypes.deleteCart:
		AppState state= prevState;
		//modify state here
		if((state.currentUser.uid!=null)&&(state.shoppingCart!=null)){
			state.shoppingCart.items.clear();

		return state;
		}
		return prevState;
		break;

		case ActionsTypes.createAuction:
		AppState state= prevState;
		//modify state here
    if((state.currentUser.uid!=null)){
    userInfo _userInfo=(new userInfo()
      ..uid=action.data.seller.uid
      ..userName=action.data.seller.userName
      ..avator=action.data.seller.avator
    );
    ItemInfo _itemInfo=(new ItemInfo()
      ..itemId=action.data.item.itemId
      ..priceUnit=action.data.item.priceUnit
      ..title=action.data.item.title
      ..seller=_userInfo
    );

			state.auctions[action.data.auctionId]=(new Auction()
				..seller=_userInfo
				..item=_itemInfo
				..auctionId=action.data.auctionId
				..start=action.data.start
				..end=action.data.end
				..status=action.data.status
				..highestBid=(new Bid()
          ..avator=action.data.highestBid.avator
          ..bidValue=action.data.highestBid.bidValue
          ..userName=action.data.highestBid.userName
          ..item=_itemInfo
        )
				..minimumBid=(new Bid()
          ..avator=action.data.minimumBid.avator
          ..bidValue=action.data.minimumBid.bidValue
          ..userName=action.data.minimumBid.userName
          ..item=_itemInfo
        )
				..bids=action.data.bids
				);
		return state;
		}
		return prevState;
		break;
		case ActionsTypes.deleteAuction:
		AppState state= prevState;
		//modify state here
		if(state.currentUser.uid!=null){
      state.auctions.remove(action.data.auctionId);
		return state;}
		return prevState;
		break;
    case ActionsTypes.updateBid:
		case ActionsTypes.placeBid:
		AppState state= prevState;
		//modify state here
		if(state.currentUser.uid!=null){
      state.auctions[action.data.auctionId].bids[action.data.uid]=(new Bid()
        ..bidValue=action.data.bidValue
        ..uid=action.data.uid
        ..userName=action.data.userName
        ..avator=action.data.avator
        ..item=(new ItemInfo()
          ..itemId=action.data.item.itemId
          ..featuredImage=action.data.item.featuredImage
          ..seller=(new userInfo()
            ..userName=action.data.item.seller.userName
            ..avator=action.data.item.seller.avator
            ..uid=action.data.item.seller.uid))
      );
		return state;
		}
		return prevState;
		break;

		case ActionsTypes.removeBid:
		AppState state= prevState;
		//modify state here
		if(state.currentUser.uid!=null){
      state.auctions[action.data.auctionId].bids.remove(action.data.uid);
		return state;}
		return prevState;
		break;
		case ActionsTypes.checkout:
		AppState state= prevState;
		//modify state here
		if(state.currentUser.uid!=null){
		return state;}
		return prevState;
		break;
		case ActionsTypes.confirmOrder:
		AppState state= prevState;
		//modify state here
		if(state.currentUser.uid!=null){
		return state;}
		return prevState;
		break;
		case ActionsTypes.cancelOrder:
		AppState state= prevState;
		//modify state here
		if(state.currentUser.uid!=null){
		return state;}
		return prevState;
		break;
/*

* 
* billing manager
* 
* 
*/
/*

* 
* content manager
* 
* 
*//*

* 
* ads manager
* 
* 
*/
		default:
		return prevState;

	}

	return prevState;
}

