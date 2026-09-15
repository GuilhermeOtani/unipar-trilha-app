import 'package:dio/dio.dart';
import 'package:unipar_trilha_app/core/api_client.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/constants_api.dart';
import 'package:unipar_trilha_app/modules/home/dto/professor_contexto_response.dart';

abstract interface class ProfessorContextoServiceContract {
  Future<ProfessorContextoResponse> obter();
}

class ProfessorContextoService implements ProfessorContextoServiceContract {
  ProfessorContextoService({Dio? dio}) : _dio = dio ?? ApiClient.shared.dio;

  final Dio _dio;

  @override
  Future<ProfessorContextoResponse> obter() async {
    try {
      final data = (await _dio.get<Object?>(
        ConstantsApi.professorContexto,
      )).data;
      if (data is! Map) {
        throw const ApiError(message: 'A resposta do contexto é inválida.');
      }
      return ProfessorContextoResponse.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (exception) {
      throw ApiError.fromDioException(exception);
    } on FormatException catch (exception) {
      throw ApiError(message: exception.message);
    }
  }
}
