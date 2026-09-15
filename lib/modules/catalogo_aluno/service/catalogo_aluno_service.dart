import 'package:dio/dio.dart';
import 'package:unipar_trilha_app/core/api_client.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/constants_api.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/dto/catalogo_aluno_response.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/dto/caminho_aluno_response.dart';

abstract interface class CatalogoAlunoServiceContract {
  Future<CatalogoAlunoResponse> listar();
  Future<CaminhoAlunoResponse> buscarCaminho(int distribuicaoId);
}

class CatalogoAlunoService implements CatalogoAlunoServiceContract {
  CatalogoAlunoService({Dio? dio}) : _dio = dio ?? ApiClient.shared.dio;

  final Dio _dio;

  @override
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

  @override
  Future<CaminhoAlunoResponse> buscarCaminho(int distribuicaoId) async {
    try {
      final data = (await _dio.get<Object?>(
        ConstantsApi.alunoCaminho(distribuicaoId),
      )).data;
      if (data is! Map) {
        throw const ApiError(message: 'A resposta do caminho é inválida.');
      }
      return CaminhoAlunoResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (exception) {
      throw ApiError.fromDioException(exception);
    } on FormatException catch (exception) {
      throw ApiError(message: exception.message);
    }
  }
}
