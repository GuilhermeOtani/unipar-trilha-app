import 'dart:async';

import 'package:unipar_trilha_app/modules/login/dto/login_request.dart';
import 'package:unipar_trilha_app/modules/login/dto/login_response.dart';
import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';
import 'package:unipar_trilha_app/modules/login/service/login_service.dart';

typedef LoginHandler = FutureOr<LoginResponse> Function(LoginRequest request);

class FakeLoginService implements LoginServiceContract {
  FakeLoginService({LoginHandler? handler})
    : handler = handler ?? ((_) => professorLogin);

  final LoginHandler handler;
  final List<LoginRequest> requests = [];

  @override
  Future<LoginResponse> efetuarLogin(LoginRequest request) async {
    requests.add(request);
    return handler(request);
  }
}

const professorLogin = LoginResponse(
  accessToken: 'jwt-professor',
  tokenType: 'Bearer',
  expiresInMinutes: 480,
  usuarioId: 2,
  login: 'professor',
  nome: 'Professor Demo',
  perfil: PerfilUsuario.professor,
);
