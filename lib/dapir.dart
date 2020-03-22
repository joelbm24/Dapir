library dapir;

import 'dart:async';

import "package:http/http.dart" as http;

part 'dapirResponse.dart';
part 'dapirRequest.dart';

class Dapir {
  String pathName;
  RequestMethod verb;
  Map<String, String> headers;
  Dapir parent;

  Dapir(this.pathName, {this.verb = RequestMethod.GET, this.headers, this.parent}) {
    headers ??= parent?.headers;
  }

  String route({List<String> extras}) {
    Dapir current = this.parent;
    String route = this.pathName;
    if (route.contains("~") && extras.length > 0) {
      route = "/" + extras.last;
      extras.removeLast();
    }

    while (current != null) {
      if (current.pathName.contains("~") && extras.length > 0) {
        route = "/" + extras.last + route;
        extras.removeLast();
      }
      else {
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

  String param(Map<String, dynamic> params) {
    if (params.isEmpty) {
      return "";
    }

    List<String> formated_params = [];
    params.forEach((k,v) {
      if (v is List<String>) {
        v = v.join(",");
      }
      formated_params.add("$k=$v");
    });

    return "?${formated_params.join('&')}";
  }

  DapirRequest request({List<String> extras = const [], Map<String, dynamic> params = const {}, dynamic body = ""}) {
    return DapirRequest(
            verb:   this.verb,
            header: this.headers,
            url:    this.route(extras: extras) + this.param(params),
            body:   body );
  }
}