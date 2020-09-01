import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'base_bloc.dart';



class ErrorBloc extends BaseBloc {

  // Singleton instance as all screens use the same error stream
  ErrorBloc._privateConstructor();
  static final ErrorBloc _instance = ErrorBloc._privateConstructor();
  static ErrorBloc get getInstance => _instance;

  //stream, sink and controllers for error handling
  PublishSubject<String> _errorMessage = PublishSubject<String>();
  Stream<String> get getError => _errorMessage.stream;

  addError(String error){

    if(error.contains("Exception: ")){
      _errorMessage.add(error.split("Exception: ").last);
    }
    else{
      _errorMessage.add(error);
    }

  }

  @override
  dispose() {
    _errorMessage.close();
  }

}