import 'dart:convert';

import 'package:test/test.dart';

import 'package:dapir/dapir.dart';
import 'placeholderObjects.dart';

void main() {
  String base_url = 'https://jsonplaceholder.typicode.com';
  Map<String, String> header = {
      'Content-Type': 'json/application',
  };

  group('URL Construction', () {
    test('Simple route', () {
      var example = Dapir(base_url, headers: header);

      DapirRequest example_request = example.request();
      expect(example_request.url, equals(base_url));
    });

    test('Nested route', () {
      var base = Dapir(base_url, headers: header);
      var posts = Dapir('/posts', parent: base);
      var post_id = Dapir('/1', parent: posts);
      DapirRequest request = post_id.request();
      expect(request.url, equals('${base_url}/posts/1'));

      var compoundPath = Dapir('/posts/2', parent: base);
      request = compoundPath.request();
      expect(request.url, equals('${base_url}/posts/2'));
    });

    test('Single path substitution', () {
      var users = Dapir('${base_url}/users', headers: header);
      var user_id = Dapir("/~id", parent: users);
      DapirRequest user_request = user_id.request(substitutions: {"~id": 10});

      expect(user_request.url, equals("${base_url}/users/10"));
    });

    test('Multiple path substitutions', () {
      // Method 1
      var base = Dapir(base_url, headers: header);
      var users = Dapir('/users', parent: base);
      var user_id = Dapir('/~id', parent: users);
      var user_attr = Dapir('/~attr', parent: user_id);

      DapirRequest request = user_attr.request(substitutions: {'~id': 1, '~attr': 'posts'});
      expect(request.url, equals('${base_url}/users/1/posts'));

      // Method 2
      base = Dapir(base_url, headers: header);
      users = base.child('/users');
      user_id = users.child('/~id');
      user_attr = user_id.child('/~attr');

      request = user_attr.request(substitutions: {'~id': 2, '~attr': 'posts'});
      expect(request.url, equals('${base_url}/users/2/posts'));

      // Method 3
      // TODO: Split up compound paths to produce multiple children internally, and return the last child.
      var full_path = Dapir('/users/~id/~attr', parent: base);
      request = full_path.request(substitutions: {'~id': 3, '~attr': 'todos'});
      expect(request.url, equals('${base_url}/users/3/todos'));

      // Method 4
      var root = Dapir(base_url, headers: header, children: [
        Dapir('/users', children: [
          Dapir('/~id', children: [
            Dapir('/~attr')
          ]),
        ]),
      ]);

      var endpoint = root / 'users' / '~id' / '~attr';
      // alternatively:
      //var endpoint = root['/users']['/~id']['/~attr'];
      request = endpoint.request(substitutions: {'~id': 4, '~attr': 'posts'});
      expect(request.url, equals('${base_url}/users/4/posts'));
      expect(endpoint.headers, equals(header));
      expect(endpoint.parent, equals(root/'users'/'~id'));

      // Method 5
      var last_child = Dapir(base_url, headers: header)
        .child('/users')
        .child('/~id')
        .child('/~attr');

      request = last_child.request(substitutions: {'~id': 5, '~attr': 'posts'});
      expect(request.url, equals('${base_url}/users/5/posts'));
      expect(last_child.headers, equals(header));
    });


    test('Query parameters', () {
      var posts = Dapir('${base_url}/posts', headers: header);
      Map<String, dynamic> params = {
        'userId': 1
      };

      DapirRequest posts_request = posts.request(params: params);
      expect(posts_request.url, equals('${base_url}/posts?userId=1'));
    });
  });

  group('Making Requests', () {
    test('Simple request', () async {
      var user = Dapir('${base_url}/users/10');
      var request = user.request();
      var response = await request.makeRequest();
      expect(response, isNotEmpty);
      expect(() => jsonDecode(response), returnsNormally);
    });

    test('With handler', () async {
      var request = Dapir('${base_url}/users/10').request();
      User user = await request.makeRequest((response) => User.fromJson(response));
      expect(user.id, equals(10));
      expect(user.name, isNotEmpty);
      expect(user.username, isNotEmpty);
      expect(user.email, isNotEmpty);
    });

    test('With query', () async {
      var posts = Dapir('${base_url}/posts');
      var filtered_posts = posts.request(params: {'userId': 1});
      List<Post> post_objects = await filtered_posts.makeRequest((response) => Post.fromJsonArray(response));
      expect(post_objects, isNotEmpty);
      expect(post_objects.every((post) => post.user_id == 1), isTrue);
    });
  });
}