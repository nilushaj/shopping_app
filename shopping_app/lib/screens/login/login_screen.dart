import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shopping_app/blocs/app_initialization_bloc.dart';
import 'package:shopping_app/helper/enums.dart';
import 'package:shopping_app/helper/utils.dart';
import 'package:shopping_app/screens/login/logo_clipper.dart';
import 'package:shopping_app/widgets/loading_widget.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _height = Utils.totalBodyHeight;
  final _width = Utils.bodyWidth;

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

    if (_prevStreamPageChange != _appInitializationBloc.getNavigation) {
      _prevStreamPageChange = _appInitializationBloc.getNavigation;
      _pageChangeSubscription?.cancel();
      listenPageState(_appInitializationBloc.getNavigation);
    }

    if (_prevStreamError != _appInitializationBloc.getError) {
      _prevStreamError = _appInitializationBloc.getError;
      _errorSubscription?.cancel();
      listenError(_appInitializationBloc.getError);
    }
  }

  //Change page depending on the stream output
  void listenPageState(Stream<ScreenStates> stream) {
    _pageChangeSubscription = stream.listen((state) {
      switch (state) {
        case ScreenStates.HOME:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case ScreenStates.LOGIN:
          break;
      }
    });
  }

  //Error message listener
  void listenError(Stream stream) {
    _errorSubscription = stream.listen((value) {
      //listen to stream, display snack bar error
      _showSnackBar(value);
    });
  }

  void _showSnackBar(String value) {
    final SnackBar snackBar = SnackBar(
      content: Text(
        value,
        style: Theme.of(context).primaryTextTheme.button,
        textAlign: TextAlign.left,
      ),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1A2D4E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
    );
    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _pageChangeSubscription.cancel();
    _errorSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Builder(builder: (BuildContext context) {
      _scaffoldContext = context;
      return Stack(
        children: <Widget>[
          SingleChildScrollView(
            reverse: true,
            child: Container(
              height: _height,
              child: Stack(
                children: <Widget>[
                  ClipPath(
                    clipper: LogoClipper(),
                    child: Container(
                      color: Colors.deepPurple,
                      height: 0.7 * _height,
                      width: _width,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: _height*0.06,
                            left: _width*0.06,
                            child: Text("Sign in \nto Buy.",style: TextStyle(fontSize: 35,color: Colors.white),),
                          ),
                          Positioned(
                            top: _height*0.15,
                            right: _width*0.1,
                            child: Transform.rotate(
                              angle: 120,
                              child: Container(
                                  height: _height*0.4,
                                  width: _width*0.5,
                                  child: Image.asset('assets/images/game_controller.png')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  Positioned(
                    bottom: _height * 0.1,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(_width * 0.08,
                              _height * 0.02, _width * 0.08, _height * 0.02),
                          padding: EdgeInsets.all(10),
                          child: _textField(
                            keyboardType: TextInputType.emailAddress,
                            hint: "Email",
                            sink: _appInitializationBloc.setUserEmail,
                            stream: _appInitializationBloc.getUserEmail,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(_width * 0.08,
                              _height * 0.02, _width * 0.08, _height * 0.02),
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: _textField(
                            keyboardType: TextInputType.visiblePassword,
                            hint: "Password",
                            obscuredText: true,
                            sink: _appInitializationBloc.setUserPassword,
                            stream: _appInitializationBloc.getUserPassword,
                          ),
                        ),
                        Container(
                            width: _width * 0.8,
                            height: 70,
                            margin: EdgeInsets.only(top: _height * 0.03),
                            child: StreamBuilder(
                                stream:
                                    _appInitializationBloc.getButtonVisibility,
                                builder: (context, snapshot) {
                                  return RaisedButton(
                                    color: Colors.deepPurple,
                                    shape: StadiumBorder(),
                                    elevation: 2,
                                    child: Text(
                                      'Let\'s Buy',
                                      style: TextStyle(
                                          fontSize: 25,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    onPressed: snapshot.hasData
                                        ? () {
                                            _appInitializationBloc.loginUser();
                                          }
                                        : null,
                                  );
                                })),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder(
            stream: _appInitializationBloc.isLoading,
            initialData: false,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data) {
                return LoadingWidget();
              } else {
                return Container();
              }
            },
          ),
        ],
      );
    }));
  }

  Widget _textField({
    TextInputType keyboardType,
    bool obscuredText = false,
    String hint,
    Stream stream,
    Sink sink,
  }) {
    return Container(
        width: _width * 0.8,
        child: StreamBuilder<Object>(
            stream: stream,
            builder: (context, snapshot) {
              return TextField(
                keyboardType: keyboardType,
                obscureText: obscuredText,
                style: TextStyle(fontSize: 20, color: Colors.black),
                onChanged: sink.add,
                decoration: InputDecoration(
                  errorText: snapshot.error,
                  border: OutlineInputBorder(),
                  labelText: hint,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                      width: 1,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              );
            }));
  }
}
