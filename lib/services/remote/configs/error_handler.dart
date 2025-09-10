import 'package:dio/dio.dart';
import 'package:fluttertest/services/local/secure_storage/secure_storage_service.dart';
import 'package:fluttertest/services/remote/configs/api_response.dart';
import 'package:fluttertest/services/remote/configs/network_exceptions.dart';

class ErrorHandler {
  SecureStorageService secureStorageService = SecureStorageService();

  static ApiResponse<T> handleException<T>(
    DioException error, {
    String? message,
  }) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse.error(
          NetworkExceptions.timeout(message: message ?? "Connection Timeout"),
        );
      case DioExceptionType.badResponse:
        if (error.response != null && error.response?.data != null) {
          try {
            final errorData = error.response?.data;
            final statusCode = error.response?.statusCode;
            if (errorData is Map<String, dynamic>) {
              if (errorData.containsKey("message")) {
                return ApiResponse.error(
                  NetworkExceptions.badResponse(
                    statusCode: statusCode?.toString(),
                    message: message ?? errorData["message"],
                    data: errorData,
                  ),
                );
              }
            } else if (errorData is String) {
              if (errorData.contains("<")) {
                return ApiResponse.error(
                  NetworkExceptions.defaultError(
                    message: message ?? "Unexpected error occurred",
                  ),
                );
              }
              return ApiResponse.error(
                NetworkExceptions.badResponse(
                  statusCode: statusCode?.toString(),
                  message: message ?? "Bad Response",
                  data: errorData,
                ),
              );
            }
          } catch (e) {
            return const ApiResponse.error(
              NetworkExceptions.unknown(message: "An unknown error occurred."),
            );
          }
        }
        return ApiResponse.error(
          NetworkExceptions.badResponse(
            statusCode: error.response?.statusCode.toString(),
            message:
                message ??
                "Received invalid status code: ${error.response?.statusCode}",
            data: null,
          ),
        );
      case DioExceptionType.cancel:
        return ApiResponse.error(
          NetworkExceptions.cancel(
            message: message ?? "Request to API server was cancelled",
          ),
        );
      case DioExceptionType.connectionError:
        return ApiResponse.error(
          NetworkExceptions.connectionError(
            message:
                message ??
                "Connection to API server failed due to internet connection",
          ),
        );
      case DioExceptionType.unknown:
        return ApiResponse.error(
          NetworkExceptions.unknown(
            message: message ?? "An unknown error occurred.",
          ),
        );
      default:
        return ApiResponse.error(
          NetworkExceptions.defaultError(
            message: message ?? "Unexpected error occurred",
          ),
        );
    }
  }
}
