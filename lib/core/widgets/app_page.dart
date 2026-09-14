import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_breakpoints.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';

/// Área de conteúdo de uma tela: safe area superior, margens, largura máxima
/// centralizada e rolagem.
///
/// Toda página de módulo retorna um `AppPage`. A navegação inferior não faz
/// parte dele; ela pertence ao `AppShell` do perfil.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.body,
    this.header,
    this.scrollable = true,
    this.topPadding = AppSpacing.md,
    this.padding,
    this.maxContentWidth = AppBreakpoints.maxContentWidth,
  });

  final Widget body;

  /// Normalmente `AlunoHeader`; rola junto com o conteúdo.
  final Widget? header;

  /// Use `false` quando [body] já possuir rolagem própria.
  final bool scrollable;
  final double topPadding;

  /// Substitui as margens responsivas quando a tela reproduz as medidas
  /// exatas de um wireframe (cada bloco define a própria margem lateral).
  final EdgeInsets? padding;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final horizontal = AppBreakpoints.horizontalPadding(
      MediaQuery.sizeOf(context).width,
    );
    final contentPadding =
        padding ??
        EdgeInsets.fromLTRB(horizontal, topPadding, horizontal, AppSpacing.lg);

    Widget constrained(Widget child) => Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );

    final children = <Widget>[
      if (header != null) ...[header!, const SizedBox(height: AppSpacing.lg)],
      if (scrollable) body else Expanded(child: body),
    ];
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );

    return Material(
      color: colors.backgroundApp,
      child: SafeArea(
        bottom: false,
        child: scrollable
            ? SingleChildScrollView(
                padding: contentPadding,
                child: constrained(column),
              )
            : Padding(padding: contentPadding, child: constrained(column)),
      ),
    );
  }
}
