import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/modules/trilha/models/trilha_edicao.dart';
import 'support/trilha_editor_fixtures.dart';

void main() {
  test('valida disciplina e limites exatos do backend', () {
    final edicao = TrilhaEdicao.fromDto(trilhaCompletaEditor);
    expect(edicao.validar({3}), isNull);
    expect(edicao.validar({7})!.etapa, EtapaTrilha.dados);
    edicao.titulo = 'x' * 161;
    expect(edicao.validar({3})!.mensagem, contains('160'));
    edicao.titulo = 'x' * 160;
    edicao.descricao = 'x' * 1001;
    expect(edicao.validar({3})!.mensagem, contains('1000'));
    edicao.descricao = '';
    edicao.modulos.first.licoes.first.desafios.first.feedback = 'x' * 2001;
    final erro = edicao.validar({3})!;
    expect(erro.etapa, EtapaTrilha.desafios);
    expect([erro.modulo, erro.licao, erro.desafio], [0, 0, 0]);
  });
  test(
    'múltiplas lições e desafios preservam ordem e identificam a pendência correta',
    () {
      final edicao = TrilhaEdicao.fromDto(trilhaCompletaEditor);
      final modulo = edicao.modulos.first;
      modulo.licoes.add(
        LicaoEdicao()
          ..titulo = 'Segunda'
          ..desafios.add(DesafioEdicao.fromDto(desafioEditor)),
      );
      modulo.licoes.last.desafios.add(
        DesafioEdicao.fromDto(desafioEditor)..opcoes.first.correta = false,
      );
      final erro = edicao.validar({3})!;
      expect([erro.modulo, erro.licao, erro.desafio], [0, 1, 1]);
      modulo.licoes.last.desafios.last.opcoes.last.correta = true;
      expect(edicao.validar({3}), isNull);
      expect(edicao.conteudo.modulos.first.licoes.last.ordem, 2);
      expect(edicao.conteudo.modulos.first.licoes.last.desafios.last.ordem, 2);
      final salva = edicao.assinatura;
      modulo.licoes.removeAt(0);
      expect(edicao.assinatura, isNot(salva));
      expect(edicao.conteudo.modulos.first.licoes.single.ordem, 1);
    },
  );
}
