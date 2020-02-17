part of dapir;

class DapirRequest {
  String verb;
  Map<String, String> header;
  String url;
  dynamic body;

  DapirRequest({String verb, Map<String, String> header, String url, dynamic body}) {
    this.verb = verb;
    this.header = header;
    this.url = url;
    this.body = body;
  }

Future<String> makeRequest() async {
  String request_verb = this.verb;

  Map<String, dynamic> make_request_by_verb = {
    "GET": getRequest,
    "POST": postRequest
  };

  return make_request_by_verb[request_verb]();
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
