import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/blocs/shopping_bloc.dart';
import 'package:shopping_app/helper/utils.dart';
import 'package:shopping_app/models/cartModel.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _height = Utils.totalBodyHeight;

  final _width = Utils.bodyWidth;

  ShoppingBloc _shoppingBloc;

  @override
  Widget build(BuildContext context) {
    _shoppingBloc = Provider.of<ShoppingBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cart",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
          stream: _shoppingBloc.cartStream,
          builder: (context, AsyncSnapshot<List<CartModelData>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length != 0) {
                return Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: EdgeInsets.only(
                            right: _width * 0.05, top: _height * 0.05),
                        child: StreamBuilder(
                            initialData: 0.00,
                            stream: _shoppingBloc.cartTotalStream,
                            builder: (context, cartSnapshot) {
                              return Text(
                                "\$${cartSnapshot.data.toStringAsFixed(2)}",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              );
                            }),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          padding: EdgeInsets.only(top: _height * 0.03),
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return _customListTile(
                                id: snapshot.data[index].id,
                                title: snapshot.data[index].title,
                                unitPrice: snapshot.data[index].unitPrice,
                                image: snapshot.data[index].image,
                                count: snapshot.data[index].count);
                          }),
                    ),
                    Container(
                      width: _width * 0.4,
                      height: 50,
                      margin: EdgeInsets.only(
                          top: _height * 0.03, bottom: _height * 0.03),
                      child: RaisedButton(
                        onPressed: () {
                          _showDialog();
                          _shoppingBloc.clearPurchaseItems();
                        },
                        color: Colors.green,
                        shape: StadiumBorder(),
                        child: Text(
                          "Purchase",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                );
              } else {
                return Center(child: Text("No Data"));
              }
            } else {
              return Center(child: Text("No Data"));
            }
          }),
    );
  }

  void _showDialog() {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 600),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            width: _width*0.7,
            height: _height*0.3,
            child: SizedBox.expand(child: _purchaseMessage()),
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

  Widget _purchaseMessage() {
    return Material(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: _width*0.6,
              child: Text("Your Order is Successfully Placed!",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
            ),
            Container(
              margin: EdgeInsets.only(top: _height*0.03),
              decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle
              ),
              width: 60,
              height: 60,
              child: Icon(
                Icons.done,
                color: Colors.white,
              ),
            ),
          ],
        ));
  }

  Widget _customListTile(
      {int id, double unitPrice, String title, String image, int count}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(6.0),
          ),
          boxShadow: [
            BoxShadow(
                offset: Offset(0.0, 2.0), color: Colors.grey.withOpacity(0.4))
          ]),
      margin: EdgeInsets.only(
          left: _width * 0.03, right: _width * 0.03, bottom: _height * 0.002),
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: _height * 0.07,
            width: _width * 0.1,
            child: image.contains("http")
                ? Image.network(image)
                : Container(
                    color: Colors.grey,
                    child: Icon(Icons.image),
                  ),
          ),
          Container(
            margin: EdgeInsets.only(left: _width * 0.03),
            child: Text(" x $count"),
          ),
          Container(
            alignment: Alignment.centerLeft,
            width: _width * 0.2,
            height: _height * 0.06,
            margin: EdgeInsets.only(left: _width * 0.03),
            child: Text(
              "$title",
              maxLines: 2,
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: _width * 0.03),
            child: Text(
              "\$${unitPrice.toStringAsFixed(2)}",
              maxLines: 2,
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: _width * 0.03),
            child: Text(
              "\$${(unitPrice * count).toStringAsFixed(2)}",
            ),
          ),
        ],
      ),
    );
  }
}
