/*
Copyright 2020 Joel Alexander Buchheim-Moore

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

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
  final Map<String, Map<RequestMethod, Dapir>> _children = {};

  Dapir(this.pathName, {this.verb = RequestMethod.GET, Map<String,String> headers = const {}, this.parent, Iterable<Dapir> children = const []}) {
    _headers = headers;
    children.forEach(_adopt);
  }

  Dapir _adopt(Dapir child) {
    child.parent = this;
    _children.putIfAbsent(child.pathName, () => {});
    _children[child.pathName][child.verb] = child;
    return child;
  }

  /// Creates a new Dapir object with the current object as the parent.
  Dapir newChild(String pathName, {RequestMethod verb = RequestMethod.GET, Map<String,String> headers = const {}}) {
    var child = Dapir(pathName, verb: verb, headers: headers);
    return _adopt(child);
  }

  set headers(Map<String, String> newHeaders) => _headers = newHeaders;

  bool get hasParent => parent != null;
  bool get hasChildren => _children.isNotEmpty;
  Iterable<Dapir> get children => _children.values.expand((map) => map.values);

  Map<String, String> get headers =>
    hasParent ? parent.headers.merge(_headers) : _headers;

  String get headerString {
    var output = '';
    _headers.forEach((k,v) => output += '$k: $v\n');
    return output;
  }

  bool isChildOf(Dapir other) {
    var current = this;
    while (current.hasParent) {
      if (current.parent == other) {
        return true;
      }
      else {
        current = current.parent;
      }
    }
    return false;
  }

  bool isParentOf(Dapir other) => other.isChildOf(this);

  Dapir getChild(String pathName, [RequestMethod verb = RequestMethod.GET]) =>
    _children[pathName][verb];

  /// Shorthand for [newChild].
  /// Create new child with the given [pathName] as a `GET` endpoint, and the same headers as the parent.
  Dapir operator +(String pathName) => newChild(pathName);

  /// Turns the right Dapir object into a child of the left Dapir object, and returns the new child.
  Dapir operator >>(Dapir child) => _adopt(child);

  /// Simplified shorthand for [getChild].
  /// Access Dapir child node only by its [pathName].
  Dapir operator [](String pathName) => getChild(pathName);

  /// Simplified shorthand for [getChild].
  /// Access Dapir child node only by its [pathName], without the leading '/'.
  Dapir operator /(String pathName) => getChild('/$pathName');

  /// Shorthand for [isParentOf].
  bool operator >(Dapir other) => isParentOf(other);

  /// Shorthand for [isChildOf].
  bool operator <(Dapir other) => isChildOf(other);

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
                 header: headers,
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