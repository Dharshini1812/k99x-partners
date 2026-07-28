import 'dart:convert';
import 'dart:developer';
import 'package:dealer/core/helper/storage_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ApiService {
  Future get(String url);
  Future post(String url, Map map);
  Future get1(String url);
  Future get2(String url);
  Future post1(String url, Map map);
  Future post2(String url, Map map);
  Future uploadImage({
    required String url,
    required String vehicleId,
    required String imageType,
    required String filePath,
  });
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
  Future<Map<String, String>> getAuthHeaders() async {
    // CURRENT BASIC AUTH

    final storage = SecureStorageService();

    final username = await storage.getUsername();
    final password = await storage.getPassword();

    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    return {
      'Authorization': basicAuth,
    };

    // FUTURE JWT TOKEN
    // final token = savedTokenFromCache;
    // return {
    //   'Authorization': 'Bearer $token',
    // };
  }

  @override
  Future get(String url) async {
    try {
      log("GET Request to: $url");
      final response = await dio.get(url);
      log("Response from $url: ${response.statusCode} - ${response.data}");
      return response;
    } catch (e) {
      log("Error during GET request to $url: $e");
      rethrow;
    }
  }

  @override
  Future post(String url, Map map) async {
    try {
      log('POST => $url');
      log('DATA => $map');
      final response = await dio.post(url, data: map);
      log('Response from $url: ${response.statusCode} - ${response.data}');
      return response;
    } catch (e) {
      log("Error during POST request to $url: $e");
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
      );

      log("Response from $url: ${response.statusCode} - ${response.data}");
      return response;
    } catch (e) {
      log("Error during GET request to $url: $e");
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
      );

      log("Response from $url: ${response.statusCode} - ${response.data}");
      return response.data; // <-- return the body, not the Response wrapper
    } catch (e) {
      log("Error during GET request to $url: $e");
      rethrow;
    }
  }

  @override
  Future post1(String url, Map map) async {
    try {
      log('POST => $url');
      log('DATA => $map');

      final response = await dio.post(
        url,
        data: map,
        options: Options(
          headers: await getAuthHeaders(),
        ),
      );

      log('Response from $url: ${response.statusCode} - ${response.data}');
      return response;
    } catch (e) {
      log("Error during POST request to $url: $e");
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
      );

      log('Response from $url: ${response.statusCode} - ${response.data}');
      return response;
    } catch (e) {
      log("Error during POST request to $url: $e");
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
      vehicleId = vehicleId;
      log('UPLOAD IMAGE => $url');
      log('vehicleId => $vehicleId');
      log('imageType => $imageType');
      log('filePath => $filePath');

      final fileName = filePath.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        url,
        queryParameters: {
          'vehicleId': vehicleId,
          'imageType': imageType,
        },
        data: formData,
        options: Options(
          headers: await getAuthHeaders(),
          contentType: 'multipart/form-data',
        ),
      );

      log(
        'UPLOAD RESPONSE => '
        '${response.statusCode} - ${response.data}',
      );

      return response;
    } on DioException catch (e) {
      log('UPLOAD ERROR => ${e.response?.statusCode}');
      log('UPLOAD ERROR DATA => ${e.response?.data}');
      rethrow;
    }
  }
}
