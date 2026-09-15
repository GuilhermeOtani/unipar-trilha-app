import 'package:dio/dio.dart';
import 'package:unipar_trilha_app/core/api_client.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/constants_api.dart';
import 'package:unipar_trilha_app/modules/trilha/dto/trilha_dto.dart';

abstract interface class TrilhaServiceContract {
  Future<List<TrilhaProfessorResumoResponse>> listar();
  Future<TrilhaResponse> criar(TrilhaCreateRequest request);
  Future<TrilhaResponse> buscar(int id);
  Future<TrilhaResponse> atualizar(int id, TrilhaConteudoRequest request);
  Future<PublicacaoResponse> publicar(int id);
}

class TrilhaService implements TrilhaServiceContract {
  TrilhaService({Dio? dio}) : _dio = dio ?? ApiClient.shared.dio;

  final Dio _dio;

  @override
  Future<List<TrilhaProfessorResumoResponse>> listar() async {
    try {
      final data = (await _dio.get<Object?>(ConstantsApi.trilhas)).data;
      if (data is! List) {
        throw const ApiError(message: 'A lista de trilhas é inválida.');
      }
      return data
          .map((item) {
            if (item is! Map) throw const FormatException('Trilha inválida.');
            return TrilhaProfessorResumoResponse.fromJson(
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
  Future<TrilhaResponse> criar(TrilhaCreateRequest request) => _trilha(
    () => _dio.post<Object?>(ConstantsApi.trilhas, data: request.toJson()),
  );

  @override
  Future<TrilhaResponse> buscar(int id) =>
      _trilha(() => _dio.get<Object?>(ConstantsApi.trilha(id)));

  @override
  Future<TrilhaResponse> atualizar(int id, TrilhaConteudoRequest request) =>
      _trilha(
        () =>
            _dio.put<Object?>(ConstantsApi.trilha(id), data: request.toJson()),
      );

  @override
  Future<PublicacaoResponse> publicar(int id) async {
    try {
      final data = (await _dio.post<Object?>(
        ConstantsApi.publicarTrilha(id),
      )).data;
      if (data is! Map) {
        throw const ApiError(message: 'A resposta da publicação é inválida.');
      }
      return PublicacaoResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (exception) {
      throw ApiError.fromDioException(exception);
    } on FormatException catch (exception) {
      throw ApiError(message: exception.message);
    }
  }

  Future<TrilhaResponse> _trilha(
    Future<Response<Object?>> Function() request,
  ) async {
    try {
      final data = (await request()).data;
      if (data is! Map) {
        throw const ApiError(message: 'A resposta da trilha é inválida.');
      }
      return TrilhaResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (exception) {
      throw ApiError.fromDioException(exception);
    } on FormatException catch (exception) {
      throw ApiError(message: exception.message);
    }
  }
}
