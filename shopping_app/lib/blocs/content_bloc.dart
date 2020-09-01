import 'package:shopping_app/helper/enums.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'base_bloc.dart';

class ContentBloc extends BaseBloc {

  //Control the bottom navigation index changes and fire ui changes
  BehaviorSubject<int> _navigationEventIndex = BehaviorSubject<int>();
  Stream<int> get navigationEvent => _navigationEventIndex.stream;
  StreamController<int> _navigationIndexController = StreamController();
  Sink<int> get setNavigationEvent => _navigationIndexController.sink;

  //Controls the body content changes according to bottom navigation change
  BehaviorSubject<HomeTabs> _pageChanges = BehaviorSubject<HomeTabs>();
  Stream<HomeTabs> get pageChanged => _pageChanges.stream;

  ContentBloc(){

    //Set the navigation streams and body content streams based on input index
    _navigationIndexController.stream.listen((index){
      _navigationEventIndex.add(index);
      _pageChanges.add(HomeTabs.values[index]);
    });

  }

  @override
  dispose() {

    _navigationEventIndex.close();
    _navigationIndexController.close();
    _pageChanges.close();
  }

}