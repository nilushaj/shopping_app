import 'package:shopping_app/helper/connectivity.dart';
import 'package:http/http.dart';
import 'package:shopping_app/helper/strings.dart';
import 'package:shopping_app/models/network_models/authenticate_user.dart';
import 'package:shopping_app/models/initialize_models.dart';
import 'package:shopping_app/models/network_models/shopping_list.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as pathProvider;
import 'package:async/async.dart';
import 'package:http_parser/http_parser.dart';
import 'config.dart';
import 'secure_storage.dart';

enum RequestType {get, post,put,patch,delete, postEncodedUrl}

class Network {

  //Singleton
  Network._privateConstructor();
  static final Network _instance = Network._privateConstructor();
  static Network get shared => _instance;

  //check connection status
  var connectionStatus;
  var _connect = ConnectionCheck.getInstance();

  //http client
  Client client = Client();

  Map<String, String> _headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'X-RapidAPI-Key':'7fc95ec69amshffde91ab318f91fp1d9f2ejsn4532dacf28a2'
  };

  Future<T> _performWebRequest<T>(RequestType type, String url, {dynamic body}) async {
    //Response initialization
    Response response;

    //Get the jwtToken from secure storage and if existing, add to the header
    String authToken = await SecureStorage.readValue("token");

    if(authToken != null){
      _headers.addAll({'x-auth-token': '$authToken'});
    }

    // Print bearer token on need
//    print(bearerToken);

    //checks for the connection status and updates boolean
    await _connect.checkConnection().then((status) => connectionStatus=status);

    //runs only if connection exists
    if(connectionStatus){
      try{
        //Identify the request type
        switch(type){
          case RequestType.get:
            response = await client.get(url, headers: _headers);
            break;
          case RequestType.post:
            response = await client.post(url,headers: _headers, body: body != null ? json.encoder.convert(body) : "");
            break;
          case RequestType.postEncodedUrl:
            response = await client.post(url,headers: {'Content-Type':"application/x-www-form-urlencoded"}, body: body);
            break;
          case RequestType.put:
            response = await client.put(url, headers: _headers, body: json.encoder.convert(body));
            break;
          case RequestType.patch:
            response = await client.patch(url, headers: _headers, body: body != null ? json.encoder.convert(body) : "");
            break;
          case RequestType.delete:
            response = await client.delete(url, headers: _headers);
            break;
        }
        print("Network call ${response.statusCode} $url");

        if (response.statusCode == 200) {
          // If the call to the server was successful, parse the JSON and initialize the data model.
          if(response.body == null || response.body == ""){
            return InitializeData.fromJson<T>(true);
          }
          else{
            return InitializeData.fromJson<T>(json.decode(response.body));
          }
        }
        else if(response.statusCode == 202){  //server call was successful, no response body
          return InitializeData.fromJson<T>(json.decode(response.body));
        }
        else if(response.statusCode == 204){  //server call was successful, no response body
          return InitializeData.fromJson<T>(true);
        }
        else if(response.statusCode == 400){
          throw Exception(json.decode(response.body));
        }
        else if(response.statusCode == 401){
          throw Exception(json.decode(response.body)['title']);
        }
        else if(response.statusCode == 404){
          throw Exception(json.decode(response.body)['title']);
        }
        else if(response.statusCode == 422){
          throw Exception(json.decode(response.body)['title']);
        }
        else {
          print(response.body);
          throw Exception(LoginAppStrings.REQUEST_ERROR);   // If that call was not successful, throw an error.
        }
      }
      on TimeoutException{
        throw Exception(LoginAppStrings.SERVER_TIMEOUT);
      }
      on SocketException{
        throw Exception(LoginAppStrings.SERVER_TIMEOUT);
      }
    }
    else{
      throw Exception(LoginAppStrings.NO_INTERNET);
    }
  }

  //Handle a multipart file request
  Future<Map<String,dynamic>> _sendMultipartFile(File file, String path, String mediaType, {String extension}) async {

    //Set the broker picture uri from api endpoint
    var uri = Uri.parse(path);

    //Get file stream data and image file length
    var stream = ByteStream(DelegatingStream.typed(file.openRead()));
    var length = await file.length();

    //Get the file type by handling extension from path provider
    String fileType = pathProvider.extension(file.path).substring(1);
    print("FILE_TYPE: $fileType");

    //Set the content type and request type
    var contentType = new MediaType(mediaType, extension ?? fileType);
    var request = MultipartRequest("POST", uri);

    //Define multipart file with the declared fields and add the file to request
    var multipartFile = MultipartFile(
        'file',
        stream,
        length,
        filename: pathProvider.basename(file.path),
        contentType: contentType
    );

    request.files.add(multipartFile);

    //get the response from endpoint and do accordingly
    var response = await request.send();

    //Get the response data from the server
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    print("reponseCode ${response.statusCode} response $responseString");

    return {
      "reponseCode":response.statusCode,
      "response":responseString
    };

  }

  //authenticate user from email and password
  authenticateUser(Map<String, String> body) {
    return _performWebRequest<AuthenticateUser>(RequestType.postEncodedUrl, ConfigData.authenticateUser, body: body);
  }

  getShoppingItems(){
    return _performWebRequest<GetShoppingList>(RequestType.get, ConfigData.shoppingListURL);
  }

}