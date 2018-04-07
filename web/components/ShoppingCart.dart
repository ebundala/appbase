import "dart:async";
import "package:redux/redux.dart";
import "../states/state.dart";
import "../states/actionsTypes.dart";
import "../states/shoppingCart/ShoppingCartState.dart";
class ShoppingCart {
	final  Store<AppState> store;
	ShoppingCart({this.store});

void createItem(Item item){
	store.dispatch(new Action(type:ActionsTypes.createItem,data:item));
}
void editItem(Item item){
	store.dispatch(new Action(type:ActionsTypes.editItem,data:item));
}
void deleteItem(ItemInfo item){
	store.dispatch(new Action(type:ActionsTypes.deleteItem,data:item));
}
void addToCart(CartItemInfo itemInfo){
	store.dispatch(new Action(type:ActionsTypes.addToCart,data:itemInfo));
}
void removeFromCart(CartItemInfo item){
	store.dispatch(new Action(type:ActionsTypes.removeFromCart,data:item));
}
void editCart(CartItemInfo cartItem){
	store.dispatch(new Action(type:ActionsTypes.editCart,data:cartItem));
}
void saveCart(Cart cart){
	store.dispatch(new Action(type:ActionsTypes.saveCart,data:cart));
}
void deleteCart(){
	store.dispatch(new Action(type:ActionsTypes.deleteCart,data:null));
}
void createAuction({AuctionInfo info,Item item}) {
	Auction auction=(new Auction()
		                ..seller=info.seller
		                ..item=info.item
						..auctionId=info.auctionId
						..start=info.start
						..end=info.end
						..status=info.status
						..highestBid=info.highestBid
						..minimumBid=info.minimumBid
						);
	//item.auctionInfo=info;

	 editItem(item);
	store.dispatch(new Action(type:ActionsTypes.createAuction,data:auction));
}
void deleteAuction({Auction auction,Item item}){
store.dispatch(new Action(type:ActionsTypes.createAuction,data:auction));
}
void placeBid(Bid bid){
	store.dispatch(new Action(type:ActionsTypes.placeBid,data:bid));
}
void updateBid(Bid bid){
	store.dispatch(new Action(type:ActionsTypes.updateBid,data:bid));

}
void removeBid(Bid bid){
  store.dispatch(new Action(type:ActionsTypes.removeBid,data:bid));
}
void checkout(){}
void confirmOrder(){}
void cancelOrder(){}
}
