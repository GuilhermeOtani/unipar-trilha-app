import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.content, this.showHero = true});

  final Widget content;
  final bool showHero;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.backgroundApp, colors.surfaceHeaderShade],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 800;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: desktop ? 40 : 20,
                  vertical: desktop ? 32 : 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (desktop ? 64 : 40),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: desktop
                          ? _DesktopLayout(content: content, showHero: showHero)
                          : _MobileLayout(content: content, showHero: showHero),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.content, required this.showHero});

  final Widget content;
  final bool showHero;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showHero) ...[
          const Expanded(child: _AuthHero(compact: false)),
          const SizedBox(width: 64),
        ],
        SizedBox(width: 440, child: _AuthCard(child: content)),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.content, required this.showHero});

  final Widget content;
  final bool showHero;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showHero) ...[
          const _AuthHero(compact: true),
          const SizedBox(height: 22),
        ],
        _AuthCard(child: content),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.surfaceDefault,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.borderCard),
        boxShadow: [
          BoxShadow(
            color: colors.shadowStrong.withValues(alpha: 0.5),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final imageHeight = compact ? 132.0 : 360.0;
    return Semantics(
      label: 'Mascote do Trail Code usando um celular',
      image: true,
      child: compact
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/mascot/iguana-phone.png',
                  height: imageHeight,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 14),
                const Flexible(child: _BrandText(compact: true)),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/mascot/iguana-phone.png',
                  height: imageHeight,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                const _BrandText(compact: false),
              ],
            ),
    );
  }
}

class _BrandText extends StatelessWidget {
  const _BrandText({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Trail Code',
          style: compact
              ? Theme.of(context).textTheme.headlineMedium
              : Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 6),
        Text(
          'Aprenda, pratique e acompanhe sua evolução.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
