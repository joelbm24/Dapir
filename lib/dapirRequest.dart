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

  Future<String> requestWithClient(http.Client client) async {
    http.Response response;

    switch (this.verb) {
      case RequestMethod.GET:
        response = await client.get(this.url, headers: this.header);
        break;
      case RequestMethod.POST:
        response = await client.post(this.url, headers: this.header, body: this.body);
        break;
      case RequestMethod.PUT:
        response = await client.put(this.url, headers: this.header, body: this.body);
        break;
      case RequestMethod.PATCH:
        response = await client.patch(this.url, headers: this.header, body: this.body);
        break;
      case RequestMethod.DELETE:
        response = await client.delete(this.url, headers: this.header);
        break;
    }

    return response.body;
  }

  Future<String> makeRequest() async {
    var client = new http.Client();
    var response = await requestWithClient(client);
    client.close();
    return response;
  }
}