import 'package:dio/dio.dart';

// 기본 Dio 인스턴스를 생성하고 설정합니다.
// 앱 전역에서 이 인스턴스를 공유하여 사용합니다.
final dio = Dio(
  BaseOptions(
    baseUrl: 'https://rickandmortyapi.com/api',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ),
);