import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/core/widgets/app_primary_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_text_field.dart';

void main() {
  testWidgets('botão compartilhado representa loading e desabilitado', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: AppPrimaryButton(
            label: 'Salvar',
            onPressed: null,
            loading: true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets('campo compartilhado aplica validação', (tester) async {
    final key = GlobalKey<FormState>();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Form(
            key: key,
            child: AppTextField(
              controller: controller,
              label: 'Campo',
              hint: 'Digite',
              validator: (value) => value!.isEmpty ? 'Obrigatório' : null,
            ),
          ),
        ),
      ),
    );

    key.currentState!.validate();
    await tester.pump();
    expect(find.text('Obrigatório'), findsOneWidget);
  });
}
