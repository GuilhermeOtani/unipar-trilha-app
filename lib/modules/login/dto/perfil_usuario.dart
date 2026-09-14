enum PerfilUsuario {
  administrador('ADMINISTRADOR'),
  professor('PROFESSOR'),
  aluno('ALUNO');

  const PerfilUsuario(this.apiValue);

  final String apiValue;

  String get label => switch (this) {
    PerfilUsuario.administrador => 'Administrador',
    PerfilUsuario.professor => 'Professor',
    PerfilUsuario.aluno => 'Aluno',
  };

  static PerfilUsuario fromJson(Object? value) {
    return PerfilUsuario.values.firstWhere(
      (perfil) => perfil.apiValue == value,
      orElse: () => throw FormatException('Perfil de usuário inválido: $value'),
    );
  }
}
