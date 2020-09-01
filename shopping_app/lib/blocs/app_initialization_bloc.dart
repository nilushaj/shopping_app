//This bloc takes care of all the app wise initialization, login and its logic//
import 'package:shopping_app/helper/enums.dart';
import 'package:shopping_app/helper/network.dart';
import 'package:shopping_app/helper/secure_storage.dart';
import 'package:shopping_app/helper/shared_preference_helper.dart';
import 'package:shopping_app/helper/validation.dart';
import 'package:shopping_app/models/network_models/authenticate_user.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

import 'base_bloc.dart';
import 'error_bloc.dart';


class AppInitializationBloc extends BaseBloc {

  final _networkCalls = Network.shared; //singleton network instance
  final _errorHandler = ErrorBloc.getInstance;

  String _email;
  String _password;

  PublishSubject<ScreenStates> _navigationController = PublishSubject<ScreenStates>();
  Stream<ScreenStates> get getNavigation => _navigationController.stream;

  //Get the user email controller sink and streams
  BehaviorSubject<String> _userEmail = BehaviorSubject<String>();
  Stream<String> get getUserEmail => _userEmail.stream;
  StreamController<String> _userEmailController = StreamController();
  Sink<String> get setUserEmail => _userEmailController.sink;

  //Get the user password controller sink and streams
  BehaviorSubject<String> _userPassword = BehaviorSubject<String>();
  Stream<String> get getUserPassword => _userPassword.stream;
  StreamController<String> _userPasswordController = StreamController();
  Sink<String> get setUserPassword => _userPasswordController.sink;


  //Sign up button press activation listener
  Stream<bool> get getButtonVisibility => Rx.combineLatest2(getUserEmail, getUserPassword,(email, password) =>true);

  //control the modal loader visibility and function
  PublishSubject<bool> _isLoading = PublishSubject<bool>();
  Stream<bool> get isLoading => _isLoading.stream;

  //stream, sink and controllers for error handling
  PublishSubject<String> _errorMessage = PublishSubject<String>();
  Stream<String> get getError => _errorMessage.stream;

  AppInitializationBloc(){

    //Get the app startup data
    doAppStartupProcedure();

    _userEmailController.stream.listen((email){
      if (email == null || email == "") {
        _userEmail.addError("This field is required.");
      } else {
        if (Validation.isValidEmail(email)) {
          _userEmail.add(email);
          _email = email;
        } else {
          _userEmail.addError("Invalid Email!");
        }
      }
    });

    _userPasswordController.stream.listen((password){
      if (password == null || password == "") {
        _userPassword.addError("This field is required.");
      }
      else{
        _password = password;
        _userPassword.add(password);
      }
    });

  }



  // Login the user with the username and password
  void loginUser() async {
    _isLoading.add(true);
    bool flag = await _authenticateUser();

    if(flag){
      _navigationController.add(ScreenStates.HOME);
    }
    else{
      _isLoading.add(false);
    }
  }

  //Do the startup procedure based on the app status. If startup details
  //available authenticate and get startup information. Else redirect to login
  //screen and do the needful
  doAppStartupProcedure() async {

    // clear shared preferences and secure storage
    // FOR DEV ONLY!!
//    await SharedPreferenceHelper.clearPref();
//    await SecureStorage.deleteAllValues();

    String tokenExpiryDate = await SharedPreferenceHelper.getFromPref<String>("tokenExpiryDate");

    if(tokenExpiryDate != null){

      // Get the token expiry date difference from existing date and find minutes remaining
      int minuteDifference = DateTime.parse(tokenExpiryDate).difference(DateTime.now()).inMinutes;

      print("Minutes Remaining: $minuteDifference");

      // If token is valid for at least 1 hour, get startup information
      if(minuteDifference > 60){
        _navigationController.add(ScreenStates.HOME);
      }
      // Else do a token refresh
      else{
        String refreshToken = await SecureStorage.readValue("refreshToken");
        bool flag = await _authenticateUser(type: AuthenticationTypes.REFRESH, refreshToken: refreshToken);
        if(flag){
          _navigationController.add(ScreenStates.HOME);
        }
      }

    }

    else{
      //route to login page
      _navigationController.add(ScreenStates.LOGIN);
    }

  }


  // Get jwt token from identity server and other utilities. Default is a brand
  // new authentication. Can be used to refresh the existing token
  Future<bool> _authenticateUser({
    AuthenticationTypes type = AuthenticationTypes.LOGIN,
    String refreshToken = ""
  }) async {

    try{
      AuthenticateUser model;

      if(type == AuthenticationTypes.LOGIN){
        model = await _networkCalls.authenticateUser(AuthenticateUser(_email, _password).getRequestBody());
      }
      else{
        print("REFRESH");
        model = await _networkCalls.authenticateUser(AuthenticateUser.refresh().refreshToken(refreshToken));
      }

      // Save jwt token and refresh token to secured storage
      SecureStorage.writeValue("jwtToken", model.getJwtToken);
      SecureStorage.writeValue("refreshToken", model.getRefreshToken);

      //Save user email refresh token and expiration time to persistent storage
      SharedPreferenceHelper.saveToPref<String>("tokenExpiryDate", DateTime.now().add(Duration(seconds: model.getExpiresIn)).toString());

      return true;
    }
    catch (error) {
      print(error.message.toString());
      if(error.message.toString() == "{error: invalid_grant, error_description: invalid_username_or_password}"){
        _errorMessage.add("Incorrect email or password");
        _errorHandler.addError("Incorrect email or password");
      }
      else{
        _errorMessage.add(error.message.toString());
        _errorHandler.addError(error.message.toString());
      }
      return false;
    }

  }



  @override
  dispose() {
    _navigationController.close();
    _userEmail.close();
    _userEmailController.close();
    _userPassword.close();
    _userPasswordController.close();
    _isLoading.close();
    _errorMessage.close();
  }

}