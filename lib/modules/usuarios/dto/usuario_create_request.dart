import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';

class UsuarioCreateRequest {
  const UsuarioCreateRequest({
    required this.login,
    required this.nome,
    required this.senha,
    required this.perfil,
  });

  final String login;
  final String nome;
  final String senha;
  final PerfilUsuario perfil;

  Map<String, dynamic> toJson() => {
    'login': login,
    'nome': nome,
    'senha': senha,
    'perfil': perfil.apiValue,
  };
}
