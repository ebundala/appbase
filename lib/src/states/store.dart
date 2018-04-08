//import "package:dartson/dartson.dart";
import "actionsTypes.dart" show Action;

class Store {
  Store({this.reducer, this.state, this.middleware = null});
  dynamic state;
  final dynamic reducer;
  final List<Function> middleware;
  // var dson= new Dartson.JSON();

  void dispatch(Action action) {
    logger("ACTION", action);
    if (middleware != null) {
      for (int x = 0; x < middleware.length; x++)
        state = middleware[x](state, action);
    }

    if (reducer != null) {
      logger("PREV_STATE", state);
      state = reducer(state, action);
      logger("NEXT_ACTION", state);
    }
  }

  void logger(tag, data) {
    // print("[$tag]:\n ${dson.encode(data).replaceAll(",",",\n").replaceAll(":{",":{\n").replaceAll("{{","{\n{").replaceAll("}}","}\n}")}\n\n");
  }
}
