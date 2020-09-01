import 'package:flutter/material.dart';
import 'package:shopping_app/blocs/content_bloc.dart';
import 'package:shopping_app/blocs/shopping_bloc.dart';
import 'package:shopping_app/helper/strings.dart';
import 'package:shopping_app/screens/cart_screen.dart';
import 'package:shopping_app/screens/home_screen.dart';
import 'package:provider/provider.dart';

import 'blocs/app_initialization_bloc.dart';
import 'blocs/error_bloc.dart';
import 'screens/login/login_screen.dart';
import 'screens/splash_screen.dart';

class ShoppingAppHead extends StatelessWidget {

  ShoppingBloc _shoppingBloc=ShoppingBloc();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ErrorBloc>(
          create: (context) => ErrorBloc.getInstance,
          dispose: (_, value) => value.dispose(),
        ),
        Provider<AppInitializationBloc>(
          create: (context) => AppInitializationBloc(),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<ContentBloc>(
          create: (context) => ContentBloc(),
          dispose: (_, value) => value.dispose(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: LoginAppStrings.APP_NAME,
        theme: ThemeData(
          //Swipe back navigation activated for both android and ios
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
          primaryColor: Colors.deepPurple,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => Provider<ShoppingBloc>(
            create: (context)=>_shoppingBloc,
            child: HomeScreen(),
            dispose: (_,bloc)=>bloc.dispose(),
          ),
          '/cart':(context)=>Provider<ShoppingBloc>(
            create: (context)=>_shoppingBloc,
            child: CartScreen(),
          ),
        },
      ),
    );
  }
}

