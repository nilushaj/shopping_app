import 'package:flutter/material.dart';
import 'package:shopping_app/blocs/shopping_bloc.dart';
import 'package:shopping_app/helper/utils.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/models/network_models/shopping_list.dart';

class ShoppingListScreen extends StatefulWidget {
  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _height = Utils.totalBodyHeight;
  final _width = Utils.bodyWidth;

  ShoppingBloc _shoppingBloc;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shoppingBloc = Provider.of<ShoppingBloc>(context);
    if (!_isLoaded) {
      _shoppingBloc.getShoppingItemList();
      _isLoaded = true;
    }
  }

  List<String> _sortOptions = ['Price', 'Alphabatical'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: _width * 0.03),
            child: InkWell(
              onTap: () {
                _shoppingBloc.cartTotal();
                Navigator.pushNamed(context, '/cart');
              },
              child: Stack(
                children: <Widget>[
                  Container(
                    child: Icon(Icons.shopping_cart),
                    height: _height * 0.08,
                    width: _width * 0.1,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: StreamBuilder(
                        stream: _shoppingBloc.cartStream,
                        builder: (context, snapshot) {
                          return (snapshot.hasData && snapshot.data.length > 0)
                              ? Container(
                                  margin: EdgeInsets.only(top: 4),
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    "${snapshot.data.length}",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10),
                                    textAlign: TextAlign.center,
                                  ),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red),
                                )
                              : Container();
                        }),
                  )
                ],
              ),
            ),
          ),
        ],
        title: Text(
          "Let\'s Buy",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Container(
                  margin: EdgeInsets.only(
                      right: _width * 0.07, top: _height * 0.03),
                  child: StreamBuilder<Object>(
                      stream: _shoppingBloc.sortedOptionStream,
                      builder: (context, snapshot) {
                        return DropdownButton(
                          hint: Text('Sort By'), // Not necessary for Option 1
                          value: snapshot.data,
                          onChanged: (newValue) {
                            _shoppingBloc.sortData(newValue);
                          },
                          items: _sortOptions.map((location) {
                            return DropdownMenuItem(
                              child: new Text(location),
                              value: location,
                            );
                          }).toList(),
                        );
                      })),
            ),
            Expanded(
              child: StreamBuilder(
                  stream: _shoppingBloc.shoppingItemStream,
                  builder: (context, AsyncSnapshot<List<Item>> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.length != 0) {
                        return ListView.builder(
                            padding: EdgeInsets.only(top: _height * 0.03),
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                child: _customListTile(
                                    id: snapshot.data[index].productId,
                                    title: snapshot.data[index].productElements
                                        .title.title,
                                    unitPrice: snapshot.data[index]
                                        .productElements.price.sellPrice.value,
                                    image: snapshot.data[index].productElements
                                        .image.imgUrl),
                                onTap: () {
                                  _shoppingBloc.reset();
                                  _showDialog(
                                      id: snapshot.data[index].productId,
                                      title: snapshot.data[index]
                                          .productElements.title.title,
                                      price: snapshot
                                          .data[index]
                                          .productElements
                                          .price
                                          .sellPrice
                                          .value,
                                      image: snapshot.data[index]
                                          .productElements.image.imgUrl);
                                },
                              );
                            });
                      } else {
                        return Center(child: Text("No Data"));
                      }
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customListTile(
      {int id, double unitPrice, String title, String image}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(6.0),
          ),
          boxShadow: [
            BoxShadow(
                offset: Offset(0.0, 3.0), color: Colors.grey.withOpacity(0.4))
          ]),
      margin: EdgeInsets.only(
          left: _width * 0.05, right: _width * 0.05, bottom: _height * 0.01),
      padding: EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Unit Price : \$"
                    "$unitPrice"),
                Text(
                  "Item : $title",
                ),
              ],
            ),
          ),
          Container(
            height: _height * 0.1,
            width: _width * 0.2,
            child: image.contains("http")
                ? Image.network(image)
                : Container(
                    color: Colors.grey,
                    child: Icon(Icons.image),
                  ),
          ),
        ],
      ),
    );
  }

  void _showDialog({String image, String title, double price, int id}) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 600),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            child: SizedBox.expand(
                child: _addToCartBody(
                    id: id, title: title, price: price, image: image)),
            margin: EdgeInsets.only(
                bottom: _height * 0.07,
                left: _width * 0.05,
                right: _width * 0.05,
                top: _height * 0.1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  Widget _addToCartBody({String image, String title, double price, int id}) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: StreamBuilder(
            initialData: 1,
            stream: _shoppingBloc.getiItemCount,
            builder: (context, snapshot) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: _height * 0.04),
                    width: _width * 0.8,
                    height: _height * 0.3,
                    child: image.contains("http")
                        ? Image.network(image)
                        : Container(
                            color: Colors.grey,
                            child: Icon(Icons.image),
                          ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: _height * 0.03),
                    child: Text(
                      "\$$price",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: _height * 0.03, left: 10, right: 10),
                    child: Text(
                      "$title",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          color: Colors.black),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: _height * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          shape: CircleBorder(),
                          onPressed: () {
                            _shoppingBloc.reduceItems();
                          },
                          elevation: 4,
                          color: Colors.blue,
                          child: Text(
                            "-",
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              right: _width * 0.02, left: _width * 0.02),
                          child: Text(
                            "${snapshot.data}",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        RaisedButton(
                          shape: CircleBorder(),
                          onPressed: () {
                            _shoppingBloc.addItems();
                          },
                          elevation: 4,
                          color: Colors.blue,
                          child: Text(
                            "+",
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(
                          top: _height * 0.06, bottom: _height * 0.06),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            height: _height * 0.05,
                            width: _width * 0.3,
                            child: RaisedButton(
                              shape: StadiumBorder(),
                              color: Colors.red,
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ),
                          Container(
                            height: _height * 0.05,
                            width: _width * 0.3,
                            child: RaisedButton(
                              shape: StadiumBorder(),
                              color: Colors.green,
                              onPressed: () {
                                Navigator.pop(context);
                                _shoppingBloc.addToCart(
                                    id, image, title, snapshot.data, price);
                              },
                              child: Text(
                                "Buy",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ))
                ],
              );
            }),
      ),
    );
  }

  Future<void> _onRefresh() async {
    _shoppingBloc.getShoppingItemList();
  }
}
