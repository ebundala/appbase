import "dart:async";
//import "package:redux/redux.dart";
////import "../states/state.dart";
import "../states/actionsTypes.dart";
import "../states/shoppingCart/ShoppingCartState.dart";
import '../states/user/userState.dart';
import 'AppBase.dart';

class ShoppingCart extends AppBase{
  var _categoriesRef;
  var _itemsRef;
  var _ratingsRef;
  var _abuseRef;
  var _ordersRef;
  var _auctionsRef;
  var _likesRef;
  var _cartRef;
  var _commentsRef;
  ShoppingCart({store,appRef}):super(store:store,className:"ShoppingCart",ref:appRef){
    _itemsRef=ref.child("items");
    _auctionsRef=ref.child("auctions");
    _ordersRef=ref.child("orders");
    _categoriesRef=ref.child("categories");
    _cartRef=ref.child("cart");
    _likesRef=ref.child("likes");
    _abuseRef=ref.child("abuses");
    _ratingsRef=ref.child("ratings");
    _commentsRef=ref.child("comments");


  }

  Future<Item> createItem(Item item) async{
    logInfo('createItem');

    try {
      logInfo('reached');
      var itemMap=_ItemToMap(item);
      await _itemsRef.child(item.itemId).set(itemMap);
      logInfo('reached2');
      var itemData = await _itemsRef.child(item.itemId).get();
      //logInfo(itemData);
      if (itemData != null) {
      Item itemIns = _itemInfoChanged(itemData);

      store.dispatch(new Action(type: ActionsTypes.createItem, data: itemIns));
      return itemIns;
    }
    else{
        throw new AppError(actionType: ActionsTypes.createItem,payload: item,message: "failed to post item");
      }

    }catch(e,st){
      logError(e,ActionsTypes.createItem,st);
    }

  }
  _itemType(type){
    switch(type){
      case "ItemType.digital":
        return ItemType.digital;
      case "ItemType.physical":
        return ItemType.physical;
    }
  }
  _sellType(type){
    switch(type){
      case "SellMode.auctionSell":
        return SellMode.auctionSell;
      case "SellMode.directSell":
        return SellMode.directSell;
    }
  }
  _itemCondition(type){
    switch(type){
      case "ItemCondition.brandNew":
        return ItemCondition.brandNew;
      case "ItemCondition.refurbished":
        return ItemCondition.refurbished;
      case "ItemCondition.needRepair":
        return ItemCondition.needRepair;
      case "ItemCondition.secondHand":
        return ItemCondition.secondHand;
      case "ItemCondition.unRepairable":
        return ItemCondition.unRepairable;
      default:
        return ItemCondition.unknown;
    }
  }
  Map _ItemToMap(Item item){
   var itemMap= {
      "itemId": item.itemId,
    "seller": {
    "uid": item.seller.uid,
    "userName": item.seller.userName,
    "avator": item.seller.avator
    },
    "title": item.title,
    "priceUnit": item.priceUnit,
    "quantity": item.quantity,
    "quantitySold": item.quantitySold,
    "qUnits": item.qUnits,
    "condition": item.condition.toString(),
    "type": item.type.toString(),
    "mode": item.mode.toString(),
    "description": item.description,
    "featuredImage": item.featuredImage,
    //"additionalImage": item.additionalImages.asMap(),
   // "categories":{},
    // "subCategories": item.subCategories,
    // "auctionInfo": item.auctionInfo
  };

   if(item.additionalImages.length>0){
     var list =new Map();
     var i=0;
     item.additionalImages.forEach((val){
       list["$i"]=val;
       i++;
     });
     itemMap["additionalImages"]=list;
   }

   if(item.categories.length>0){
     var list =new Map();
     item.categories.forEach((key,val){
       list[key]={"catId":val.catId,"name":val.name};
     });
     itemMap["categories"]=list;
   }
   if(item.subCategories.length>0){
     var list =new Map();
     item.subCategories.forEach((key,val){
       list[key]={"catId":val.catId,"name":val.name,"parentId":val.parentId};
     });
     itemMap["subCategories"]=list;
   }

   return itemMap;
  }
  Item _itemInfoChanged(itemInfo){


    Item item= (new Item()
      ..itemId = itemInfo["itemId"]
      ..title = itemInfo["title"]
      ..priceUnit = itemInfo["priceUnit"]
      ..quantity = itemInfo["quantity"]
      ..quantitySold = itemInfo["quantitySold"]
      ..qUnits = itemInfo["qUnits"]
      ..condition = _itemCondition(itemInfo["condition"])
      ..type = _itemType(itemInfo["type"])
      ..mode = _sellType(itemInfo["mode"])
      ..description = itemInfo["description"]
      ..featuredImage = itemInfo["featuredImage"]
    );

    logInfo(itemInfo["seller"]);
    if(itemInfo["seller"]!=null){
      item.seller=(new userInfo()
        ..uid=itemInfo["seller"]["uid"]
        ..userName=itemInfo["seller"]["userName"]
        ..avator=itemInfo["seller"]["avator"]
      );
    }

    logInfo(itemInfo["additionalImages"]);
    if(itemInfo["additionalImages"]!=null){
      itemInfo["additionalImages"].forEach((key,image){
        logInfo("$image");
        item.additionalImages.add(image);
      });

    }
    logInfo(itemInfo["categories"]);
    if(itemInfo["categories"]!=null){
      itemInfo["categories"].forEach((key,image){
        item.categories[key]=(new Category()
                                    ..catId=itemInfo["categories"][key]["catId"]
                                        ..name=itemInfo["categories"][key]["name"]

        );
      });
    }
    logInfo(itemInfo["subCategories"]);
    if(itemInfo["subCategories"]!=null){
      itemInfo["subCategories"].forEach((key,image){
        item.subCategories[key]=(new SubCategory()
          ..catId=itemInfo["subCategories"][key]["catId"]
          ..name=itemInfo["subCategories"][key]["name"]
          ..parentId=itemInfo["subCategories"][key]["parentId"]
        );
      });
    }

    if(itemInfo["auctionInfo"]!=null){

        item.auctionInfo=(new AuctionInfo()

                            ..start=itemInfo["auctionInfo"]["start"]
                            ..end=itemInfo["auctionInfo"]["end"]
                            ..status=true
                            ..seller=(new userInfo()
                              ..uid=itemInfo["auctionInfo"]["seller"]["uid"]
                              ..avator=itemInfo["auctionInfo"]["seller"]["avator"]
                              ..userName=itemInfo["auctionInfo"]["seller"]["userName"]
                            )
                            ..item=(new ItemInfo()
                              ..itemId=itemInfo["auctionInfo"]["item"]["itemId"]
                                ..title=itemInfo["auctionInfo"]["item"]["title"]
                                ..priceUnit=itemInfo["auctionInfo"]["item"]["priceUnit"]
                                ..seller=(new userInfo()
                                  ..uid=itemInfo["auctionInfo"]["item"]["seller"]["uid"]
                                  ..avator=itemInfo["auctionInfo"]["item"]["seller"]["avator"]
                                  ..userName=itemInfo["auctionInfo"]["item"]["seller"]["userName"]
                                )
                            )
                            ..highestBid=(new Bid()
                              ..uid=itemInfo["auctionInfo"]["highestBid"]["uid"]
                              ..avator=itemInfo["auctionInfo"]["highestBid"]["avator"]
                              ..userName=itemInfo["auctionInfo"]["highestBid"]["userName"]
                              ..bidValue=itemInfo["auctionInfo"]["highestBid"]["bidValue"]
                               ..item=(new ItemInfo()
                                ..itemId=itemInfo["auctionInfo"]["highestBid"]["item"]["itemId"]
                                ..title=itemInfo["auctionInfo"]["highestBid"]["item"]["title"]
                                ..priceUnit=itemInfo["auctionInfo"]["highestBid"]["item"]["priceUnit"]
                                ..seller=(new userInfo()
                                  ..uid=itemInfo["auctionInfo"]["highestBid"]["item"]["seller"]["uid"]
                                  ..avator=itemInfo["auctionInfo"]["highestBid"]["item"]["seller"]["avator"]
                                  ..userName=itemInfo["auctionInfo"]["highestBid"]["item"]["seller"]["userName"]
                                )
                            ))
                            ..minimumBid=(new Bid()
                              ..uid=itemInfo["auctionInfo"]["minimumBid"]["uid"]
                              ..avator=itemInfo["auctionInfo"]["minimumBid"]["avator"]
                              ..userName=itemInfo["auctionInfo"]["minimumBid"]["userName"]
                              ..bidValue=itemInfo["auctionInfo"]["minimumBid"]["bidValue"]
                              ..item=(new ItemInfo()
                                ..itemId=itemInfo["auctionInfo"]["minimumBid"]["item"]["itemId"]
                                ..title=itemInfo["auctionInfo"]["minimumBid"]["item"]["title"]
                                ..priceUnit=itemInfo["auctionInfo"]["minimumBid"]["item"]["priceUnit"]
                                ..seller=(new userInfo()
                                  ..uid=itemInfo["auctionInfo"]["minimumBid"]["item"]["seller"]["uid"]
                                  ..avator=itemInfo["auctionInfo"]["minimumBid"]["item"]["seller"]["avator"]
                                  ..userName=itemInfo["auctionInfo"]["minimumBid"]["item"]["seller"]["userName"]
                                )
                              ))
                            ..auctionId=itemInfo["auctionInfo"]["auctionId"]

        );

    }
    return item;
  }

  Future<Item> editItem(Item item) async{
    logInfo('editItem');
    try{
      Item itemInst=await createItem(item);
    store.dispatch(new Action(type: ActionsTypes.editItem, data: itemInst));
    return itemInst;
    }catch(e,st){
      logError(e,ActionsTypes.editItem,st);
    }

  }
  Future<Cart> addToCart(CartItemInfo itemInfo) async{
    logInfo('addToCart');
    User aUser=store.state.currentUser;
    try{
      var cartVal=await _cartRef.child(aUser.uid).get();
      var cartInst;
      if(cartVal!=null){
        cartInst=_cartInfoChanged(cartVal);
      }
      var cartMap=_cartToMap(itemInfo,cartInst);
      logInfo(cartMap);
      await _cartRef.child(aUser.uid).set(cartMap);
      cartVal=await _cartRef.child(aUser.uid).get();
      if(cartVal!=null){
        cartInst=_cartInfoChanged(cartVal);
      store.dispatch(new Action(type: ActionsTypes.addToCart, data: cartInst));
      return cartInst;
      }
      else{
        throw new AppError(actionType: ActionsTypes.addToCart,payload: itemInfo,message:"failed to add item to cart");
      }
    }catch(e,st){
      logError(e,ActionsTypes.addToCart,st);
    }

  }
  Cart _cartInfoChanged(info){
    Cart cart=(new Cart()
        ..uid=info["uid"]
        ..avator=info["avator"]
        ..userName=info["userName"]
        ..grandTotal=info["grandTotal"]
        ..invoiceNo=info["invoiceNo"]

    );

    if(info["items"]!=null){
      info["items"].forEach((key,val){
        cart.items[key]=(new CartItemInfo()
          ..title=val["title"]
          ..featuredImage=val["featuredImage"]
          ..quantity=val["quantity"]
          ..subTotal=val["subTotal"]
          ..itemId=val["itemId"]
          ..priceUnit=val["priceUnit"]
            ..seller=(new userInfo()
              ..uid=val["seller"]["uid"]
              ..avator=val["seller"]["avator"]
              ..userName=val["seller"]["userName"])
        );
      });
    }

    return cart;
  }
  Map _cartToMap(CartItemInfo info,cart){
    User aUser=store.state.currentUser;


    Map cartMap={
      "uid":aUser.uid,
      "userName":aUser.displayName,
      "avator":aUser.photoUrl,
      "grandTotal":0.0


    };
    if(info!=null){
       var list=new Map();
      if ( cart!= null)
      {
        cart.items.forEach((key,val){
          cartMap["grandTotal"]+=(val.quantity*val.priceUnit);
          list["$key"]={
            "itemId":val.itemId,
            "title":val.title,
            "featuredImage":val.featuredImage,
            "priceUnit":val.priceUnit,
            "quantity":val.quantity,
            "subTotal":val.quantity*val.priceUnit,
            "seller":{
              "uid":val.seller.uid,
              "userName":val.seller.userName,
              "avator":val.seller.avator
            }
          };
        });
      }

      cartMap["grandTotal"]+=(info.quantity*info.priceUnit);

     list[info.itemId]={
        "itemId":info.itemId,
        "title":info.title,
        "featuredImage":info.featuredImage,
        "priceUnit":info.priceUnit,
        "quantity":info.quantity,
       "subTotal":info.quantity*info.priceUnit,
        "seller":{
          "uid":info.seller.uid,
          "userName":info.seller.userName,
          "avator":info.seller.avator
        }
      };
       cartMap["items"]=list;


    }

    return cartMap;
  }

  void deleteItem(ItemInfo item) {
    logInfo('deleteItem');
    try{

    }catch(e,st){
      logError(e,ActionsTypes.deleteItem,st);
    }
    store.dispatch(new Action(type: ActionsTypes.deleteItem, data: item));
  }



  void removeFromCart(CartItemInfo item) {
    logInfo('removeFromCart');
    try{

    }catch(e,st){
      logError(e,ActionsTypes.removeFromCart,st);
    }
    store.dispatch(new Action(type: ActionsTypes.removeFromCart, data: item));
  }

  void editCart(CartItemInfo cartItem) {
    logInfo('editCart');
    try{

    }catch(e,st){
      logError(e,ActionsTypes.editCart,st);
    }
    store.dispatch(new Action(type: ActionsTypes.editCart, data: cartItem));
  }

  void saveCart(Cart cart) {
    logInfo('saveCart');
    try{

    }catch(e,st){
      logError(e,ActionsTypes.saveCart,st);
    }
    store.dispatch(new Action(type: ActionsTypes.saveCart, data: cart));
  }

  void deleteCart() {
    logInfo('deleteCart');
    try{

    }catch(e,st){
      logError(e,ActionsTypes.deleteCart,st);
    }
    store.dispatch(new Action(type: ActionsTypes.deleteCart, data: null));
  }

  Future<Auction> createAuction({AuctionInfo info, Item item}) async{
    logInfo('createAuction');
    try{


      Auction auction = (new Auction()
        ..seller = info.seller
        ..item = info.item
        ..auctionId = info.auctionId
        ..start = info.start
        ..end = info.end
        ..status = info.status
        ..highestBid = info.highestBid
        ..minimumBid = info.minimumBid);
       item.auctionInfo=info;

     var edited=await editItem(item);
      store.dispatch(new Action(type: ActionsTypes.createAuction, data: auction));
    }catch(e,st){
      logError(e,ActionsTypes.createAuction,st);
    }

  }

  void deleteAuction({Auction auction, Item item}) {
    logInfo('deleteAuction');
    try{

    }catch(e,st){
      logError(e,ActionsTypes.deleteAuction,st);
    }
    store.dispatch(new Action(type: ActionsTypes.createAuction, data: auction));
  }

  void placeBid(Bid bid) {
    logInfo('placeBid');
    try{

    }catch(e,st){
      logError(e,ActionsTypes.placeBid,st);
    }
    store.dispatch(new Action(type: ActionsTypes.placeBid, data: bid));
  }

  void updateBid(Bid bid) {
    logInfo('updateBid');
    try{

    }catch(e,st){
      logError(e,ActionsTypes.updateBid,st);
    }
    store.dispatch(new Action(type: ActionsTypes.updateBid, data: bid));
  }

  void removeBid(Bid bid) {
    logInfo('removeBid');
    try{

    }catch(e,st){
      logError(e,ActionsTypes.removeBid,st);
    }
    store.dispatch(new Action(type: ActionsTypes.removeBid, data: bid));
  }

  void checkout() {
    logInfo('checkout');
    try{

    }catch(e,st){
      logError(e,ActionsTypes.checkout,st);
    }
  }
  void confirmOrder(Order order) {
    logInfo('confirmOrder');
    try{

    }catch(e,st){
      logError(e,ActionsTypes.confirmOrder,st);
    }
    store.dispatch(new Action(type: ActionsTypes.confirmOrder, data: order));
  }

  void cancelOrder(Order order) {
    logInfo('cancelOrder');
    try{

    }catch(e,st){
      logError(e,ActionsTypes.cancelOrder,st);
    }
    store.dispatch(new Action(type: ActionsTypes.cancelOrder, data: order));
  }

  void editOrder(Order order) {
    logInfo('editOrder');
    try{

    }catch(e,st){
      logError(e,ActionsTypes.editOrder,st);
    }
    store.dispatch(new Action(type: ActionsTypes.editOrder, data: order));
  }




}
