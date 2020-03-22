library dapir;

import 'dart:async';

import "package:http/http.dart" as http;

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
      route = "/" + extras[0];
      extras.removeAt(0);
    }

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
    // params.entries.forEach((l) {
    //   if (l.value is List<String>) {
    //     l.value = l.value;
    //   }
    //   formated_params.add("${l.key}=${l.value}");
    // });

    return "?${formated_params.join('&')}";
  }

  DapirRequest request({List<String> extras = const [], Map<String, dynamic> params = const {}, dynamic body}) { 
    return DapirRequest(
            verb: this.verb,
            header: this.headers,
            url: this.route(extras: extras) + this.param(params),
            body: body ?? "" );
  }
}
