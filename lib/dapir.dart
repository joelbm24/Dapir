part of dapir;

class Dapir {
  String pathName;
  String verb;
  Map<String, String> headers;
  Dapir parent;

  Dapir(String pathName, {
    String verb = "GET",
    Map<String, String> headers = null,
    Dapir parent = null,
    Map<String, String> params = null}) {
    this.pathName = pathName;
    this.parent = parent;
    this.verb = verb;
    this.headers = headers;

    if (headers == null) {
      this.headers = parent.headers;
    }
  }

  String route({List<String> extras}) {
    Dapir current = this.parent;
    String route = this.pathName;
    while (current != null) {
      if (current.pathName.contains("~") && extras.length > 0) {
        route = "/" + extras[0] + route;
        extras.removeAt(0);
      } else {
        route = current.pathName + route;
      }
      current = current.parent;
    }

    return route;
  }

  String header() {
    String output = "";

    this.headers.forEach((k,v) {
      output += k + ": " + v + "\n";
    });

    return output;
  }

  String param(Map<String, String> params) {

    if (params.isEmpty) {
      return "";
    }

    List<String> formated_params = [];
    params.entries.forEach((l) {
      formated_params.add("${l.key}=${l.value}");
    });

    return "?${formated_params.join("&")}";
  }

  Map<String, dynamic> request({List<String> extras, Map<String, String> params}) {
    Map<String, dynamic> request = {
      "verb": this.verb,
      "header": this.headers,
      "url": this.route(extras: extras) + this.param(params)
    };

    return request;
  }
}