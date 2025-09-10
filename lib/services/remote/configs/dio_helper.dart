import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertest/configs/route/route_name.dart';
import 'package:fluttertest/configs/route/routes.dart';
import 'package:fluttertest/services/local/secure_storage/secure_storage_service.dart';
import 'package:fluttertest/services/local/shared_preferences/shared_preferences_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioHelper {
  static Dio createDio(String baseUrl) {
    final Dio dio = Dio(BaseOptions(baseUrl: baseUrl));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requireAuth = options.extra["requireAuth"] ?? true;
          if (requireAuth) {
            final accessToken = await SecureStorageService().readToken();
            if (accessToken != null) {
              options.headers["Authorization"] = "Bearer $accessToken";
            }
          }
          // final requireIpv4 = options.extra["requireIpv4"] ?? false;
          // if (requireIpv4) {
          //   final ipv4 = await CommonService().getPublicIp();
          //   if (ipv4 != null) {
          //     options.queryParameters.addEntries([MapEntry("ipv4", ipv4)]);
          //   }
          // }
          // final requireLanguage = options.extra["requireLanguage"] ?? true;
          // if (requireLanguage) {
          //   final language =
          //       SharedPrefService.getLanguage() ?? LocaleEnum.id.name;
          //   options.queryParameters.addEntries([MapEntry("lang", language)]);
          // }
          return handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (DioException error, handler) async {
          final requireAuth = error.requestOptions.extra["requireAuth"] ?? true;
          if (error.response?.statusCode == 401 && requireAuth == true) {
            await SecureStorageService().deleteAll();
            SharedPrefService.clearAll();
            Routes.router.goNamed(RouteName.login);
          }
          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
      dio.interceptors.add(ChuckerDioInterceptor());
    }

    return dio;
  }
}
