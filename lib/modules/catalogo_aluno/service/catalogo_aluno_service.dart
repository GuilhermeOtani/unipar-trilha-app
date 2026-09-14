import 'package:dio/dio.dart';
import 'package:unipar_trilha_app/core/api_client.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/constants_api.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/dto/catalogo_aluno_response.dart';

class CatalogoAlunoService {
  CatalogoAlunoService({Dio? dio}) : _dio = dio ?? ApiClient.shared.dio;

  final Dio _dio;

  Future<CatalogoAlunoResponse> listar() async {
    try {
      final response = await _dio.get<Object?>(ConstantsApi.alunoDistribuicoes);
      final data = response.data;
      if (data is! Map) {
        throw const ApiError(message: 'A resposta do catálogo é inválida.');
      }
      return CatalogoAlunoResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (exception) {
      throw ApiError.fromDioException(exception);
    } on FormatException catch (exception) {
      throw ApiError(message: exception.message);
    }
  }
}
