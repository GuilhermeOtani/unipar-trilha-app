import 'package:dio/dio.dart';
import 'package:unipar_trilha_app/core/api_client.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/constants_api.dart';
import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';
import 'package:unipar_trilha_app/modules/usuarios/dto/usuario_create_request.dart';

abstract interface class UsuarioServiceContract {
  Future<List<UsuarioResponse>> listar(PerfilUsuario perfil);
  Future<UsuarioResponse> criar(UsuarioCreateRequest request);
}

class UsuarioService implements UsuarioServiceContract {
  UsuarioService({Dio? dio}) : _dio = dio ?? ApiClient.shared.dio;

  final Dio _dio;

  @override
  Future<List<UsuarioResponse>> listar(PerfilUsuario perfil) async {
    try {
      final data = (await _dio.get<Object?>(
        ConstantsApi.usuarios,
        queryParameters: {'perfil': perfil.apiValue},
      )).data;
      if (data is! List) {
        throw const ApiError(message: 'A lista de usuários é inválida.');
      }
      return data
          .map((item) {
            if (item is! Map) throw const FormatException('Usuário inválido.');
            return UsuarioResponse.fromJson(Map<String, dynamic>.from(item));
          })
          .toList(growable: false);
    } on DioException catch (exception) {
      throw ApiError.fromDioException(exception);
    } on FormatException catch (exception) {
      throw ApiError(message: exception.message);
    }
  }

  @override
  Future<UsuarioResponse> criar(UsuarioCreateRequest request) async {
    try {
      final data = (await _dio.post<Object?>(
        ConstantsApi.usuarios,
        data: request.toJson(),
      )).data;
      if (data is! Map) {
        throw const ApiError(message: 'A resposta do usuário é inválida.');
      }
      return UsuarioResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (exception) {
      throw ApiError.fromDioException(exception);
    } on FormatException catch (exception) {
      throw ApiError(message: exception.message);
    }
  }
}
