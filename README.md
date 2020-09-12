# Dapir
Dapir is a library for writing REST clients in Dart. It allows you to easily build paths, manage parameters and handle url substitutions.
 
 ---

 ## Authors
* Joel Buchheim-Moore => joelbm24@gmail.com
* Enrique Gavidia => oblique63@gmail.com

 ---

## Installation
Just include these lines in your `pubspec.yaml` file.

```yaml
dapir:
    git: git@github.com:joelbm24/Dapir.git
    version: '>=0.0.2'
```

---

## Examples

### URL Construction

<br />

> #### Simple Route
```dart
String base_url = 'https://jsonplaceholder.typicode.com';
Map<String, String> header = {
    'Content-Type': 'json/application',
};

var example = Dapir(base_url, headers: header);
DapirRequest example_request = example.request();
```

<br />

> #### Nested Routes
```dart
var base = Dapir(base_url, headers: header);
var posts = Dapir('/posts', parent: base);
var post_id = Dapir('/1', parent: posts);
DapirRequest request = post_id.request();

var compoundPath = Dapir('/posts/2', parent: base);
request = compoundPath.request();
```

<br />

> #### Query Parameters
```dart
var posts = Dapir('${base_url}/posts', headers: header);
Map<String, dynamic> params = {
  'userId': 1
};

DapirRequest posts_request = posts.request(params: params);
```

<br />

> #### Single Path Substitution
```dart
var users = Dapir('${base_url}/users', headers: header);
var user_id = Dapir('/~id', parent: users);
DapirRequest user_request = user_id.request(substitutions: {'~id': 10});
```

<br />

> #### Multiple Path Substitutions
```dart
// Method 1: Original style.
var base = Dapir(base_url, headers: header);
var users = Dapir('/users', parent: base);
var user_id = Dapir('/~id', parent: users);
var user_attr = Dapir('/~attr', parent: user_id);

DapirRequest request = user_attr.request(substitutions: {'~id': 1, '~attr': 'posts'});

// Method 2: Shorthand for defining new children.
base = Dapir(base_url, headers: header);
users = base + '/users';
user_id = users + '/~id';
user_attr = user_id + '/~attr';
// Equivalent to
//   users = base.newChild('/users');
// And
//   users = Dapir('/users', parent: base);

request = user_attr.request(substitutions: {'~id': 2, '~attr': 'posts'});

// Method 3: Construct compound url path as a single Dapir object.
var full_path = Dapir('/users/~id/~attr', parent: base);
request = full_path.request(substitutions: {'~id': 3, '~attr': 'todos'});

// Method 4: Flutter-like, Nested Dapir Object Definitions.
var root = Dapir(base_url, headers: header, children: [
  Dapir('/users', children: [
    Dapir('/~id', children: [
      Dapir('/~attr')
    ]),
  ]),
]);

// Retreiving nested child objects
var endpoint = root / 'users' / '~id' / '~attr';
// Equivalent to
//  var endpoint = root['/users']['/~id']['/~attr'];

request = endpoint.request(substitutions: {'~id': 4, '~attr': 'posts'});

// Method 5: Constructing compound url path as a chain of Dapir objects.
var last_child = Dapir(base_url, headers: header) + '/users' + '/~id' + '/~attr';

request = last_child.request(substitutions: {'~id': 5, '~attr': 'posts'});

// Method 6: Composing existing Dapir objects.
base = Dapir(base_url, headers: header);
users = base >> Dapir('/users');
user_id = users >> Dapir('/~id');
user_attr = user_id >> Dapir('/~attr');

request = user_attr.request(substitutions: {'~id': 2, '~attr': 'posts'});
  ```

<br />

### Making Requests

<br />

> #### Simple Request
```dart
var user = Dapir('${base_url}/users/10');
var request = user.request();
var response = await request.makeRequest();
```

<br />

> #### With Handler
```dart
var request = Dapir('${base_url}/users/10').request();
User user = await request.makeRequest((response) => User.fromJson(response));
```

<br />

> #### With Query
```dart
var posts = Dapir('${base_url}/posts');
var filtered_posts = posts.request(params: {'userId': 1});
List<Post> post_objects = await filtered_posts.makeRequest((response) => Post.fromJsonArray(response));
```
