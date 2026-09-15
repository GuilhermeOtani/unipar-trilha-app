import 'package:dio/dio.dart';
import 'package:unipar_trilha_app/core/api_client.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/constants_api.dart';
import 'package:unipar_trilha_app/modules/distribuicao/dto/distribuicao_dto.dart';

abstract interface class DistribuicaoServiceContract {
  Future<List<DistribuicaoResponse>> listar(int turmaId);
  Future<DistribuicaoResponse> criar(DistribuicaoRequest request);
}

class DistribuicaoService implements DistribuicaoServiceContract {
  DistribuicaoService({Dio? dio}) : _dio = dio ?? ApiClient.shared.dio;

  final Dio _dio;

  @override
  Future<List<DistribuicaoResponse>> listar(int turmaId) async {
    try {
      final data = (await _dio.get<Object?>(
        ConstantsApi.distribuicoes,
        queryParameters: {'turmaId': turmaId},
      )).data;
      if (data is! List) {
        throw const ApiError(message: 'A lista de distribuições é inválida.');
      }
      return data
          .map((item) {
            if (item is! Map) {
              throw const FormatException('Distribuição inválida.');
            }
            return DistribuicaoResponse.fromJson(
              Map<String, dynamic>.from(item),
            );
          })
          .toList(growable: false);
    } on DioException catch (exception) {
      throw ApiError.fromDioException(exception);
    } on FormatException catch (exception) {
      throw ApiError(message: exception.message);
    }
  }

  @override
  Future<DistribuicaoResponse> criar(DistribuicaoRequest request) async {
    try {
      final data = (await _dio.post<Object?>(
        ConstantsApi.distribuicoes,
        data: request.toJson(),
      )).data;
      if (data is! Map) {
        throw const ApiError(message: 'A resposta da distribuição é inválida.');
      }
      return DistribuicaoResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (exception) {
      throw ApiError.fromDioException(exception);
    } on FormatException catch (exception) {
      throw ApiError(message: exception.message);
    }
  }
}
