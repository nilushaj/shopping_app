import 'package:shopping_app/helper/network.dart';
import 'package:shopping_app/models/cartModel.dart';
import 'package:shopping_app/models/network_models/shopping_list.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

import 'base_bloc.dart';

class ShoppingBloc extends BaseBloc {
  final _networkCalls = Network.shared;

  //List of Order Subject
  BehaviorSubject<List<Item>> _shoppingItemSubject =
      BehaviorSubject<List<Item>>();

  Stream<List<Item>> get shoppingItemStream => _shoppingItemSubject.stream;
  PublishSubject<bool> _isLoading = PublishSubject<bool>();
  Stream<bool> get isLoading => _isLoading.stream;

  PublishSubject<int> _itemCount = PublishSubject<int>();
  Stream<int> get getiItemCount => _itemCount.stream;
  int items = 1;

  PublishSubject<String> _sortedOptionSubject = PublishSubject<String>();
  Stream<String> get sortedOptionStream => _sortedOptionSubject.stream;

  BehaviorSubject<List<CartModelData>> _cartSubject =
      BehaviorSubject<List<CartModelData>>();
  Stream<List<CartModelData>> get cartStream => _cartSubject.stream;

  BehaviorSubject<double> _cartTotal = BehaviorSubject<double>();
  Stream<double> get cartTotalStream => _cartTotal.stream;

  getShoppingItemList() async {
    _isLoading.add(true);
    await _getUserToDo().then((success) {
      _isLoading.add(false);
    });
  }

  void addItems() {
    items += 1;
    _itemCount.add(items);
  }

  void reduceItems() {
    if (items != 1) {
      items -= 1;
    }
    _itemCount.add(items);
  }

  void reset() {
    items = 1;
    _itemCount.add(items);
  }

  void sortData(String option) {
    _sortedOptionSubject.add(option);
    List<Item> filtered = _shoppingItemSubject.value;
    if (option == "Price") {
      filtered.sort((e1, e2) => e1.productElements.price.sellPrice.value
          .compareTo(e2.productElements.price.sellPrice.value));
    } else {
      filtered.sort((e1, e2) => e1.productElements.title.title
          .compareTo(e2.productElements.title.title));
    }

    _shoppingItemSubject.add(filtered);
  }

  void addToCart(
      int id, String image, String title, int count, double unitPrice) {
    if (_cartSubject.value != null) {
      List<CartModelData> cartItems = _cartSubject.value;
      cartItems.add(CartModelData(
          id: id,
          image: image,
          count: count,
          title: title,
          unitPrice: unitPrice));
      List<CartModelData> reducedList = [];

      // Iterate through the unique ids and add reduced form of products
      cartItems.map((e) => e.id).toSet().toList().forEach((id) {
        reducedList.add(cartItems.where((p) => p.id == id).reduce((e1, e2) =>
            CartModelData(
                id: e1.id,
                image: e1.image,
                count: (e1.count + e2.count),
                title: e1.title,
                unitPrice: e1.unitPrice)));
      });
      _cartSubject.add(reducedList);
    } else {
      List<CartModelData> cartItems = [];
      cartItems.add(CartModelData(
          id: id,
          image: image,
          count: count,
          title: title,
          unitPrice: unitPrice));
      _cartSubject.add(cartItems);
    }
  }

  void cartTotal() {
    if (_cartSubject.value != null) {
      _cartTotal.add(_cartSubject.value.fold<double>(
          0.00,
          (previousValue, product) =>
              previousValue + (product.count * product.unitPrice)));
    } else {
      _cartTotal.add(0.00);
    }
  }

  void clearPurchaseItems() {
    _cartSubject.add([]);
  }

  Future<bool> _getUserToDo() async {
    try {
      GetShoppingList shoppingListModel =
          await _networkCalls.getShoppingItems();

      _shoppingItemSubject.add(shoppingListModel.data.items);

      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  dispose() {
    _shoppingItemSubject.close();
    _isLoading.close();
    _sortedOptionSubject.close();
    _cartSubject.close();
    _cartTotal.close();
  }
}
