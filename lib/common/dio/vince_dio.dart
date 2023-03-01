import 'dart:io';

import 'package:baedal/common/constant/data.dart';
import 'package:baedal/common/secure_storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.add(
    CustomInterceptor(storage),
  );

  return dio;
});

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  CustomInterceptor(this.storage);

  /// 1) 요청 보낼때
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('[REQ✈️] [${options.method}] ${options.uri}');

    print(options.headers);

    /// check access token
    if (options.headers.containsKey('accessToken') &&
        options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken');

      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }

    return super.onRequest(options, handler);
  }

  /// 2) 응답 받을때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '[RES📦] [${response.requestOptions.method}] ${response.requestOptions.uri}');

    return super.onResponse(response, handler);
  }

  /// 3) 에러났을 때
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // 401 -> ACCESS 토큰 재발급 시도
    print('[ERR⁉️] [${err.requestOptions.method}] [${err.requestOptions.uri}]');

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    if (refreshToken == null) {
      /// Refresh token 만료
      handler.reject(err);
      return;
    }

    final isUnauthorized = err.response?.statusCode == HttpStatus.unauthorized;
    final isPathRefresh = err.requestOptions.path == '/auth/token';

    if (isUnauthorized && !isPathRefresh) {
      /// refresh 가 아닌데 401 -> 액세스토큰 만료
      final dio = Dio();

      try {
        final resp = await dio.post(
          'http://$ip/auth/token',
          options: Options(headers: {
            'authorization': 'Bearer $refreshToken',
          }),
        );

        final accessToken = resp.data['accessToken'];
        final options = err.requestOptions;
        options.headers.addAll({
          'authorization': 'Bearer $accessToken',
        });
        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

        final response = await dio.fetch(options);
        return handler.resolve(response);
      } on DioError catch (e) {
        return handler.reject(e);
      }
    }
  }
}
