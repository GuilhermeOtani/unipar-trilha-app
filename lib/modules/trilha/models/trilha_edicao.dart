import 'dart:convert';
import 'package:unipar_trilha_app/modules/trilha/dto/trilha_dto.dart';

enum EtapaTrilha { dados, modulos, licoes, desafios }

class PendenciaTrilha {
  const PendenciaTrilha(
    this.mensagem,
    this.etapa, {
    this.modulo,
    this.licao,
    this.desafio,
  });
  final String mensagem;
  final EtapaTrilha etapa;
  final int? modulo;
  final int? licao;
  final int? desafio;
}

/// Conteúdo em memória, compartilhado pelas páginas do cadastro.
class TrilhaEdicao {
  String titulo = '';
  String descricao = '';
  int? disciplinaId;
  final modulos = <ModuloEdicao>[];

  TrilhaEdicao();
  factory TrilhaEdicao.fromDto(TrilhaResponse dto) {
    return TrilhaEdicao()
      ..titulo = dto.titulo
      ..descricao = dto.descricao ?? ''
      ..disciplinaId = dto.disciplinaId
      ..modulos.addAll(dto.modulos.map(ModuloEdicao.fromDto));
  }

  TrilhaCreateRequest get basico => TrilhaCreateRequest(
    titulo: titulo.trim(),
    descricao: _opcional(descricao),
    disciplinaId: disciplinaId!,
  );
  TrilhaConteudoRequest get conteudo => TrilhaConteudoRequest(
    titulo: titulo.trim(),
    descricao: _opcional(descricao),
    disciplinaId: disciplinaId!,
    modulos: [for (var i = 0; i < modulos.length; i++) modulos[i].toDto(i + 1)],
  );

  // Inclui inclusive campos ainda incompletos para proteger a saída do editor.
  String get assinatura => jsonEncode({
    'titulo': titulo,
    'descricao': descricao,
    'disciplinaId': disciplinaId,
    'modulos': [
      for (var i = 0; i < modulos.length; i++) modulos[i].toDto(i + 1).toJson(),
    ],
  });

  PendenciaTrilha? validarDados(Set<int> disciplinas) {
    final erro =
        validarTexto(titulo, 'título da trilha', 160) ??
        validarTexto(descricao, 'descrição', 1000, obrigatorio: false);
    if (erro != null) return PendenciaTrilha(erro, EtapaTrilha.dados);
    if (!disciplinas.contains(disciplinaId)) {
      return const PendenciaTrilha(
        'Selecione uma disciplina vinculada ao professor.',
        EtapaTrilha.dados,
      );
    }
    return null;
  }

  PendenciaTrilha? validar(Set<int> disciplinas) {
    final dados = validarDados(disciplinas);
    if (dados != null) return dados;
    if (modulos.isEmpty) {
      return const PendenciaTrilha('Adicione um módulo.', EtapaTrilha.modulos);
    }
    for (var m = 0; m < modulos.length; m++) {
      final modulo = modulos[m];
      final erro = validarTexto(modulo.titulo, 'título do módulo', 160);
      if (erro != null) {
        return PendenciaTrilha(erro, EtapaTrilha.modulos, modulo: m);
      }
      if (modulo.licoes.isEmpty) {
        return PendenciaTrilha(
          'Adicione uma lição ao módulo ${m + 1}.',
          EtapaTrilha.licoes,
          modulo: m,
        );
      }
      for (var l = 0; l < modulo.licoes.length; l++) {
        final licao = modulo.licoes[l];
        final erro = licao.validar();
        if (erro != null) {
          return PendenciaTrilha(erro, EtapaTrilha.licoes, modulo: m, licao: l);
        }
        if (licao.desafios.isEmpty) {
          return PendenciaTrilha(
            'Adicione um desafio à lição ${l + 1}.',
            EtapaTrilha.desafios,
            modulo: m,
            licao: l,
          );
        }
        for (var d = 0; d < licao.desafios.length; d++) {
          final erro = licao.desafios[d].validar();
          if (erro != null) {
            return PendenciaTrilha(
              erro,
              EtapaTrilha.desafios,
              modulo: m,
              licao: l,
              desafio: d,
            );
          }
        }
      }
    }
    return null;
  }
}

class ModuloEdicao {
  String titulo = '';
  final licoes = <LicaoEdicao>[];
  ModuloEdicao();
  factory ModuloEdicao.fromDto(ModuloTrilhaDto dto) => ModuloEdicao()
    ..titulo = dto.titulo
    ..licoes.addAll(dto.licoes.map(LicaoEdicao.fromDto));
  ModuloTrilhaDto toDto(int ordem) => ModuloTrilhaDto(
    titulo: titulo.trim(),
    ordem: ordem,
    licoes: [for (var i = 0; i < licoes.length; i++) licoes[i].toDto(i + 1)],
  );
}

class LicaoEdicao {
  String titulo = '';
  String resumo = '';
  final desafios = <DesafioEdicao>[];
  LicaoEdicao();
  factory LicaoEdicao.fromDto(LicaoTrilhaDto dto) => LicaoEdicao()
    ..titulo = dto.titulo
    ..resumo = dto.resumo ?? ''
    ..desafios.addAll(dto.desafios.map(DesafioEdicao.fromDto));
  String? validar() =>
      validarTexto(titulo, 'título da lição', 160) ??
      validarTexto(resumo, 'resumo', 1000, obrigatorio: false);
  LicaoTrilhaDto toDto(int ordem) => LicaoTrilhaDto(
    titulo: titulo.trim(),
    resumo: _opcional(resumo),
    ordem: ordem,
    desafios: [
      for (var i = 0; i < desafios.length; i++) desafios[i].toDto(i + 1),
    ],
  );
}

class DesafioEdicao {
  String enunciado = '';
  String feedback = '';
  String dificuldade = 'FACIL';
  final opcoes = <OpcaoEdicao>[OpcaoEdicao()..correta = true, OpcaoEdicao()];
  DesafioEdicao();
  factory DesafioEdicao.fromDto(DesafioTrilhaDto dto) => DesafioEdicao()
    ..enunciado = dto.enunciado
    ..feedback = dto.explicacao
    ..dificuldade = dto.dificuldade
    ..opcoes.clear()
    ..opcoes.addAll(
      dto.opcoes.map(
        (o) => OpcaoEdicao()
          ..texto = o.texto
          ..correta = o.correta,
      ),
    );
  String? validar() {
    final erro =
        validarTexto(enunciado, 'enunciado', 2000) ??
        validarTexto(feedback, 'feedback', 2000);
    if (erro != null) return erro;
    if (!['FACIL', 'MEDIA', 'DIFICIL'].contains(dificuldade)) {
      return 'Selecione a dificuldade.';
    }
    if (opcoes.length < 2) return 'Adicione pelo menos duas opções.';
    for (var i = 0; i < opcoes.length; i++) {
      final erro = validarTexto(
        opcoes[i].texto,
        'texto da opção ${i + 1}',
        1000,
      );
      if (erro != null) return erro;
    }
    if (opcoes.where((o) => o.correta).length != 1) {
      return 'Marque exatamente uma resposta correta.';
    }
    return null;
  }

  DesafioTrilhaDto toDto(int ordem) => DesafioTrilhaDto(
    enunciado: enunciado.trim(),
    explicacao: feedback.trim(),
    dificuldade: dificuldade,
    ordem: ordem,
    opcoes: [
      for (var i = 0; i < opcoes.length; i++)
        OpcaoTrilhaDto(
          texto: opcoes[i].texto.trim(),
          correta: opcoes[i].correta,
          ordem: i + 1,
        ),
    ],
  );
}

class OpcaoEdicao {
  String texto = '';
  bool correta = false;
}

String? validarTexto(
  String texto,
  String campo,
  int limite, {
  bool obrigatorio = true,
}) {
  if (obrigatorio && texto.trim().isEmpty) return 'Preencha o $campo.';
  if (texto.length > limite) {
    return 'O campo $campo permite até $limite caracteres.';
  }
  return null;
}

String? _opcional(String texto) => texto.trim().isEmpty ? null : texto.trim();
