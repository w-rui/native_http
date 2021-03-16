import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';

const MethodChannel _channel = const MethodChannel('native_http');

Future<NativeResponse> get(
  String url, {
  Map<String, dynamic> headers = const {},
}) {
  return request(url: url, method: "GET", headers: headers);
}

Future<NativeResponse> post(
  String url, {
  Map<String, dynamic> headers = const {},
  Uint8List? body,
}) {
  return request(url: url, method: "POST", headers: headers, body: body);
}

Future<NativeResponse> request({
  required String url,
  required String method,
  required Map<String, dynamic> headers,
  Uint8List? body
}) async {
  var req = {
    "url": url,
    "method": method,
    "headers": headers,
    "body": body ?? Uint8List(0),
  };

  Map<String, dynamic>? response = await _channel.invokeMapMethod<String, dynamic>("native_http/request", req);

  if (response == null)
    throw Exception("response is null for $req.");

  return NativeResponse._fromMap(response);
}

class NativeResponse {
  int code;
  Uint8List body;

  NativeResponse({ required this.code, required this.body });

  dynamic getJson() => json.decode(utf8.decode(body));

  static NativeResponse _fromMap(Map<String, dynamic> response) {
    return NativeResponse(code: response["code"], body: response["body"]);
  }
}
