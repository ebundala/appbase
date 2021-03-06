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
   // "auctionInfo": new Map()
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

   if(item.auctionInfo!=null){

     itemMap["auctionInfo"]={
       "auctionId":item.auctionInfo.auctionId,
       "start":item.auctionInfo.start,
       "end":item.auctionInfo.end,
       "status":item.auctionInfo.status,
       "highestBid":item.auctionInfo.highestBid,
       "minimumBid":item.auctionInfo.minimumBid,
        "seller":{
         "uid":item.auctionInfo.seller.uid,
         "userName":item.auctionInfo.seller.userName,
         "avator":item.auctionInfo.seller.avator
       },
       "item":{
         "itemId":item.auctionInfo.item.itemId,
         "priceUnit":item.auctionInfo.item.priceUnit,
         "title":item.auctionInfo.item.title,
         "featuredImage":item.auctionInfo.item.featuredImage,
         "seller":{
             "uid":item.auctionInfo.item.seller.uid,
             "userName":item.auctionInfo.item.seller.userName,
             "avator":item.auctionInfo.item.seller.avator
             },
       }
     };


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
                            ..highestBid=itemInfo["auctionInfo"]["highestBid"]
                            ..minimumBid=itemInfo["auctionInfo"]["minimumBid"]
                            ..auctionId=itemInfo["auctionInfo"]["auctionId"]
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

    var list=new Map();
      if ( cart!= null)
      {
        cart.items.forEach((key,val){

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


    if(info!=null){
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
    }
    cartMap["items"]=list;
    cartMap["items"].forEach((key,val){
      cartMap["grandTotal"]+=(val["subTotal"]);
    });

    return cartMap;
  }

  Future<Cart> editCart(CartItemInfo cartItem) async{
    logInfo('editCart');
    try{
       var cart=await addToCart(cartItem);
       if(cart!=null){
         store.dispatch(new Action(type: ActionsTypes.editCart, data: cart));
         return cart;
       }
       else{
         throw new AppError(actionType: ActionsTypes.editCart,payload: cartItem,message: "failed to edit cart");
       }
    }catch(e,st){
      logError(e,ActionsTypes.editCart,st);
    }
  }
  Future<Cart> saveCart(Cart cart) async{
    logInfo('saveCart');
    try{
      User aUser=store.state.currentUser;
        var cartMap=_cartToMap(null,cart);
        await _cartRef.child(aUser.uid).set(cartMap);
        var cartVal=await _cartRef.child(aUser.uid).get();
        if(cartVal!=null){
          var cartInst=_cartInfoChanged(cartVal);
            store.dispatch(new Action(type: ActionsTypes.saveCart, data: cartInst));
        }
          else{
            throw new AppError(actionType: ActionsTypes.saveCart,payload: cart,message: "failed to save your cart");
          }
    }catch(e,st){
      logError(e,ActionsTypes.saveCart,st);
    }
  }
  Future<bool> deleteItem(Item item) async{
    logInfo('deleteItem');
    try{
     var itemRef= _itemsRef.child(item.itemId);
     await itemRef.set(null);
     var res=await itemRef.get();
     if(res==null){
       store.dispatch(new Action(type: ActionsTypes.deleteItem, data: item));
       return true;
     }
     else{
       throw new AppError(actionType: ActionsTypes.deleteItem,payload: item,message: "failed to delete item ");
     }

    }catch(e,st){
      logError(e,ActionsTypes.deleteItem,st);
      return false;
    }

  }

  Future<Null> removeFromCart(CartItemInfo item) async{
    logInfo('removeFromCart');
    try{
      User aUser=store.state.currentUser;
      await _cartRef.child(aUser.uid).child("items").child(item.itemId).set(null);
      var res=await _cartRef.child(aUser.uid).child("items").child(item.itemId).get();
      if(res==null){

        store.dispatch(new Action(type: ActionsTypes.removeFromCart, data: item));

        return res;
      }
      else{
        throw new AppError(actionType: ActionsTypes.removeFromCart,payload: item,message: "failed to remove item from your cart");
      }

    }catch(e,st){
      logError(e,ActionsTypes.removeFromCart,st);
    }

  }

  Future<bool> deleteCart() async{
    logInfo('deleteCart');
    try{
      User aUser=store.state.currentUser;
      await _cartRef.child(aUser.uid).set(null);

      var res=await _cartRef.child(aUser.uid).get();
      if(res==null) {
        store.dispatch(new Action(type: ActionsTypes.deleteCart, data: null));
      }else{
        throw new AppError(actionType: ActionsTypes.deleteCart,payload: res,message: "failed to clear your cart");
      }

    }catch(e,st){
      logError(e,ActionsTypes.deleteCart,st);
    }
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

     //todo make editing item and creating auction atomic transaction
     var edited=await editItem(item);
     logInfo(edited.auctionInfo);
     var auctionMap=_auctionToMap(auction);
     await _auctionsRef.child(info.auctionId).set(auctionMap);
     var auctionVal=await _auctionsRef.child(info.auctionId).get();
     if(auctionVal!=null){
       var auctionInstance=_auctionInfoChanged(auctionVal);
       store.dispatch(new Action(type: ActionsTypes.createAuction, data: auctionInstance));
       return auctionInstance;
     }
     else{
       throw new AppError(actionType: ActionsTypes.createAuction,payload: info,message: "failed to create auction");
     }

    }catch(e,st){
      logError(e,ActionsTypes.createAuction,st);
    }
 return new Auction();
  }

  Map _auctionToMap(Auction auction){
     Map auctionMap={
       "start":auction.start,
       "end":auction.end,
       "status":auction.status,
       "auctionId":auction.auctionId,
       "minimumBid":auction.minimumBid,
       "highestBid":auction.highestBid,
       "seller":{
         "uid":auction.seller.uid,
         "userName":auction.seller.userName,
         "avator":auction.seller.avator
       },
       "item":{
         "title":auction.item.title,
         "featuredImage":auction.item.featuredImage,
         "priceUnit":auction.item.priceUnit,
         "itemId":auction.item.itemId,
         "seller":{
             "uid":auction.item.seller.uid,
             "userName":auction.item.seller.userName,
             "avator":auction.item.seller.avator
             }
       },

     };
     var list= new Map();
     auction.bids.forEach((key,val){
       list[key]={
         "userName":val.userName,
         "avator":val.avator,
         "uid":val.uid,
         "auctionId":val.auctionId,
         "item":{
           "title":val.item.title,
           "priceUnit":val.item.priceUnit,
           "itemId":val.item.itemId,
           "featuredImage":val.item.featuredImage,
           "seller":{
             "uid":val.item.seller.uid,
             "userName":val.item.seller.userName,
             "avator":val.item.seller.avator
           }
       }
     };
     }
       );
     auctionMap["bids"]=list;

     return auctionMap;
  }
  Auction _auctionInfoChanged(info){
    Auction auction= (new Auction()
        ..auctionId=info["auctionId"]
        ..start=info["start"]
        ..end=info["end"]
        ..status=info["status"]
        ..minimumBid=info["minimumBid"]
        ..highestBid=info["highestBid"]
        ..seller=(new userInfo()
          ..userName=info["seller"]["userName"]
          ..avator=info["seller"]["avator"]
          ..uid=info["seller"]["uid"])
        ..item=(new ItemInfo()
            ..featuredImage=info["item"]["featuredImage"]
            ..itemId=info["itemId"]
            ..priceUnit=info["item"]["priceUnit"]
            ..title=info["item"]["title"]
            ..seller=(new userInfo()
              ..userName=info["item"]["seller"]["userName"]
              ..avator=info["item"]["seller"]["avator"]
              ..uid=info["item"]["seller"]["uid"]
            )
        )
    );

    if(info["bids"]!=null){
      info["bids"].forEach((key,val){

        auction.bids[key]=(new Bid()
            ..auctionId=val["auctionId"]
            ..avator=val["avator"]
            ..userName=val["userName"]
            ..uid=val["uid"]
            ..bidValue=val["bidValue"]
            ..item=(new ItemInfo()
              ..featuredImage=val["item"]["featuredImage"]
              ..itemId=val["itemId"]
              ..priceUnit=val["item"]["priceUnit"]
              ..title=info["item"]["title"]
              ..seller=(new userInfo()
                ..userName=val["item"]["seller"]["userName"]
                ..avator=val["item"]["seller"]["avator"]
                ..uid=val["item"]["seller"]["uid"]
              )
            )

        );
      });
    }


    return auction;
  }

  Future<bool> deleteAuction({Item item}) async{
    logInfo('deleteAuction');
    try{
      //todo make editing item and deleting auction atomic transaction
      Auction auction = (new Auction()
        ..seller = item.auctionInfo.seller
        ..item = item.auctionInfo.item
        ..auctionId = item.auctionInfo.auctionId
        ..start = item.auctionInfo.start
        ..end = item.auctionInfo.end
        ..status = item.auctionInfo.status
        ..highestBid = item.auctionInfo.highestBid
        ..minimumBid = item.auctionInfo.minimumBid);

      await _auctionsRef.child(auction.auctionId).set(null);
      var auctionVal=await _auctionsRef.child(auction.auctionId).get();
      if(auctionVal==null){
        item.auctionInfo=null;

        var edited=await editItem(item);
        // logInfo(edited.auctionInfo);
      if(edited.auctionInfo==null){
        store.dispatch(new Action(type: ActionsTypes.deleteAuction, data: auction));
        return true;
      }

      }

      throw new AppError(actionType: ActionsTypes.deleteAuction,payload: auction,message: "failed to delete auction");

    }catch(e,st){
      logError(e,ActionsTypes.deleteAuction,st);
      return false;
    }

  }

  Map _bidToMap(Bid bid){

    Map bidMap={
      "auctionId":bid.auctionId,
      "bidValue":bid.bidValue,
      "uid":bid.uid,
      "userName":bid.userName,
      "avator":bid.avator,
      "item":{
        "itemId":bid.item.itemId,
        "featuredImage":bid.item.featuredImage,
        "priceUnit":bid.item.priceUnit,
        "title":bid.item.title,
        "seller":{
          "uid":bid.item.seller.uid,
          "userName":bid.item.seller.userName,
          "avator":bid.item.seller.avator
        }
      }
    };

    return bidMap;
  }

  Bid _bidInfoChanged(info){
    Bid bidInstance=(new Bid()
      ..auctionId = info["auctionId"]
      ..bidValue = info["bidValue"]
      ..uid = info["uid"]
      ..userName = info["displayName"]
      ..avator = info["photoUrl"]
      ..item = (new ItemInfo()
        ..itemId = info["item"]["itemId"]
        ..featuredImage = info["item"]["featuredImage"]
        ..priceUnit=info["item"]["priceUnit"]
        ..seller = (new userInfo()
          ..userName = info["item"]["seller"]["userName"]
          ..avator = info["item"]["seller"]["avator"]
          ..uid = info["item"]["seller"]["uid"])));
    return bidInstance;
  }

  Future<Bid> placeBid(Bid bid) async{
    logInfo('placeBid');
    try{

      var bidRef=_auctionsRef.child(bid.auctionId).child("bids").child(bid.uid);
    var bidInfo=  await bidRef.get();

    if(bidInfo!=null) {
      if (bidInfo["bidValue"] > bid.bidValue) {
        throw new AppError(actionType: ActionsTypes.placeBid,
            payload: bid,
            message: "cant set bid to lower value than ${bidInfo["bidValue"]}");
      }
    }
      var bidMap=_bidToMap(bid);
     await bidRef.set(bidMap);
     bidInfo= await bidRef.get();

     if(bidInfo!=null){

       Bid bidInst=_bidInfoChanged(bidInfo);

       store.dispatch(new Action(type: ActionsTypes.placeBid, data: bidInst));
       return bidInst;
     }else{
       throw new AppError(actionType: ActionsTypes.placeBid,payload: bid,message: "failed to place a bid");
     }

    }catch(e,st){
      logError(e,ActionsTypes.placeBid,st);
      return new Bid();
    }

  }

  Future<Bid> updateBid(Bid bid) async{
    logInfo('updateBid');
    try{
      var bidInst=await placeBid(bid);
      if(bidInst!=null){
        store.dispatch(new Action(type: ActionsTypes.updateBid, data: bidInst));
        return bidInst;
      }
      else{
        throw new AppError(actionType: ActionsTypes.updateBid,payload: bid,message: "failed to update bid");
      }

    }catch(e,st){
      logError(e,ActionsTypes.updateBid,st);
      return new Bid();
    }

  }

  Future<bool> removeBid(Bid bid) async{
    logInfo('removeBid');
    try{
      var bidRef=_auctionsRef.child(bid.auctionId).child("bids").child(bid.uid);
      await bidRef.set(null);
      var res=await bidRef.get();

      if(res==null){
        store.dispatch(new Action(type: ActionsTypes.removeBid, data: bid));
        return true;
      }
      else{
        throw new AppError(actionType: ActionsTypes.removeBid,payload: bid,message: "failed to delete bid");
      }

    }catch(e,st){
      logError(e,ActionsTypes.removeBid,st);
      return false;
    }

  }

  Future<Order> checkout(Cart cart) async{
    logInfo('checkout');
    try{
   var orderConf=await confirmOrder(cart);
   if(orderConf!=null){
     return orderConf;
   }
   else{
     throw new AppError(actionType: ActionsTypes.checkout,payload: cart,message: "failed to check out");
   }
    }catch(e,st){
      logError(e,ActionsTypes.checkout,st);
    }
    return new Order();
  }

  _orderStatus(status){
    switch(status){
      case "OrderState.waiting":
        return OrderState.waiting;
      case "OrderState.canceled":
        return OrderState.canceled;
      case "OrderState.delivered":
        return OrderState.delivered;
      case "OrderState.returned":
        return OrderState.returned;
      case "OrderState.completed":
        return OrderState.completed;
      default:
        return OrderState.unknown;
    }
  }

  Map _orderToMap(Order info){
    Map orderMap={
      "orderId":info.orderId,
      "userName":info.userName,
      "avator":info.avator,
      "uid":info.uid,
      "status":info.status.toString(),
      "cart":_cartToMap(null,info.cart)
    };
    return orderMap;
  }

  Order _orderInfoChanged(info){

    Order order = (new Order()
      ..userName = info["userName"]
      ..uid = info["uid"]
      ..avator = info["avator"]
      ..orderId = info["orderId"]
      ..status = _orderStatus(info["status"])
      ..cart = _cartInfoChanged(info["cart"]));

    return order;
  }

  Future<Order> confirmOrder(Cart _cart) async{
    logInfo('confirmOrder');
    try {
      Order order = (new Order()
        ..userName = _cart.userName
        ..uid = _cart.uid
        ..avator = _cart.avator
        ..orderId = "key" //todo generate this key
        ..status = OrderState.waiting
        ..cart = (new Cart()
          ..avator = _cart.avator
          ..uid = _cart.uid
          ..invoiceNo = _cart.invoiceNo //todo generate invoice here
          ..userName = _cart.userName));

      if (_cart.items.length > 0) {
        _cart.items.forEach((key, item) {
          order.cart.grandTotal += (item.priceUnit * item.quantity);
          order.cart.items[key] = (new CartItemInfo()
            ..title = item.title
            ..quantity = item.quantity
            ..featuredImage = item.featuredImage
            ..subTotal = (item.quantity * item.priceUnit)
            ..priceUnit = item.priceUnit
            ..seller = (new userInfo()
              ..userName = item.seller.userName
              ..uid = item.seller.uid
              ..avator = item.seller.avator));
        });
      }
      var orderMap = _orderToMap(order);
      await _ordersRef.child(order.orderId).set(orderMap);
      var orderVal = await _ordersRef.child(order.orderId).get();
      if (orderVal != null) {
        var orderInstance=_orderInfoChanged(orderVal);
      store.dispatch(new Action(type: ActionsTypes.confirmOrder, data: orderInstance));
      return orderInstance;
        }
        else{
        throw new AppError(actionType: ActionsTypes.confirmOrder,payload: order,message: "failed to confirm your order");
      }

    }catch(e,st){
      logError(e,ActionsTypes.confirmOrder,st);
    }
 return new Order();
  }

  Future<bool> cancelOrder(Order order) async{
    logInfo('cancelOrder');
    try{

      await _ordersRef.child(order.orderId).set(null);
     var res= await _ordersRef.child(order.orderId).get();
      if(res==null){
        store.dispatch(new Action(type: ActionsTypes.cancelOrder, data: order));
        return true;
      }
      else{
        throw new AppError(actionType: ActionsTypes.cancelOrder,payload: order,message: "failed to cancel your order");
      }
    }catch(e,st){
      logError(e,ActionsTypes.cancelOrder,st);
    }
   return false;
  }

  Future<Order> editOrder(Order order) async{
    logInfo('editOrder');
    try{

      var orderMap = _orderToMap(order);
      await _ordersRef.child(order.orderId).set(orderMap);
    var orderVal = await _ordersRef.child(order.orderId).get();
    if (orderVal != null) {
    var orderInstance=_orderInfoChanged(orderVal);
    store.dispatch(new Action(type: ActionsTypes.editOrder, data: order));
    return orderInstance;
    }
    else{
    throw new AppError(actionType: ActionsTypes.editOrder,payload: order,message: "failed to edit your order");
    }
    }catch(e,st){
      logError(e,ActionsTypes.editOrder,st);
    }
    return new Order();
  }
}
