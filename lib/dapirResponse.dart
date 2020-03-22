part of dapir;

// TODO: figure out what we want to do with this / how to use it.
abstract class DapirResponse {
  String body;
}

mixin JsonResponse on DapirResponse {
  decode() {

  }
}

mixin XmlResponse on DapirResponse {
  decode() {

  }
}