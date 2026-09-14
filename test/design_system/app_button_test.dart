import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_text_field.dart';

import '../support/design_system_harness.dart';

void main() {
  testWidgets('habilitado executa a ação', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      themed(
        AppButton(
          label: 'Enviar',
          icon: AppIcons.play,
          onPressed: () => taps++,
        ),
      ),
    );

    await tester.tap(find.text('Enviar'));
    expect(taps, 1);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isTrue,
    );
  });

  testWidgets('desabilitado não executa a ação', (tester) async {
    await tester.pumpWidget(
      themed(const AppButton(label: 'Enviar', onPressed: null)),
    );

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isFalse,
    );
  });

  testWidgets('carregando mostra indicador e bloqueia duplo envio', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      themed(
        AppButton(label: 'Enviar', isLoading: true, onPressed: () => taps++),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Enviar'));
    await tester.tap(find.text('Enviar'));
    expect(taps, 0);
    expect(find.bySemanticsLabel(RegExp('Enviar')), findsOneWidget);
  });

  testWidgets('campo de senha alterna visibilidade', (tester) async {
    await tester.pumpWidget(
      themed(const AppTextField(label: 'Senha', obscureText: true)),
    );

    EditableText editable() => tester.widget(find.byType(EditableText));
    expect(editable().obscureText, isTrue);

    await tester.tap(find.byTooltip('Mostrar senha'));
    await tester.pump();
    expect(editable().obscureText, isFalse);
    expect(find.byTooltip('Ocultar senha'), findsOneWidget);
  });

  testWidgets('campo exibe mensagem de erro', (tester) async {
    await tester.pumpWidget(
      themed(
        const AppTextField(label: 'Login', errorText: 'Campo obrigatório'),
      ),
    );

    expect(find.text('Campo obrigatório'), findsOneWidget);
  });
}
