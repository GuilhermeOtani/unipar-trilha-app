/// Caminhos dos ativos de produção registrados no `pubspec.yaml`.
///
/// Ícones em [AppIcons] são silhuetas: a cor vem do token aplicado por
/// `AppIcon`. Apenas os itens em `icons/colored` mantêm as cores originais.
abstract final class AppIcons {
  static const _base = 'assets/images/icons';

  static const arrowBack = '$_base/arrow-back.png';
  static const arrowRight = '$_base/arrow-right.png';
  static const home = '$_base/home.png';
  static const learningBook = '$_base/learning-book.png';
  static const lock = '$_base/lock.png';
  static const menu = '$_base/menu.png';
  static const notificationBell = '$_base/notification-bell.png';
  static const play = '$_base/play.png';
  static const ranking = '$_base/ranking.png';
  static const statusError = '$_base/status-error.png';

  static const statusSuccess = '$_base/colored/status-success.png';
  static const diamond = '$_base/colored/diamond.png';
}

abstract final class AppIllustrations {
  static const _base = 'assets/images/illustrations';

  static const cabbage = '$_base/cabbage.png';
  static const codingLaptop = '$_base/coding-laptop.png';
  static const flame = '$_base/flame.png';
  static const treasureChest = '$_base/treasure-chest.png';
  static const speechBubble = 'assets/images/decorative/speech-bubble.png';
}

/// Poses e expressões da iguana (página 10 do Canva).
enum MascotPose {
  phone('iguana-phone', 163 / 216),
  front('iguana-front', 62 / 107),
  side('iguana-side', 65 / 103),
  back('iguana-back', 55 / 105),
  neutral('iguana-expression-neutral', 78 / 58),
  smile('iguana-expression-smile', 79 / 58),
  speaking('iguana-expression-speaking', 89 / 66);

  const MascotPose(this._file, this.aspectRatio);

  final String _file;

  /// Largura ÷ altura do arquivo original, usada para preservar a proporção.
  final double aspectRatio;

  String get asset => 'assets/images/mascot/$_file.png';
}
