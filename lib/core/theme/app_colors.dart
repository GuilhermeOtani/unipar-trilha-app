import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_palette.dart';

/// Tokens semânticos de cor, expostos pelo `ThemeData` como extensão.
///
/// Uso: `final colors = AppColors.of(context);`
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.backgroundApp,
    required this.surfaceDefault,
    required this.surfaceBrand,
    required this.surfaceHeader,
    required this.surfaceHeaderShade,
    required this.surfaceInfo,
    required this.surfaceSelected,
    required this.surfaceProfile,
    required this.surfaceBubble,
    required this.onBubble,
    required this.badgeSurface,
    required this.shadowStrong,
    required this.actionPrimary,
    required this.actionPrimaryPressed,
    required this.actionSecondary,
    required this.actionInfo,
    required this.actionConfirm,
    required this.onAction,
    required this.link,
    required this.linkEmphasis,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textInfoMuted,
    required this.textAccent,
    required this.textOnSurface,
    required this.iconDefault,
    required this.iconActive,
    required this.notification,
    required this.borderDefault,
    required this.borderSubtle,
    required this.borderCard,
    required this.borderGoal,
    required this.borderInfo,
    required this.borderFocus,
    required this.avatarBorder,
    required this.progressTrack,
    required this.progressFill,
    required this.progressTrail,
    required this.scrollTrack,
    required this.scrollThumb,
    required this.pathNode,
    required this.pathNodeCurrent,
    required this.pathNodeRing,
    required this.pathConnector,
    required this.pathDots,
    required this.feedbackSuccessSurface,
    required this.feedbackSuccessBorder,
    required this.feedbackSuccessText,
    required this.feedbackSuccessTitle,
    required this.feedbackSuccessIcon,
    required this.feedbackDangerSurface,
    required this.feedbackDangerBorder,
    required this.feedbackDangerText,
    required this.codeText,
    required this.codeHighlight,
    required this.trailBlueSurface,
    required this.trailBlueAction,
    required this.trailBlueTrack,
    required this.trailBlueIcon,
    required this.trailPurpleSurface,
    required this.trailPurpleAction,
    required this.trailPurpleTrack,
    required this.trailPurpleIcon,
    required this.trailCyanSurface,
    required this.trailCyanAction,
    required this.trailCyanTrack,
    required this.trailCyanIcon,
    required this.trailCyanIconBox,
    required this.trailCyanIconBoxBorder,
    required this.brandSpring,
    required this.brandXampp,
    required this.brandJs,
    required this.brandHibernate,
    required this.onBrand,
    required this.onBrandJs,
  });

  /// Tema escuro Unipar Trail Code, único tema do MVP.
  static const dark = AppColors(
    backgroundApp: AppPalette.navy950,
    surfaceDefault: AppPalette.navy900,
    surfaceBrand: AppPalette.indigo,
    surfaceHeader: AppPalette.plumDeep,
    surfaceHeaderShade: AppPalette.plumNight,
    surfaceInfo: AppPalette.ocean,
    surfaceSelected: AppPalette.selectedSurface,
    surfaceProfile: AppPalette.cobalt,
    surfaceBubble: AppPalette.textLight,
    onBubble: AppPalette.navy950,
    badgeSurface: AppPalette.cobalt,
    shadowStrong: AppPalette.black,
    actionPrimary: AppPalette.greenLight,
    actionPrimaryPressed: AppPalette.green,
    actionSecondary: AppPalette.navActive,
    actionInfo: AppPalette.cyan,
    actionConfirm: AppPalette.progressFill,
    onAction: AppPalette.navy950,
    link: AppPalette.navActive,
    linkEmphasis: AppPalette.iris,
    textPrimary: AppPalette.textLight,
    textSecondary: AppPalette.textSoft,
    textMuted: AppPalette.dusk,
    textInfoMuted: AppPalette.haze,
    textAccent: AppPalette.mauve,
    textOnSurface: AppPalette.white,
    iconDefault: AppPalette.textSoft,
    iconActive: AppPalette.navActive,
    notification: AppPalette.notification,
    borderDefault: AppPalette.violetBorder,
    borderSubtle: AppPalette.indigo,
    borderCard: AppPalette.slate,
    borderGoal: AppPalette.denim,
    borderInfo: AppPalette.abyss,
    borderFocus: AppPalette.navActive,
    avatarBorder: AppPalette.lavender,
    progressTrack: AppPalette.track,
    progressFill: AppPalette.progressFill,
    progressTrail: AppPalette.lime,
    scrollTrack: AppPalette.scrollTrack,
    scrollThumb: AppPalette.scrollThumb,
    pathNode: AppPalette.violetBorder,
    pathNodeCurrent: AppPalette.textLight,
    pathNodeRing: AppPalette.navActive,
    pathConnector: AppPalette.textSoft,
    pathDots: AppPalette.pewter,
    feedbackSuccessSurface: AppPalette.successSurface,
    feedbackSuccessBorder: AppPalette.successBorder,
    feedbackSuccessText: AppPalette.greenLight,
    feedbackSuccessTitle: AppPalette.mint,
    feedbackSuccessIcon: AppPalette.statusSuccess,
    feedbackDangerSurface: AppPalette.dangerSurface,
    feedbackDangerBorder: AppPalette.dangerBorder,
    feedbackDangerText: AppPalette.statusError,
    codeText: AppPalette.cyan,
    codeHighlight: AppPalette.codeAqua,
    trailBlueSurface: AppPalette.royal,
    trailBlueAction: AppPalette.lime,
    trailBlueTrack: AppPalette.indigoDeep,
    trailBlueIcon: AppPalette.aqua,
    trailPurpleSurface: AppPalette.purple,
    trailPurpleAction: AppPalette.lilac,
    trailPurpleTrack: AppPalette.track,
    trailPurpleIcon: AppPalette.orchid,
    trailCyanSurface: AppPalette.steel,
    trailCyanAction: AppPalette.sky,
    trailCyanTrack: AppPalette.track,
    trailCyanIcon: AppPalette.textLight,
    trailCyanIconBox: AppPalette.azure,
    trailCyanIconBoxBorder: AppPalette.azureLight,
    brandSpring: AppPalette.brandSpring,
    brandXampp: AppPalette.brandXampp,
    brandJs: AppPalette.brandJs,
    brandHibernate: AppPalette.brandHibernate,
    onBrand: AppPalette.white,
    onBrandJs: AppPalette.black,
  );

  /// Tokens do tema atual; usa [dark] quando a extensão não foi registrada.
  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ?? dark;
  }

  // Fundo e superfícies
  /// Fundo principal do app.
  final Color backgroundApp;

  /// Cards, opções de quiz e navegação.
  final Color surfaceDefault;

  /// Superfície elevada de marca.
  final Color surfaceBrand;

  /// Extremidades do cabeçalho do aluno.
  final Color surfaceHeader;

  /// Centro escurecido do cabeçalho do aluno.
  final Color surfaceHeaderShade;

  /// Card da próxima lição e métricas.
  final Color surfaceInfo;

  /// Item selecionado e banner da trilha.
  final Color surfaceSelected;

  /// Card de resumo do perfil (tela 7).
  final Color surfaceProfile;

  /// Balão de fala da mascote.
  final Color surfaceBubble;

  /// Texto sobre o balão de fala.
  final Color onBubble;

  /// Contadores sobre ilustrações (sequência, +1).
  final Color badgeSurface;

  /// Base de sombras (nós do caminho, foto do perfil).
  final Color shadowStrong;

  // Ações
  /// Botão primário e seta de avanço.
  final Color actionPrimary;

  /// Botão primário pressionado.
  final Color actionPrimaryPressed;

  /// Botão secundário.
  final Color actionSecondary;

  /// Botão informativo e rótulos de métricas.
  final Color actionInfo;

  /// Botão de envio de resposta (tela 4).
  final Color actionConfirm;

  /// Texto e ícone sobre ações claras.
  final Color onAction;

  /// Ações textuais, como a volta para a trilha.
  final Color link;

  /// Ação textual de seção, como ver todas.
  final Color linkEmphasis;

  // Texto
  /// Texto principal.
  final Color textPrimary;

  /// Legendas e metadados.
  final Color textSecondary;

  /// Percentual da meta diária e contador de questões.
  final Color textMuted;

  /// Legenda sobre superfícies informativas.
  final Color textInfoMuted;

  /// RA e instruções auxiliares.
  final Color textAccent;

  /// Títulos sobre cards coloridos.
  final Color textOnSurface;

  // Navegação e ícones
  /// Ícone inativo.
  final Color iconDefault;

  /// Ícone ativo.
  final Color iconActive;

  /// Badge de notificação.
  final Color notification;

  // Bordas, progresso e rolagem
  /// Borda de opções e campos.
  final Color borderDefault;

  /// Divisores e contornos discretos.
  final Color borderSubtle;

  /// Contorno da navegação e dos cards da visão geral.
  final Color borderCard;

  /// Contorno da meta diária.
  final Color borderGoal;

  /// Contorno do card de métricas (tela 7).
  final Color borderInfo;

  /// Foco e seleção.
  final Color borderFocus;

  /// Contorno da foto do aluno.
  final Color avatarBorder;

  /// Trilho de barras e anéis.
  final Color progressTrack;

  /// Preenchimento da meta diária.
  final Color progressFill;

  /// Preenchimento do progresso da trilha.
  final Color progressTrail;

  /// Trilho das barras de rolagem visíveis.
  final Color scrollTrack;

  /// Indicador das barras de rolagem visíveis.
  final Color scrollThumb;

  // Caminho da trilha
  /// Nó de lição.
  final Color pathNode;

  /// Nó da lição atual.
  final Color pathNodeCurrent;

  /// Contorno e balão da lição atual.
  final Color pathNodeRing;

  /// Conectores entre nós.
  final Color pathConnector;

  /// Pontos entre a lição e o baú.
  final Color pathDots;

  // Feedback
  /// Fundo de resposta correta.
  final Color feedbackSuccessSurface;

  /// Borda de resposta correta.
  final Color feedbackSuccessBorder;

  /// Texto positivo secundário.
  final Color feedbackSuccessText;

  /// Título do acerto e rótulo Correta.
  final Color feedbackSuccessTitle;

  /// Ícone de resposta correta.
  final Color feedbackSuccessIcon;

  /// Fundo de resposta incorreta.
  final Color feedbackDangerSurface;

  /// Borda de resposta incorreta.
  final Color feedbackDangerBorder;

  /// Título e ícone de resposta incorreta.
  final Color feedbackDangerText;

  /// Trechos de código sem caixa.
  final Color codeText;

  /// Código dentro da caixa do feedback de erro.
  final Color codeHighlight;

  // Tons de TrailCard
  /// Card de trilha azul.
  final Color trailBlueSurface;

  /// Botão e progresso do card azul.
  final Color trailBlueAction;

  /// Trilho do progresso do card azul.
  final Color trailBlueTrack;

  /// Ícone do curso no card azul.
  final Color trailBlueIcon;

  /// Card de trilha roxo.
  final Color trailPurpleSurface;

  /// Botão do card roxo.
  final Color trailPurpleAction;

  /// Trilho do progresso do card roxo.
  final Color trailPurpleTrack;

  /// Ícone do curso no card roxo e no banner.
  final Color trailPurpleIcon;

  /// Card de trilha ciano.
  final Color trailCyanSurface;

  /// Botão do card ciano.
  final Color trailCyanAction;

  /// Trilho do progresso do card ciano.
  final Color trailCyanTrack;

  /// Ícone do curso no card ciano.
  final Color trailCyanIcon;

  /// Caixa sólida do ícone no card ciano.
  final Color trailCyanIconBox;

  /// Contorno da caixa do ícone no card ciano.
  final Color trailCyanIconBoxBorder;

  // Marcas dos cursos
  /// Spring.
  final Color brandSpring;

  /// XAMPP.
  final Color brandXampp;

  /// JavaScript.
  final Color brandJs;

  /// Hibernate.
  final Color brandHibernate;

  /// Glifo sobre cores de marca.
  final Color onBrand;

  /// Texto sobre o amarelo do JavaScript.
  final Color onBrandJs;

  @override
  AppColors copyWith({
    Color? backgroundApp,
    Color? surfaceDefault,
    Color? surfaceBrand,
    Color? surfaceHeader,
    Color? surfaceHeaderShade,
    Color? surfaceInfo,
    Color? surfaceSelected,
    Color? surfaceProfile,
    Color? surfaceBubble,
    Color? onBubble,
    Color? badgeSurface,
    Color? shadowStrong,
    Color? actionPrimary,
    Color? actionPrimaryPressed,
    Color? actionSecondary,
    Color? actionInfo,
    Color? actionConfirm,
    Color? onAction,
    Color? link,
    Color? linkEmphasis,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textInfoMuted,
    Color? textAccent,
    Color? textOnSurface,
    Color? iconDefault,
    Color? iconActive,
    Color? notification,
    Color? borderDefault,
    Color? borderSubtle,
    Color? borderCard,
    Color? borderGoal,
    Color? borderInfo,
    Color? borderFocus,
    Color? avatarBorder,
    Color? progressTrack,
    Color? progressFill,
    Color? progressTrail,
    Color? scrollTrack,
    Color? scrollThumb,
    Color? pathNode,
    Color? pathNodeCurrent,
    Color? pathNodeRing,
    Color? pathConnector,
    Color? pathDots,
    Color? feedbackSuccessSurface,
    Color? feedbackSuccessBorder,
    Color? feedbackSuccessText,
    Color? feedbackSuccessTitle,
    Color? feedbackSuccessIcon,
    Color? feedbackDangerSurface,
    Color? feedbackDangerBorder,
    Color? feedbackDangerText,
    Color? codeText,
    Color? codeHighlight,
    Color? trailBlueSurface,
    Color? trailBlueAction,
    Color? trailBlueTrack,
    Color? trailBlueIcon,
    Color? trailPurpleSurface,
    Color? trailPurpleAction,
    Color? trailPurpleTrack,
    Color? trailPurpleIcon,
    Color? trailCyanSurface,
    Color? trailCyanAction,
    Color? trailCyanTrack,
    Color? trailCyanIcon,
    Color? trailCyanIconBox,
    Color? trailCyanIconBoxBorder,
    Color? brandSpring,
    Color? brandXampp,
    Color? brandJs,
    Color? brandHibernate,
    Color? onBrand,
    Color? onBrandJs,
  }) {
    return AppColors(
      backgroundApp: backgroundApp ?? this.backgroundApp,
      surfaceDefault: surfaceDefault ?? this.surfaceDefault,
      surfaceBrand: surfaceBrand ?? this.surfaceBrand,
      surfaceHeader: surfaceHeader ?? this.surfaceHeader,
      surfaceHeaderShade: surfaceHeaderShade ?? this.surfaceHeaderShade,
      surfaceInfo: surfaceInfo ?? this.surfaceInfo,
      surfaceSelected: surfaceSelected ?? this.surfaceSelected,
      surfaceProfile: surfaceProfile ?? this.surfaceProfile,
      surfaceBubble: surfaceBubble ?? this.surfaceBubble,
      onBubble: onBubble ?? this.onBubble,
      badgeSurface: badgeSurface ?? this.badgeSurface,
      shadowStrong: shadowStrong ?? this.shadowStrong,
      actionPrimary: actionPrimary ?? this.actionPrimary,
      actionPrimaryPressed: actionPrimaryPressed ?? this.actionPrimaryPressed,
      actionSecondary: actionSecondary ?? this.actionSecondary,
      actionInfo: actionInfo ?? this.actionInfo,
      actionConfirm: actionConfirm ?? this.actionConfirm,
      onAction: onAction ?? this.onAction,
      link: link ?? this.link,
      linkEmphasis: linkEmphasis ?? this.linkEmphasis,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textInfoMuted: textInfoMuted ?? this.textInfoMuted,
      textAccent: textAccent ?? this.textAccent,
      textOnSurface: textOnSurface ?? this.textOnSurface,
      iconDefault: iconDefault ?? this.iconDefault,
      iconActive: iconActive ?? this.iconActive,
      notification: notification ?? this.notification,
      borderDefault: borderDefault ?? this.borderDefault,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderCard: borderCard ?? this.borderCard,
      borderGoal: borderGoal ?? this.borderGoal,
      borderInfo: borderInfo ?? this.borderInfo,
      borderFocus: borderFocus ?? this.borderFocus,
      avatarBorder: avatarBorder ?? this.avatarBorder,
      progressTrack: progressTrack ?? this.progressTrack,
      progressFill: progressFill ?? this.progressFill,
      progressTrail: progressTrail ?? this.progressTrail,
      scrollTrack: scrollTrack ?? this.scrollTrack,
      scrollThumb: scrollThumb ?? this.scrollThumb,
      pathNode: pathNode ?? this.pathNode,
      pathNodeCurrent: pathNodeCurrent ?? this.pathNodeCurrent,
      pathNodeRing: pathNodeRing ?? this.pathNodeRing,
      pathConnector: pathConnector ?? this.pathConnector,
      pathDots: pathDots ?? this.pathDots,
      feedbackSuccessSurface:
          feedbackSuccessSurface ?? this.feedbackSuccessSurface,
      feedbackSuccessBorder:
          feedbackSuccessBorder ?? this.feedbackSuccessBorder,
      feedbackSuccessText: feedbackSuccessText ?? this.feedbackSuccessText,
      feedbackSuccessTitle: feedbackSuccessTitle ?? this.feedbackSuccessTitle,
      feedbackSuccessIcon: feedbackSuccessIcon ?? this.feedbackSuccessIcon,
      feedbackDangerSurface:
          feedbackDangerSurface ?? this.feedbackDangerSurface,
      feedbackDangerBorder: feedbackDangerBorder ?? this.feedbackDangerBorder,
      feedbackDangerText: feedbackDangerText ?? this.feedbackDangerText,
      codeText: codeText ?? this.codeText,
      codeHighlight: codeHighlight ?? this.codeHighlight,
      trailBlueSurface: trailBlueSurface ?? this.trailBlueSurface,
      trailBlueAction: trailBlueAction ?? this.trailBlueAction,
      trailBlueTrack: trailBlueTrack ?? this.trailBlueTrack,
      trailBlueIcon: trailBlueIcon ?? this.trailBlueIcon,
      trailPurpleSurface: trailPurpleSurface ?? this.trailPurpleSurface,
      trailPurpleAction: trailPurpleAction ?? this.trailPurpleAction,
      trailPurpleTrack: trailPurpleTrack ?? this.trailPurpleTrack,
      trailPurpleIcon: trailPurpleIcon ?? this.trailPurpleIcon,
      trailCyanSurface: trailCyanSurface ?? this.trailCyanSurface,
      trailCyanAction: trailCyanAction ?? this.trailCyanAction,
      trailCyanTrack: trailCyanTrack ?? this.trailCyanTrack,
      trailCyanIcon: trailCyanIcon ?? this.trailCyanIcon,
      trailCyanIconBox: trailCyanIconBox ?? this.trailCyanIconBox,
      trailCyanIconBoxBorder:
          trailCyanIconBoxBorder ?? this.trailCyanIconBoxBorder,
      brandSpring: brandSpring ?? this.brandSpring,
      brandXampp: brandXampp ?? this.brandXampp,
      brandJs: brandJs ?? this.brandJs,
      brandHibernate: brandHibernate ?? this.brandHibernate,
      onBrand: onBrand ?? this.onBrand,
      onBrandJs: onBrandJs ?? this.onBrandJs,
    );
  }

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      backgroundApp: Color.lerp(backgroundApp, other.backgroundApp, t)!,
      surfaceDefault: Color.lerp(surfaceDefault, other.surfaceDefault, t)!,
      surfaceBrand: Color.lerp(surfaceBrand, other.surfaceBrand, t)!,
      surfaceHeader: Color.lerp(surfaceHeader, other.surfaceHeader, t)!,
      surfaceHeaderShade: Color.lerp(
        surfaceHeaderShade,
        other.surfaceHeaderShade,
        t,
      )!,
      surfaceInfo: Color.lerp(surfaceInfo, other.surfaceInfo, t)!,
      surfaceSelected: Color.lerp(surfaceSelected, other.surfaceSelected, t)!,
      surfaceProfile: Color.lerp(surfaceProfile, other.surfaceProfile, t)!,
      surfaceBubble: Color.lerp(surfaceBubble, other.surfaceBubble, t)!,
      onBubble: Color.lerp(onBubble, other.onBubble, t)!,
      badgeSurface: Color.lerp(badgeSurface, other.badgeSurface, t)!,
      shadowStrong: Color.lerp(shadowStrong, other.shadowStrong, t)!,
      actionPrimary: Color.lerp(actionPrimary, other.actionPrimary, t)!,
      actionPrimaryPressed: Color.lerp(
        actionPrimaryPressed,
        other.actionPrimaryPressed,
        t,
      )!,
      actionSecondary: Color.lerp(actionSecondary, other.actionSecondary, t)!,
      actionInfo: Color.lerp(actionInfo, other.actionInfo, t)!,
      actionConfirm: Color.lerp(actionConfirm, other.actionConfirm, t)!,
      onAction: Color.lerp(onAction, other.onAction, t)!,
      link: Color.lerp(link, other.link, t)!,
      linkEmphasis: Color.lerp(linkEmphasis, other.linkEmphasis, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textInfoMuted: Color.lerp(textInfoMuted, other.textInfoMuted, t)!,
      textAccent: Color.lerp(textAccent, other.textAccent, t)!,
      textOnSurface: Color.lerp(textOnSurface, other.textOnSurface, t)!,
      iconDefault: Color.lerp(iconDefault, other.iconDefault, t)!,
      iconActive: Color.lerp(iconActive, other.iconActive, t)!,
      notification: Color.lerp(notification, other.notification, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderCard: Color.lerp(borderCard, other.borderCard, t)!,
      borderGoal: Color.lerp(borderGoal, other.borderGoal, t)!,
      borderInfo: Color.lerp(borderInfo, other.borderInfo, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      avatarBorder: Color.lerp(avatarBorder, other.avatarBorder, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      progressFill: Color.lerp(progressFill, other.progressFill, t)!,
      progressTrail: Color.lerp(progressTrail, other.progressTrail, t)!,
      scrollTrack: Color.lerp(scrollTrack, other.scrollTrack, t)!,
      scrollThumb: Color.lerp(scrollThumb, other.scrollThumb, t)!,
      pathNode: Color.lerp(pathNode, other.pathNode, t)!,
      pathNodeCurrent: Color.lerp(pathNodeCurrent, other.pathNodeCurrent, t)!,
      pathNodeRing: Color.lerp(pathNodeRing, other.pathNodeRing, t)!,
      pathConnector: Color.lerp(pathConnector, other.pathConnector, t)!,
      pathDots: Color.lerp(pathDots, other.pathDots, t)!,
      feedbackSuccessSurface: Color.lerp(
        feedbackSuccessSurface,
        other.feedbackSuccessSurface,
        t,
      )!,
      feedbackSuccessBorder: Color.lerp(
        feedbackSuccessBorder,
        other.feedbackSuccessBorder,
        t,
      )!,
      feedbackSuccessText: Color.lerp(
        feedbackSuccessText,
        other.feedbackSuccessText,
        t,
      )!,
      feedbackSuccessTitle: Color.lerp(
        feedbackSuccessTitle,
        other.feedbackSuccessTitle,
        t,
      )!,
      feedbackSuccessIcon: Color.lerp(
        feedbackSuccessIcon,
        other.feedbackSuccessIcon,
        t,
      )!,
      feedbackDangerSurface: Color.lerp(
        feedbackDangerSurface,
        other.feedbackDangerSurface,
        t,
      )!,
      feedbackDangerBorder: Color.lerp(
        feedbackDangerBorder,
        other.feedbackDangerBorder,
        t,
      )!,
      feedbackDangerText: Color.lerp(
        feedbackDangerText,
        other.feedbackDangerText,
        t,
      )!,
      codeText: Color.lerp(codeText, other.codeText, t)!,
      codeHighlight: Color.lerp(codeHighlight, other.codeHighlight, t)!,
      trailBlueSurface: Color.lerp(
        trailBlueSurface,
        other.trailBlueSurface,
        t,
      )!,
      trailBlueAction: Color.lerp(trailBlueAction, other.trailBlueAction, t)!,
      trailBlueTrack: Color.lerp(trailBlueTrack, other.trailBlueTrack, t)!,
      trailBlueIcon: Color.lerp(trailBlueIcon, other.trailBlueIcon, t)!,
      trailPurpleSurface: Color.lerp(
        trailPurpleSurface,
        other.trailPurpleSurface,
        t,
      )!,
      trailPurpleAction: Color.lerp(
        trailPurpleAction,
        other.trailPurpleAction,
        t,
      )!,
      trailPurpleTrack: Color.lerp(
        trailPurpleTrack,
        other.trailPurpleTrack,
        t,
      )!,
      trailPurpleIcon: Color.lerp(trailPurpleIcon, other.trailPurpleIcon, t)!,
      trailCyanSurface: Color.lerp(
        trailCyanSurface,
        other.trailCyanSurface,
        t,
      )!,
      trailCyanAction: Color.lerp(trailCyanAction, other.trailCyanAction, t)!,
      trailCyanTrack: Color.lerp(trailCyanTrack, other.trailCyanTrack, t)!,
      trailCyanIcon: Color.lerp(trailCyanIcon, other.trailCyanIcon, t)!,
      trailCyanIconBox: Color.lerp(
        trailCyanIconBox,
        other.trailCyanIconBox,
        t,
      )!,
      trailCyanIconBoxBorder: Color.lerp(
        trailCyanIconBoxBorder,
        other.trailCyanIconBoxBorder,
        t,
      )!,
      brandSpring: Color.lerp(brandSpring, other.brandSpring, t)!,
      brandXampp: Color.lerp(brandXampp, other.brandXampp, t)!,
      brandJs: Color.lerp(brandJs, other.brandJs, t)!,
      brandHibernate: Color.lerp(brandHibernate, other.brandHibernate, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      onBrandJs: Color.lerp(onBrandJs, other.onBrandJs, t)!,
    );
  }
}
