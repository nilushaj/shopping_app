class GetShoppingList {

  Data _data;

  GetShoppingList.fromJson(Map<String, dynamic> json){
    _data = Data(json["data"]);
  }

  Data get data => _data;

}

class Data {

  List<Item> _items;

  Data(key) {
    _items = List<Item>.from(key["items"].map((x) => Item(x)));
  }

  List<Item> get items => _items;


}

class Item {

  ProductElements _productElements;
  int _productId;

  Item(key) {
    _productElements= ProductElements.fromJson(key["productElements"]);
    _productId=key["productId"];
  }

  ProductElements get productElements => _productElements;

  int get productId => _productId;


}

class ProductElements {


  ImageData _image;
  Price _price;
  Title _title;

  ProductElements.fromJson(Map<String, dynamic> json){
    _image= ImageData.fromJson(json["image"]);
    _price= Price.fromJson(json["price"]);
    _title= Title.fromJson(json["title"]);
  }

  Title get title => _title;

  Price get price => _price;

  ImageData get image => _image;


}

class ImageData {

  String _imgUrl;

  ImageData.fromJson(Map<String, dynamic> json) {
    _imgUrl= json["imgUrl"];
  }

  String get imgUrl => _imgUrl;

}

class Price {

  SellPrice _sellPrice;

  Price.fromJson(Map<String, dynamic> json) {
    _sellPrice= SellPrice.fromJson(json["sell_price"]);
  }

  SellPrice get sellPrice => _sellPrice;

}

class SellPrice {

  double _value;

  SellPrice.fromJson(Map<String, dynamic> json) {
    _value= json["value"].toDouble();
  }

  double get value => _value;


}

class Title {

  String _title;

  Title.fromJson(Map<String, dynamic> json) {
    _title= json["title"];
  }

  String get title => _title;


}
