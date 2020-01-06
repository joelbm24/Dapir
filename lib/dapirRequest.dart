part of dapir;

class DapirRequest {
    String verb;
    Map<String, String> header;
    String url;
    Map<String, dynamic> body;

    DapirRequest({String verb, Map<String, String> header, String url, Map<String, dynamic> body}) {
        this.verb = verb;
        this.header = header;
        this.url = url;
        this.body = body;
    }

}
