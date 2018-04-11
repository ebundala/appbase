import 'package:logging/logging.dart';
import '../states/actionsTypes.dart';
import 'package:redux/redux.dart';
import '../states/state.dart';

class  AppBase {
   Logger log;
   final ref;
  final String className;
  Store<AppState> store;
  AppBase({this.className,this.store,this.ref}){
    log = new Logger(className);
  }
  void logInfo(dynamic info){
    log.info(info);
  }
   void logError(dynamic e, [ActionsTypes actionType, dynamic stackTrace]) {
     log.severe('error encountered!', e, stackTrace);
     store.dispatch(new Action(
         type: ActionsTypes.onError,
         data: (e is! AppError ? {"payload": e, "actionType": actionType} : e)));
   }
}