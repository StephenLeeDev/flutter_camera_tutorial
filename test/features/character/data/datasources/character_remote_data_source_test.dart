import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_camera_tutorial/features/character/data/models/character_model.dart';
import 'package:flutter_camera_tutorial/features/character/data/datasources/character_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'character_remote_data_source_test.mocks.dart';
import '../../../../fixtures/fixture_reader.dart';

// 1. Dio 클래스를 Mocking 하도록 설정
@GenerateMocks([Dio])
void main() {
  late CharacterRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = CharacterRemoteDataSourceImpl(dio: mockDio);
  });

  void setUpMockDioSuccess200() {
    // 2. dio.get('/character')가 호출되면, 미리 준비된 성공 응답(JSON)과 함께
    // statusCode 200을 담은 Response 객체를 반환하도록 설정
    when(mockDio.get('/character')).thenAnswer(
          (_) async => Response(
        requestOptions: RequestOptions(path: '/character'),
        data: json.decode(fixture('character_list.json')),
        statusCode: 200,
      ),
    );
  }

  void setUpMockDioFailure404() {
    // 3. dio.get('/character')가 호출되면, DioException을 던지도록 설정 (404 에러 흉내)
    when(mockDio.get('/character')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/character'),
        response: Response(
          requestOptions: RequestOptions(path: '/character'),
          data: 'Something went wrong',
          statusCode: 404,
        ),
      ),
    );
  }

  group('getCharacters', () {
    final tCharacterListModel = CharacterList.fromJson(json.decode(fixture('character_list.json')));

    test(
      'should return CharacterList when the response code is 200 (success)',
          () async {
        // Arrange
        setUpMockDioSuccess200();
        // Act
        final result = await dataSource.getCharacters();
        // Assert
        expect(result, equals(tCharacterListModel));
      },
    );

    test(
      'should throw a DioException when the response code is 404 or other error code',
          () async {
        // Arrange
        setUpMockDioFailure404();
        // Act
        final call = dataSource.getCharacters;
        // Assert
        // dataSource.getCharacters()를 호출하면 Exception이 발생하는지 확인
        expect(() => call(), throwsA(isA<Exception>()));
      },
    );
  });
}
