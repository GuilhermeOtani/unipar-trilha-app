import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/widgets/app_mascot.dart';
import 'package:unipar_trilha_app/core/widgets/app_progress.dart';
import 'package:unipar_trilha_app/core/widgets/feedback_card.dart';
import 'package:unipar_trilha_app/core/widgets/quiz_option.dart';

import '../support/design_system_harness.dart';

void main() {
  testWidgets('opção idle é selecionável', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      themed(QuizOption(label: 'a', text: '<h1>', onTap: () => taps++)),
    );

    await tester.tap(find.byType(QuizOption));
    expect(taps, 1);
    expect(
      tester.getSemantics(find.byType(QuizOption)),
      isSemantics(label: 'a) <h1>', isInMutuallyExclusiveGroup: true),
    );
  });

  testWidgets('opção selecionada informa estado marcado', (tester) async {
    await tester.pumpWidget(
      themed(
        QuizOption(
          label: 'a',
          text: '<h1>',
          state: QuizOptionState.selected,
          onTap: () {},
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(QuizOption)),
      isSemantics(isChecked: true),
    );
  });

  testWidgets('correta e incorreta exibem rótulo, não só cor', (tester) async {
    await tester.pumpWidget(
      themed(
        const Column(
          children: [
            QuizOption(label: 'd', text: '<p>', state: QuizOptionState.correct),
            QuizOption(
              label: 'a',
              text: '<h1>',
              state: QuizOptionState.incorrect,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Correta'), findsOneWidget);
    expect(find.text('Incorreta'), findsOneWidget);
    expect(find.bySemanticsLabel('d) <p>, resposta correta'), findsOneWidget);
    expect(
      find.bySemanticsLabel('a) <h1>, resposta incorreta'),
      findsOneWidget,
    );
  });

  testWidgets('opção sem onTap fica desabilitada', (tester) async {
    await tester.pumpWidget(themed(const QuizOption(label: 'b', text: '<th>')));

    expect(
      tester.getSemantics(find.byType(QuizOption)),
      isSemantics(isEnabled: false),
    );
  });

  for (final variant in FeedbackVariant.values) {
    for (final size in [compactSize, desktopSize]) {
      testWidgets('feedback ${variant.name} em ${size.width.toInt()} px', (
        tester,
      ) async {
        useSurface(tester, size);
        await tester.pumpWidget(
          themed(
            FeedbackCard(
              variant: variant,
              title: 'Título',
              message: 'Explicação',
              code: '<p>Meu parágrafo!</p>',
              hint: 'pense na inicial de parágrafo.',
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(
          find.text('Dica: pense na inicial de parágrafo.'),
          findsOneWidget,
        );
        expect(find.byType(AppMascot), findsOneWidget);
        expect(
          find.bySemanticsLabel(
            RegExp(
              variant == FeedbackVariant.success
                  ? '^Resposta correta'
                  : '^Resposta incorreta',
            ),
          ),
          findsOneWidget,
        );

        final mascot = tester.getSize(find.byType(AppMascot));
        final pose = tester.widget<AppMascot>(find.byType(AppMascot)).pose;
        expect(mascot.width / mascot.height, closeTo(pose.aspectRatio, 0.01));
      });
    }
  }

  testWidgets('stepper anuncia a questão atual', (tester) async {
    await tester.pumpWidget(themed(const QuizStepper(current: 2, total: 5)));

    expect(find.bySemanticsLabel('Questão 2 de 5'), findsOneWidget);
  });
}
