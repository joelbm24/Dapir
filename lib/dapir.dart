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

  String header() {
    String output = "";

    this.headers.forEach((k,v) {
      output += k + ": " + v + "\n";
    });

    return output;
  }

  String route({Map<String, dynamic> substitutions}) {
    Dapir current = this;
    String route = '';

    while (current != null) {
      route = current.pathName + route;
      current = current.parent;
    }

    substitutions.forEach((placeholder, value) {
      route = route.replaceAll(placeholder, value.toString());
    });

    return route;
  }

  String param(Map<String, dynamic> params) {
    if (params.isEmpty) {
      return "";
    }

    List<String> formated_params = [];
    params.forEach((k,v) {
      if (v is List) {
        v = v.join(",");
      }
      formated_params.add("$k=$v");
    });

    return "?${formated_params.join('&')}";
  }

  DapirRequest request({Map<String, dynamic> substitutions = const {}, Map<String, dynamic> params = const {}, body = ""}) {
    return DapirRequest(
            verb:   this.verb,
            header: this.headers,
            url:    this.route(substitutions: substitutions) + this.param(params),
            body:   body );
  }
}