import 'package:flutter/material.dart';
import 'package:shopping_app/blocs/content_bloc.dart';
import 'package:shopping_app/helper/enums.dart';
import 'package:shopping_app/screens/shopping_list_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ContentBloc _contentBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _contentBloc = Provider.of<ContentBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _contentBloc.pageChanged,
        initialData: HomeTabs.HOME,
        builder: (context, AsyncSnapshot<HomeTabs> snapshot) {
          switch (snapshot.data) {
            case HomeTabs.HOME:
              return ShoppingListScreen();
            case HomeTabs.MESSAGE:
              return Container();
            case HomeTabs.PROFILE:
              return Container();
            default:
              return Container();
          }
        },
      ),
      bottomNavigationBar: StreamBuilder(
          stream: _contentBloc.navigationEvent,
          builder: (context, AsyncSnapshot<int> snapshot) {
            return BottomNavigationBar(
              currentIndex: snapshot.data ?? 0,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  title: Text("Home"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  title: Text("Messages"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  title: Text("Profile"),
                ),
              ],
              onTap: (index) => _contentBloc.setNavigationEvent.add(index),
            );
          }
      ),
    );
  }
}
