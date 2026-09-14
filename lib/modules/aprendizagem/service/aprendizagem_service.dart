import 'package:dio/dio.dart';
import 'package:unipar_trilha_app/core/api_client.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/constants_api.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/dto/resposta_aluno_request.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/dto/resposta_aluno_response.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/dto/sessao_response.dart';

class AprendizagemService {
  AprendizagemService({Dio? dio}) : _dio = dio ?? ApiClient.shared.dio;

  final Dio _dio;

  /// Cria a sessão da distribuição ou devolve a que já está em andamento.
  Future<SessaoResponse> iniciarOuRetomar(int distribuicaoId) {
    return _sessao(
      () => _dio.post<Object?>(ConstantsApi.alunoIniciarSessao(distribuicaoId)),
    );
  }

  Future<SessaoResponse> buscarSessao(int sessaoId) {
    return _sessao(() => _dio.get<Object?>(ConstantsApi.alunoSessao(sessaoId)));
  }

  /// Envia a resposta uma única vez; timeouts não são repetidos.
  Future<RespostaAlunoResponse> responder(
    int sessaoId,
    RespostaAlunoRequest request,
  ) async {
    try {
      final response = await _dio.post<Object?>(
        ConstantsApi.alunoRespostas(sessaoId),
        data: request.toJson(),
      );
      final data = response.data;
      if (data is! Map) {
        throw const ApiError(message: 'A resposta da correção é inválida.');
      }
      return RespostaAlunoResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (exception) {
      throw ApiError.fromDioException(exception);
    } on FormatException catch (exception) {
      throw ApiError(message: exception.message);
    }
  }

  Future<SessaoResponse> _sessao(
    Future<Response<Object?>> Function() requisicao,
  ) async {
    try {
      final data = (await requisicao()).data;
      if (data is! Map) {
        throw const ApiError(message: 'A resposta da sessão é inválida.');
      }
      return SessaoResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (exception) {
      throw ApiError.fromDioException(exception);
    } on FormatException catch (exception) {
      throw ApiError(message: exception.message);
    }
  }
}
