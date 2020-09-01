class AuthenticateUser {

String _jwtToken;
int _expiresIn;
String _refreshToken;

String _email;
String _password;

AuthenticateUser.fromJson(Map<String, dynamic> parsedJson){
_jwtToken = parsedJson['access_token'];
_expiresIn = parsedJson['expires_in'];
_refreshToken = parsedJson['refresh_token'];
}

AuthenticateUser(this._email, this._password);

AuthenticateUser.refresh();

Map<String, String> getRequestBody(){
return {
"grant_type": "password",
"password": _password,
"username": _email,
"client_id": "brokerapp_dev",
"client_secret": "2e7707f7-9385-7930-c216-d101d24ea2b2",
"scope": "EffieBrokerService offline_access",
};
}

Map<String, String> refreshToken(String refreshToken){
return {
"grant_type": "refresh_token",
"client_id": "brokerapp_dev",
"client_secret": "2e7707f7-9385-7930-c216-d101d24ea2b2",
"refresh_token": refreshToken,
};
}

String get getJwtToken => _jwtToken;
String get getRefreshToken => _refreshToken;
int get getExpiresIn => _expiresIn;


}