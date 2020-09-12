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

part of dapir;

enum RequestMethod {
  GET,    // Read
  POST,   // Create
  PUT,    // Replace
  PATCH,  // Modify
  DELETE  // Delete
}

typedef ResponseHandler<T> = T Function(String);

class DapirRequest {
  RequestMethod verb;
  Map<String, String> header;
  String url;
  dynamic body;

  DapirRequest({this.verb, this.header, this.url, this.body});

  Future<T> requestWithClient<T>(http.Client client, [ResponseHandler<T> handler]) async {
    http.Response response;

    switch (verb) {
      case RequestMethod.GET:
        response = await client.get(url, headers: header);
        break;
      case RequestMethod.POST:
        response = await client.post(url, headers: header, body: body);
        break;
      case RequestMethod.PUT:
        response = await client.put(url, headers: header, body: body);
        break;
      case RequestMethod.PATCH:
        response = await client.patch(url, headers: header, body: body);
        break;
      case RequestMethod.DELETE:
        response = await client.delete(url, headers: header);
        break;
    }

    handler ??= (body) => body as T;
    return handler(response.body);
  }

  Future<T> makeRequest<T>([ResponseHandler<T> handler]) async {
    var client = http.Client();
    var response = await requestWithClient(client, handler);
    client.close();
    return response;
  }
}