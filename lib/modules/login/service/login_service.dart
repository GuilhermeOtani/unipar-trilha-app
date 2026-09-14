import 'package:dio/dio.dart';
import 'package:unipar_trilha_app/core/api_client.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/core/constants_api.dart';
import 'package:unipar_trilha_app/modules/login/dto/login_request.dart';
import 'package:unipar_trilha_app/modules/login/dto/login_response.dart';

abstract interface class LoginServiceContract {
  Future<LoginResponse> efetuarLogin(LoginRequest request);
}

class LoginService implements LoginServiceContract {
  LoginService({Dio? dio, AuthSession? authSession})
    : _dio = dio ?? ApiClient.shared.dio,
      _authSession = authSession ?? AuthSession.instance;

  final Dio _dio;
  final AuthSession _authSession;

  @override
  Future<LoginResponse> efetuarLogin(LoginRequest request) async {
    try {
      final response = await _dio.post<Object?>(
        ConstantsApi.login,
        data: request.toJson(),
      );
      final data = response.data;
      if (data is! Map) {
        throw const ApiError(message: 'A resposta do login é inválida.');
      }
      final login = LoginResponse.fromJson(Map<String, dynamic>.from(data));
      await _authSession.salvarLogin(login);
      return login;
    } on DioException catch (exception) {
      throw ApiError.fromDioException(
        exception,
        unauthorizedMessage: 'Login ou senha inválidos.',
      );
    } on FormatException catch (exception) {
      throw ApiError(message: exception.message);
    }
  }

  Future<void> logout() => _authSession.logout();
}
