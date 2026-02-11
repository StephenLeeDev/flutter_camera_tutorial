import 'package:dio/dio.dart';

import '../models/character_model.dart';

abstract class CharacterRemoteDataSource {
  Future<CharacterList> getCharacters();
}

class CharacterRemoteDataSourceImpl implements CharacterRemoteDataSource {
  final Dio dio;

  CharacterRemoteDataSourceImpl({required this.dio});

  @override
  Future<CharacterList> getCharacters() async {
    try {
      final response = await dio.get('/character');
      if (response.statusCode == 200) {
        return CharacterList.fromJson(response.data);
      } else {
        throw Exception('Failed to load characters');
      }
    } on DioException catch (e) {
      throw Exception('Network Error: ${e.message}');
    }
  }
}