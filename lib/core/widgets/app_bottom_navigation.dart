import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/widgets/app_icon.dart';

class AppNavigationDestination {
  const AppNavigationDestination({
    required this.icon,
    required this.label,
    this.iconSize = 30,
  });

  /// Caminho de um ícone de `AppIcons`.
  final String icon;

  /// Nome lido por leitores de tela e exibido no tooltip.
  final String label;

  /// Lado da caixa do ícone. Os ícones do kit têm proporções diferentes;
  /// o valor de cada destino reproduz o tamanho visto no wireframe.
  final double iconSize;
}

/// Navegação inferior somente com ícones, como nas telas de referência.
///
/// Medidas da tela 1: 55 dp de altura, raio 22 dp e contorno `borderCard`.
/// Estados: padrão (ícone neutro), ativo (ícone destacado e `selected` na
/// semântica) e pressionado (realce do `InkWell`).
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
  }) : assert(destinations.length >= 2);

  static const double height = 55;
  static const double radius = 22;

  final List<AppNavigationDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceDefault,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: colors.borderCard),
      ),
      child: Row(
        children: [
          for (var index = 0; index < destinations.length; index++)
            Expanded(
              child: _NavigationItem(
                destination: destinations[index],
                selected: index == currentIndex,
                onTap: () => onSelected(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppNavigationDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = selected ? colors.iconActive : colors.iconDefault;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      onTap: onTap,
      excludeSemantics: true,
      child: Tooltip(
        message: destination.label,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppBottomNavigation.radius),
            splashColor: colors.iconActive.withValues(alpha: 0.16),
            highlightColor: colors.iconActive.withValues(alpha: 0.10),
            child: Center(
              child: AppIcon(
                destination.icon,
                size: destination.iconSize,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
