import 'package:flutter/material.dart';
import 'package:shopping_app/blocs/app_initialization_bloc.dart';
import 'package:shopping_app/blocs/error_bloc.dart';
import 'package:shopping_app/helper/enums.dart';
import 'package:shopping_app/helper/utils.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  StreamSubscription _pageChangeSubscription;
  StreamSubscription _errorSubscription;
  Stream _prevStreamPageChange;
  Stream _prevStreamError;

  AppInitializationBloc _appInitializationBloc;
  BuildContext _scaffoldContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _appInitializationBloc = Provider.of<AppInitializationBloc>(context);
    final _errorBloc = Provider.of<ErrorBloc>(context);

    if (_prevStreamPageChange != _appInitializationBloc.getNavigation) {
      _prevStreamPageChange = _appInitializationBloc.getNavigation;
      _pageChangeSubscription?.cancel();
      listenPageState(_appInitializationBloc.getNavigation);
    }

    if (_prevStreamError != _errorBloc.getError) {
      _prevStreamError = _errorBloc.getError;
      _errorSubscription?.cancel();
      listenError(_errorBloc.getError);
    }
  }

  //Change page depending on the stream output
  void listenPageState(Stream<ScreenStates> stream) {
    _pageChangeSubscription = stream.listen((state) async {
      await Future.delayed(Duration(seconds: 1));
      switch (state) {
        case ScreenStates.HOME:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case ScreenStates.LOGIN:
          Navigator.pushReplacementNamed(context, '/login');
          break;
      }
    });
  }

  //Change page depending on the stream output
  void listenError(Stream<String> stream) {
    _errorSubscription = stream.listen((error) async {
      final SnackBar snackBar = SnackBar(
        content: Text(
          error,
          style: Theme.of(context).primaryTextTheme.button,
          textAlign: TextAlign.left,
        ),
        action: SnackBarAction(
          label: "RETRY",
          onPressed: () => _appInitializationBloc.doAppStartupProcedure(),
          textColor: Colors.white,
        ),
        duration: const Duration(minutes: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      );

      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
    });
  }

  @override
  void dispose() {
    _pageChangeSubscription.cancel();
    _errorSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Set the screen sizes and the static util variables
    Utils.setScreenSizes(context);

    final _height = Utils.totalBodyHeight - Utils.statusBarHeight;
    final _width = Utils.bodyWidth;

    return Scaffold(
      body: Builder(
        builder: (context) {
          _scaffoldContext = context;

          return SafeArea(
            child: Center(
                child: Text(
                  "Let\'s Buy",
                  style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold,color: Colors.deepPurple),
                )),
          );
        },
      ),
    );
  }
}
