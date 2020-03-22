import 'package:test/test.dart';
import '../lib/dapir.dart';

void main() {
  String base_url = "https://api.example.com";
  Map<String, String> header = {
      "Content-Type": "json/application",
  };

  test('test simple route', () {
    Dapir example = new Dapir(base_url, headers: header);

    DapirRequest example_request = example.request();
    expect(example_request.url, equals(base_url));
  });

  test('test complex route', () {
    var example = new Dapir(base_url, headers: header);
    var ponyStable = new Dapir("/ponyStable", parent: example);
    var prettyPony = new Dapir("/prettyPony", parent: ponyStable);
    DapirRequest request = prettyPony.request();
    expect(request.url, equals("https://api.example.com/ponyStable/prettyPony"));

    var compoundPath = new Dapir('/ponyStable/prettyPony', parent: example);
    request = compoundPath.request();
    expect(request.url, equals("https://api.example.com/ponyStable/prettyPony"));
  });

  test('test url substitutions', () {
    Dapir example = new Dapir(base_url, headers: header);
    Dapir ponyFood = new Dapir("/ponyFood", parent: example);
    Dapir food = new Dapir("~food", parent: ponyFood);
    DapirRequest food_request = food.request(extras: ["apples"]);

    expect(food_request.url, equals("https://api.example.com/ponyFood/apples"));
  });

  test('test multiple url substitutions', () {
    var example = new Dapir(base_url, headers: header);
    var ponies = new Dapir('/ponies', parent: example);
    var pony = new Dapir("~pony", parent: ponies);
    var attribute = new Dapir("~attr", parent: pony);
    DapirRequest request = attribute.request(extras: ["applejack", "height"]);
    expect(request.url, equals("https://api.example.com/ponies/applejack/height"));

    // TODO: this doesn't work!
    //var fullPath = new Dapir('/ponies/~pony/~attr', parent: example);
    //request = fullPath.request(extras: ["pinkiepie", "weight"]);
    //expect(request.url, equals("https://api.example.com/ponies/pinkiepie/weight"));
  });

  test('test url with params', () {
    Dapir example = new Dapir(base_url, headers: header);
    Dapir pretty_pony = new Dapir("/mylittlepony", parent: example);
    Map<String, String> params = {
      "species": "unicorn",
      "color": "purple"
    };

    DapirRequest pony_request = pretty_pony.request(params: params);
    // TODO:
    // DapirResponse pony_response = pony_request.makeRequest();
    // pony_response.getFavoriteFood();

    expect(pony_request.url, equals("https://api.example.com/mylittlepony?species=unicorn&color=purple"));
  });
}