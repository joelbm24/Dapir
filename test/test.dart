import 'dart:convert';
import 'package:test/test.dart';
import '../lib/dapir.dart';
import 'placeholderObjects.dart';

void main() {
  String base_url = "https://jsonplaceholder.typicode.com";
  Map<String, String> header = {
      "Content-Type": "json/application",
  };

  group('URL Construction', () {
    test('Simple route', () {
      var example = new Dapir(base_url, headers: header);

      DapirRequest example_request = example.request();
      expect(example_request.url, equals(base_url));
    });

    test('Nested route', () {
      var base = new Dapir(base_url, headers: header);
      var posts = new Dapir("/posts", parent: base);
      var post_id = new Dapir("/1", parent: posts);
      DapirRequest request = post_id.request();
      expect(request.url, equals("${base_url}/posts/1"));

      var compoundPath = new Dapir("/posts/2", parent: base);
      request = compoundPath.request();
      expect(request.url, equals("${base_url}/posts/2"));
    });


    test('Single path substitution', () {
      var users = new Dapir("${base_url}/users", headers: header);
      var user_id = new Dapir("/~id", parent: users);
      DapirRequest user_request = user_id.request(substitutions: {"~id": 10});

      expect(user_request.url, equals("${base_url}/users/10"));
    });

    test('Multiple path substitutions', () {
      var base = new Dapir(base_url, headers: header);
      var users = new Dapir('/users', parent: base);
      var user_id = new Dapir("/~id", parent: users);
      var user_attr = new Dapir("/~attr", parent: user_id);
      DapirRequest request = user_attr.request(substitutions: {"~id": 2, "~attr": "posts"});
      expect(request.url, equals("${base_url}/users/2/posts"));

      var full_path = new Dapir('/users/~id/~attr', parent: base);
      request = full_path.request(substitutions: {"~id": 3, "~attr": "todos"});
      expect(request.url, equals("${base_url}/users/3/todos"));
    });


    test('Query parameters', () {
      var posts = new Dapir("${base_url}/posts", headers: header);
      Map<String, dynamic> params = {
        "userId": 1
      };

      DapirRequest posts_request = posts.request(params: params);
      expect(posts_request.url, equals("${base_url}/posts?userId=1"));
    });
  });

  group('Making Requests', () {
    test('Simple request', () async {
      var user = new Dapir("${base_url}/users/10");
      var request = user.request();
      var response = await request.makeRequest();
      expect(response, isNotEmpty);
      expect(() => jsonDecode(response), returnsNormally);
    });

    test('With handler', () async {
      var request = new Dapir("${base_url}/users/10").request();
      User user = await request.makeRequest((response) => new User.fromJson(response));
      expect(user.id, equals(10));
      expect(user.name, isNotEmpty);
      expect(user.username, isNotEmpty);
      expect(user.email, isNotEmpty);
    });

    test('With query', () async {
      var posts = new Dapir("${base_url}/posts");
      var filtered_posts = posts.request(params: {"userId": 1});
      List<Post> post_objects = await filtered_posts.makeRequest((response) => Post.fromJsonArray(response));
      expect(post_objects, isNotEmpty);
      expect(post_objects.every((post) => post.user_id == 1), isTrue);
    });
  });
}