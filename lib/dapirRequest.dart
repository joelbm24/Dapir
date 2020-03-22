part of dapir;

enum RequestMethod {
  GET,    // Read
  POST,   // Create
  PUT,    // Replace
  PATCH,  // Modify
  DELETE  // Delete
}

class DapirRequest {
  RequestMethod verb;
  Map<String, String> header;
  String url;
  dynamic body;

  DapirRequest({this.verb, this.header, this.url, this.body}) {}

  Future<String> makeRequest() async {
    switch (this.verb) {
      case RequestMethod.GET:  return getRequest();
      case RequestMethod.POST: return postRequest();
      default:                 return Future.value("Not Implemented");
    }
  }

  Future<String> getRequest() async {
    var response = await http.get(this.url, headers: this.header);
    return response.body;
  }

  Future<String> postRequest() async {
    var response = await http.post(this.url, headers: this.header, body: this.body);
    return response.body;
  }
}
