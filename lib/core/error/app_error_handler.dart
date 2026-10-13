import 'dart:io';
import 'package:dio/dio.dart';

class AppErrorHandler {
  static String parse(dynamic error) {
    if (error is DioException) {
      if (error.type case DioExceptionType.connectionTimeout) {
        return 'Connection timed out. Please check your internet connection.';
      } else if (error.type case DioExceptionType.sendTimeout) {
        return 'Unable to send data in time. Please try again.';
      } else if (error.type case DioExceptionType.receiveTimeout) {
        return 'The server took too long to respond. Please try again later.';
      } else if (error.type case DioExceptionType.badCertificate) {
        return 'Security certificate verification failed.';
      } else if (error.type case DioExceptionType.badResponse) {
        return _extractBackendMessage(error.response?.data) ??
            'Server error (${error.response?.statusCode}). Please try again.';
      } else if (error.type case DioExceptionType.cancel) {
        return 'Request was cancelled.';
      } else if (error.type case DioExceptionType.connectionError) {
        return 'No internet connection. Please verify your network and retry.';
      } else if (error.type case DioExceptionType.unknown) {
        if (error.error is SocketException) {
          return 'Network unreachable. Please check your network connection.';
        }
        return 'An unexpected network error occurred. Please try again.';
      }
    } else if (error is SocketException) {
      return 'No internet connection.';
    } else if (error is String) {
      return error;
    } else if (error is FormatException) {
      return 'Bad data format received from server.';
    }

    return error?.toString().replaceAll('Exception: ', '') ??
        'An unexpected error occurred. Please try again.';
  }

  static String? _extractBackendMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      if (data.containsKey('message') && data['message'] != null) {
        return data['message'].toString();
      }
      if (data.containsKey('error') && data['error'] != null) {
        return data['error'].toString();
      }
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
    return null;
  }
}
