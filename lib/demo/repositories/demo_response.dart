import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;

class DemoResponse {
  DemoResponse._();

  static Response<T> typed<T>(Map<String, dynamic> json, T body, {int statusCode = 200}) {
    return Response<T>(http.Response(jsonEncode(json), statusCode), body);
  }

  static Response raw(Map<String, dynamic> json, {int statusCode = 200}) {
    return Response(http.Response(jsonEncode(json), statusCode), json);
  }
}
