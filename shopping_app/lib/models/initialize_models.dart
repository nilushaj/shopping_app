import 'package:shopping_app/models/network_models/authenticate_user.dart';
import 'package:shopping_app/models/network_models/shopping_list.dart';

class InitializeData {
  static T fromJson<T>(dynamic json) {
    switch (T) {
      case bool:
        return json as T;
      case String:
        return json as T;
      case AuthenticateUser:
        return AuthenticateUser.fromJson(json) as T;
      case GetShoppingList:
        return GetShoppingList.fromJson(json) as T;
      default:
        throw Exception("Unknown class");
    }
  }
}
