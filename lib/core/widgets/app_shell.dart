import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/widgets/app_design_frame.dart';

/// Moldura de navegação: fundo do app e navegação inferior fixa.
///
/// É usada uma única vez por perfil (ex.: `AlunoNavegacaoPage`). O conteúdo
/// de cada tela fica em um `AppDesignPage` ou `AppPage` dentro de [body].
///
/// A navegação é desenhada no canvas de 360 dp do wireframe e escalada pelo
/// mesmo fator de `AppDesignScale`, acompanhando o conteúdo das telas.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.body, this.bottomNavigation});

  final Widget body;

  /// Normalmente um `AppBottomNavigation`.
  final Widget? bottomNavigation;

  /// Margens da navegação na tela 1: 9,5 dp nas laterais e 9 dp abaixo.
  static const navigationPadding = EdgeInsets.fromLTRB(9.5, 8, 9.5, 9);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final scale = AppDesignScale.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      body: body,
      bottomNavigationBar: bottomNavigation == null
          ? null
          : SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: 1,
                child: SizedBox(
                  width: AppDesignScale.designWidth * scale,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: SizedBox(
                      width: AppDesignScale.designWidth,
                      child: Padding(
                        padding: navigationPadding,
                        child: bottomNavigation,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
