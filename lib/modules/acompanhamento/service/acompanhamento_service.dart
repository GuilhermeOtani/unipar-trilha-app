import 'package:dio/dio.dart';
import 'package:unipar_trilha_app/core/api_client.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/constants_api.dart';
import 'package:unipar_trilha_app/modules/acompanhamento/dto/indicadores_turma_response.dart';

abstract interface class AcompanhamentoServiceContract {
  Future<IndicadoresTurmaResponse> obter(int turmaId);
}

class AcompanhamentoService implements AcompanhamentoServiceContract {
  AcompanhamentoService({Dio? dio}) : _dio = dio ?? ApiClient.shared.dio;

  final Dio _dio;

  @override
  Future<IndicadoresTurmaResponse> obter(int turmaId) async {
    try {
      final data = (await _dio.get<Object?>(
        ConstantsApi.indicadoresTurma(turmaId),
      )).data;
      if (data is! Map) {
        throw const ApiError(message: 'A resposta dos indicadores é inválida.');
      }
      return IndicadoresTurmaResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (exception) {
      throw ApiError.fromDioException(exception);
    } on FormatException catch (exception) {
      throw ApiError(message: exception.message);
    }
  }
}
