final class ConstantsApi {
  ConstantsApi._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String health = '/actuator/health';
  static const String login = '/auth/login';
  static const String usuarioAtual = '/usuarios/me';
  static const String alunoDistribuicoes = '/aluno/distribuicoes';

  static String alunoIniciarSessao(int distribuicaoId) =>
      '/aluno/distribuicoes/$distribuicaoId/sessoes';
  static String alunoSessao(int sessaoId) => '/aluno/sessoes/$sessaoId';
  static String alunoRespostas(int sessaoId) =>
      '/aluno/sessoes/$sessaoId/respostas';
}
