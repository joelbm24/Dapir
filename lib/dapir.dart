library dapir;

import 'dart:async';

import 'package:http/http.dart' as http;

part 'dapirRequest.dart';
part 'extensions.dart';

// TODO: Make this immutable.
class Dapir {
  String pathName;
  RequestMethod verb;
  Map<String, String> _headers;
  Dapir parent;
  final Map<String, Dapir> _children = {};

  Dapir(this.pathName, {this.verb = RequestMethod.GET, Map<String,String> headers = const {}, this.parent, Iterable<Dapir> children = const []}) {
    _headers = headers;
    children.forEach(_adopt);
  }

  void _adopt(Dapir child) {
    child.parent = this;
    // TODO: Storing children by their path this way will break when 2 children use the same path but different verbs/headers.
    //       Perhaps store it as '/my-path:VERB' to distinguish them.
    _children[child.pathName] = child;
  }

  /// Creates a new Dapir object with the current object as the parent.
  Dapir child(String pathName, {RequestMethod verb = RequestMethod.GET, Map<String,String> headers = const {}}) {
    var child = Dapir(pathName, verb: verb, headers: headers);
    _adopt(child);
    return child;
  }

  set headers(Map<String, String> newHeaders) => _headers = newHeaders;

  bool get hasParent => parent != null;
  bool get hasChildren => _children.isNotEmpty;
  Iterable<Dapir> get children => _children.values;

  Map<String, String> get headers =>
    hasParent ? parent.headers.merge(_headers) : _headers;

  String get headerString {
    var output = '';
    _headers.forEach((k,v) => output += '$k: $v\n');
    return output;
  }

  /// Access child Dapir nodes by their `pathName`.
  Dapir operator [](String path) => _children[path];

  String route({Map<String, dynamic> substitutions = const {}}) {
    var current = this;
    var route = '';

    while (current != null) {
      route = current.pathName + route;
      current = current.parent;
    }

    substitutions.forEach((placeholder, value) {
      route = route.replaceAll(placeholder, value.toString());
    });

    return route;
  }

  DapirRequest request({Map<String, dynamic> substitutions = const {}, Map<String, dynamic> params = const {}, body = ''}) =>
    DapirRequest(verb:   verb,
                 header: _headers,
                 url:    route(substitutions: substitutions) + _formatParams(params),
                 body:   body);


  static String _formatParams([Map<String, dynamic> params = const {}]) {
    if (params.isEmpty) {
      return '';
    }

    List<String> formated_params = [];
    params.forEach((k,v) {
      if (v is List) {
        v = v.join(',');
      }
      formated_params.add('$k=$v');
    });

    return "?${formated_params.join('&')}";
  }
}