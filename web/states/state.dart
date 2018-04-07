
/*
* created by ebundala 
* states for the app
* 
* */
import "package:dartson/dartson.dart";
import "user/userState.dart";
import "IM/instantMessangerState.dart";
import "shopping_cart/shoppingCartState.dart";
import "actionsTypes.dart";




@Entity()
class AppState {
	bool isLoading;
	List<AppError> errors=[];
	User currentUser;
	Map<String,Chat> chats={};
	Map<String,Message> messages={};

	Map<String,Category> categories;
	Map<String,SubCategory> subCategories;

	Map<String,Item> items={};
	Map<String,Auction> auctions={};

	Map<String,Order> orders={};
	Cart shoppingCart;
	Map<String,Abuse> abuses={};
	Map<String,Comment> comments={};
	Map<String,Like> likes={};
	Map<String,Rating> ratings={};
}
