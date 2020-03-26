import 'dart:convert';

class User {
  int id;
  String name;
  String username;
  String email;

  User.fromJson(String raw_json) {
    var object = jsonDecode(raw_json);
    id = object['id'];
    name = object['name'];
    username = object['username'];
    email = object['email'];
  }
}

class Post {
  int id;
  int user_id;
  String title;
  String body;

  Post(this.id, this.user_id, this.title, this.body);

  Post.fromJson(String raw_json) {
    var object = jsonDecode(raw_json);
    id = object['id'];
    user_id = object['userId'];
    title = object['title'];
    body = object['body'];
  }

  static List<Post> fromJsonArray(String raw_json) {
    List array = jsonDecode(raw_json);
    List<Post> posts = [];
    array.forEach((post) {
      posts.add(Post(post['id'], post['userId'], post['title'], post['body']));
    });
    return posts;
  }
}