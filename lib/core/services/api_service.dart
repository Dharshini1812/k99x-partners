// Adjust this file's actual location to wherever ApiService/ApiServiceImpl
// already live in your project — only `get()` changed (now takes an
// optional `headers` param), everything else is identical to what you
// pasted. Diff is isolated to the abstract method signature and the
// get() implementation below.

import 'dart:convert';
import 'dart:developer';
import 'package:dealer/core/helper/storage_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ApiService {
  Future get(String url, {Map<String, String>? headers});
  Future post(String url, Map map);
  Future get1(String url);
  Future get2(String url);
  Future post1(String url, Map? map);
  Future post2(String url, Map map);
  Future uploadImage({
    required String url,
    required String vehicleId,
    required String imageType,
    required String filePath,
  });

  Future postMultipart(String url, FormData formData,
      {bool requiresAuth = true});
  void cancelAllRequests([String reason]);
}

class ApiServiceImpl extends ApiService {
  Ref ref;
  ApiServiceImpl(this.ref);
  final Dio dio = Dio(
    BaseOptions(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-KEY': 'K99X-2021-AU',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 180),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
  CancelToken _token = CancelToken();

  CancelToken get _activeToken {
    if (_token.isCancelled) {
      _token = CancelToken();
    }
    return _token;
  }

  @override
  void cancelAllRequests([String reason = 'Logged out']) {
    _token.cancel(reason);
  }

  bool _isCancellation(Object e) =>
      e is DioException && e.type == DioExceptionType.cancel;

  Future<Map<String, String>> getAuthHeaders() async {
    // CURRENT BASIC AUTH

    final storage = SecureStorageService();

    final username = await storage.getUsername();
    final password = await storage.getPassword();
    final userId = await storage.getUserId();
    if (username == null ||
        username.trim().isEmpty ||
        password == null ||
        password.trim().isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.cancel,
        error: 'Not authenticated — no active session',
      );
    }

    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    return {
      'Authorization': basicAuth,
      'X-USER-ID': userId.toString(),
    };
  }

  @override
  Future get(String url, {Map<String, String>? headers}) async {
    try {
      log("GET Request to: $url");
      // Dio merges per-request Options.headers on top of BaseOptions'
      // headers (Content-Type/Accept/X-API-KEY stay, these just add to
      // them) — so passing e.g. {'X-USER-ID': '193'} here doesn't drop
      // anything already set globally.
      final response = await dio.get(
        url,
        options: headers != null ? Options(headers: headers) : null,
        cancelToken: _activeToken,
      );
      log("Response from $url: ${response.statusCode} - ${response.data}");
      return response;
    } catch (e) {
      if (_isCancellation(e)) {
        log("Request cancelled: $url");
      } else {
        log("Error during GET request to $url: $e");
      }
      rethrow;
    }
  }

  @override
  Future post(String url, Map map) async {
    try {
      log('POST => $url');
      log('DATA => $map');
      final response =
          await dio.post(url, data: map, cancelToken: _activeToken);
      log('Response from $url: ${response.statusCode} - ${response.data}');
      return response;
    } catch (e) {
      if (_isCancellation(e)) {
        log("Request cancelled: $url");
      } else {
        log("Error during POST request to $url: $e");
      }
      rethrow;
    }
  }

  @override
  Future get1(String url) async {
    try {
      log("GET Request to: $url");

      final response = await dio.get(
        url,
        options: Options(
          headers: await getAuthHeaders(),
        ),
        cancelToken: _activeToken,
      );

      log("Response from $url: ${response.statusCode} - ${response.data}");
      return response;
    } catch (e) {
      if (_isCancellation(e)) {
        log("Request cancelled: $url");
      } else {
        log("Error during GET request to $url: $e");
      }
      rethrow;
    }
  }

  @override
  Future get2(String url) async {
    try {
      log("GET Request to: $url");

      final response = await dio.get(
        url,
        options: Options(headers: await getAuthHeaders()),
        cancelToken: _activeToken,
      );

      log("Response from $url: ${response.statusCode} - ${response.data}");
      return response.data; // <-- return the body, not the Response wrapper
    } catch (e) {
      if (_isCancellation(e)) {
        log("Request cancelled: $url");
      } else {
        log("Error during GET request to $url: $e");
      }
      rethrow;
    }
  }

  @override
  Future post1(String url, Map? map) async {
    try {
      log('POST => $url');
      log('DATA => $map');

      final response = await dio.post(
        url,
        data: map,
        options: Options(
          headers: await getAuthHeaders(),
        ),
        cancelToken: _activeToken,
      );

      log('Response from $url: ${response.statusCode} - ${response.data}');
      return response;
    } catch (e) {
      if (_isCancellation(e)) {
        log("Request cancelled: $url");
      } else {
        log("Error during POST request to $url: $e");
      }
      rethrow;
    }
  }

  @override
  Future post2(String url, Map map) async {
    try {
      log('POST => $url');
      log('DATA => $map');

      final response = await dio.post(
        url,
        data: map,
        options: Options(
            headers: await getAuthHeaders(), responseType: ResponseType.plain),
        cancelToken: _activeToken,
      );

      log('Response from $url: ${response.statusCode} - ${response.data}');
      return response;
    } catch (e) {
      if (_isCancellation(e)) {
        log("Request cancelled: $url");
      } else {
        log("Error during POST request to $url: $e");
      }
      rethrow;
    }
  }

  @override
  Future uploadImage({
    required String url,
    required String vehicleId,
    required String imageType,
    required String filePath,
  }) async {
    try {
      log('UPLOAD => $url ($imageType)');

      final fileName = filePath.split(RegExp(r'[/\\]')).last;

      final formData = FormData.fromMap({
        "vehicleId": vehicleId,
        imageType: await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: await getAuthHeaders(),
        ),
        cancelToken: _activeToken,
      );

      log('Upload Response: ${response.data}');
      return response;
    } on DioException catch (e) {
      if (_isCancellation(e)) {
        log('Upload cancelled: $url');
      } else {
        log('Upload Error: ${e.response?.data}');
      }
      rethrow;
    }
  }

  @override
  Future postMultipart(
    String url,
    FormData formData, {
    bool requiresAuth = true,
  }) async {
    try {
      log('POST(multipart) => $url');
      log('FIELDS => ${formData.fields}');
      log('FILES => ${formData.files.map((f) => f.key)}');

      final response = await dio.post(
        url,
        data: formData,
        options: requiresAuth ? Options(headers: await getAuthHeaders()) : null,
        cancelToken: _activeToken,
      );

      log('Response from $url: ${response.statusCode} - ${response.data}');
      return response;
    } catch (e) {
      if (_isCancellation(e)) {
        log("Request cancelled: $url");
      } else {
        log("Error during POST(multipart) request to $url: $e");
      }
      rethrow;
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiServiceImpl(ref));
