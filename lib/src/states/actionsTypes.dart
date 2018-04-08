//import "package:dartson/dartson.dart";

class Action {
  final ActionsTypes type;
  final dynamic data;
  const Action({this.type, this.data = null});
}

class AppError {
  final dynamic actionType;
  final dynamic payload;
  final String message;
  const AppError(
      {this.actionType = null, this.payload = null, this.message = null});
}

enum ActionsTypes {
  //general ActionsTypes
  onError,
  clearError,
  loading,
  ready,

  //user management ActionsTypes
  login,
  register,
  logout,
  givePermission,
  revokePermission,
  setUserMetadata,
  getUserMetadata,
  deleteUser,
  followUser,
  unfollowUser,
  redirectUser,
  userInfoChanged,
  //IM actionType
  createChat,
  deleteChat,
  getContacts,
  sendMessage,
  deleteMessage,
  addParticipant,
  removeParticipant,
  quoteMessage,
  forwardMessage,
  //shopping cart actionType
  createItem,
  editItem,
  deleteItem,
  addToCart,
  removeFromCart,
  editCart,
  saveCart,
  deleteCart,
  createAuction,
  deleteAuction,
  placeBid,
  updateBid,
  removeBid,
  checkout,
  confirmOrder,
  editOrder,
  cancelOrder,

  //content management
  createPost,
  editPost,
  deletePost,
  reportAbuse,
  like,
  unlike,
  comment,
  rate,
  share
}
