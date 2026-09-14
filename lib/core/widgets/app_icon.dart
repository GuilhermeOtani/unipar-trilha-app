import 'package:flutter/widgets.dart';

/// Ícone PNG monocromático tingido por token.
///
/// Equivale ao uso de máscara com `currentColor` do kit web: a silhueta vem do
/// arquivo e a cor vem de [color] ou do `IconTheme` atual.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.asset, {
    super.key,
    this.size = 24,
    this.color,
    this.semanticLabel,
  });

  final String asset;
  final double size;
  final Color? color;

  /// Deixe nulo quando o ícone for decorativo e já houver texto equivalente.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return ImageIcon(
      AssetImage(asset),
      size: size,
      color: color ?? IconTheme.of(context).color,
      semanticLabel: semanticLabel,
    );
  }
}
