import 'package:test/test.dart';
import '../lib/dapir.dart';

void main() {
  String base_url = "https://jsonplaceholder.typicode.com/";
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

      var compoundPath = new Dapir('/posts/2', parent: base);
      request = compoundPath.request();
      expect(request.url, equals("${base_url}/posts/2"));
    });


    test('Single path substitution', () {
      var users = new Dapir("${base_url}/users", headers: header);
      var user_id = new Dapir("~id", parent: users);
      DapirRequest user_request = user_id.request(extras: [10]);

      expect(user_request.url, equals("${base_url}/users/10"));
    });

    test('Multiple path substitutions', () {
      var base = new Dapir(base_url, headers: header);
      var users = new Dapir('/users', parent: base);
      var user_id = new Dapir("~id", parent: users);
      var user_attr = new Dapir("~attr", parent: user_id);
      DapirRequest request = user_attr.request(extras: [1, "posts"]);
      expect(request.url, equals("${base_url}/users/1/posts"));

      // TODO: this doesn't work!
      //var fullPath = new Dapir('/users/~id/~attr', parent: base);
      //request = fullPath.request(extras: [2, "todos"]);
      //expect(request.url, equals("${base_url}/users/2/todos"));
    });


    test('Query parameters', () {
      Dapir posts = new Dapir("${base_url}/posts", headers: header);
      Map<String, dynamic> params = {
        "userId": 1
      };

      DapirRequest posts_request = posts.request(params: params);
      // TODO:
      // DapirResponse posts_response = posts_request.makeRequest();
      // posts_response.getTitle();

      expect(posts_request.url, equals("${base_url}/posts?userId=1"));
    });
  });
}