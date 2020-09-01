class ConfigData {
  //Base url and version are private and not exposed
  static const _IDENTITY_SERVER_URL =
      "https://identity.effi.com.au/connect/token";
  static const _VERSION = "api-version=1";

  static String _baseUrl = "https://jsonplaceholder.typicode.com";
  static String _rapidUrl = "https://ali-express1.p.rapidapi.com";

  //This url is dynamic and sent from the Startup endpoint
  static String _cloudStorageUrl;

  //authenticate user with email and password
  static String authenticateUser = _IDENTITY_SERVER_URL;
  static String shoppingListURL = _rapidUrl + "/productsByCategory/152405";
}
