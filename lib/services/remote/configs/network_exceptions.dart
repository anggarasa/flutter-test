import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_exceptions.freezed.dart';

@freezed
abstract class NetworkExceptions<T> with _$NetworkExceptions<T> {
  const factory NetworkExceptions.timeout({required String? message}) =
      Timeout<T>;

  const factory NetworkExceptions.badResponse({
    required String? statusCode,
    required String? message,
    required T data,
  }) = BadResponse<T>;

  const factory NetworkExceptions.cancel({required String? message}) =
      Cancel<T>;

  const factory NetworkExceptions.connectionError({required String? message}) =
      ConnectionError<T>;

  const factory NetworkExceptions.unknown({required String? message}) =
      Unknown<T>;

  const factory NetworkExceptions.defaultError({required String? message}) =
      DefaultError<T>;
}
