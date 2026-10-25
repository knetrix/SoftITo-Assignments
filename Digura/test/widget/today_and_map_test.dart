import 'package:digura/core/constants/app_colors.dart';
import 'package:digura/core/constants/app_strings.dart';
import 'package:digura/core/utils/clock.dart';
import 'package:digura/core/widgets/app_buttons.dart';
import 'package:digura/features/home/views/home_shell_view.dart';
import 'package:digura/features/mood_calendar/views/mood_calendar_view.dart';
import 'package:digura/features/mood_calendar/widgets/circle_reveal.dart';
import 'package:digura/features/mood_calendar/widgets/heatmap.dart';
import 'package:digura/features/mood_entry/views/mood_entry_view.dart';
import 'package:digura/features/mood_stats/views/mood_stats_view.dart';
import 'package:digura/features/mood_stats/widgets/stats_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

/// Ağaçtaki tüm görünür metinler (Text + RichText).
Iterable<String> allTexts(WidgetTester tester) sync* {
  for (final w in tester.allWidgets) {
    if (w is Text) yield w.data ?? w.textSpan?.toPlainText() ?? '';
    if (w is RichText) yield w.text.toPlainText();
  }
}

/// Simge düğmesini erişilebilirlik etiketinden bulur.
Finder byTip(String tooltip) => find.byWidgetPredicate((w) => w is AppIconButton && w.tooltip == tooltip);

void main() {
  group('Bugün (mood_entry)', () {
    testWidgets('renk seçilmeden kaydet pasif; onaylı kayıt sonrası kilitli kapsül kartı', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices();
      await tester.pumpWidget(wrapApp(s, MoodEntryView(onOpenSettings: () {}, onShowMap: () {})));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.todayTitle), findsOneWidget);
      expect(find.text('25 EKİM 2026 · PAZAR'), findsOneWidget);
      final button = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
      expect(button.onPressed, isNull);

      await tester.tap(find.text('Dingin'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.selectedMood), findsOneWidget);
      expect(tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed, isNotNull);

      await tester.enterText(find.byType(TextField), 'Parkta\nkitap okudum');
      await tester.pump();
      expect(find.text('Parkta kitap okudum'), findsOneWidget);
      expect(find.text('19/140'), findsOneWidget);

      await tester.tap(find.text(AppStrings.saveColor));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.confirmTitle), findsOneWidget);
      expect(find.textContaining(AppStrings.withNote), findsOneWidget);

      await tester.tap(find.text(AppStrings.save));
      await tester.pumpAndSettle();
      // Başlık + bildirim (snackbar) aynı metni taşır.
      expect(find.text(AppStrings.todaySavedTitle), findsNWidgets(2));
      expect(find.text(AppStrings.noteSealed), findsOneWidget);
      expect(find.text(AppStrings.capsuleRemaining(30)), findsOneWidget);
      expect(find.text(AppStrings.savedPermanent), findsOneWidget);
      // Kaydedilen not Bugün ekranında bile gösterilmez.
      expect(allTexts(tester).any((t) => t.contains('kitap okudum')), isFalse);
      expect(s.moods.entryFor(s.clock.today())!.note, 'Parkta kitap okudum');
    });

    testWidgets('not 140 karakterde kesilir ve sayaç sınır rengini alır', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices();
      await tester.pumpWidget(wrapApp(s, MoodEntryView(onOpenSettings: () {}, onShowMap: () {})));
      await tester.enterText(find.byType(TextField), 'x' * 160);
      await tester.pump();
      expect(find.text('140/140'), findsOneWidget);
      final counter = tester.widget<Text>(find.text('140/140'));
      expect(counter.style!.color, AppPalette.light.danger);
    });
  });

  group('Harita (mood_calendar)', () {
    testWidgets('kilitli günün notu widget ağacında hiç oluşturulmaz', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices();
      final locked = s.moods.getByDayKey('2026-10-24')!;
      expect(locked.note, isNotEmpty);
      await tester.pumpWidget(wrapApp(s, const MoodCalendarView()));
      await tester.pumpAndSettle();
      expect(find.text('Ekim 2026'), findsOneWidget);
      expect(find.text(AppStrings.monthColored(17, 31)), findsOneWidget);

      await tester.tap(find.text('24'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.capsuleRemaining(29)), findsOneWidget);
      expect(allTexts(tester).any((t) => t.contains(locked.note)), isFalse);
      expect(find.byType(CircleReveal), findsNothing);
      // Kilitli kapsül açılmış sayılmaz.
      expect(s.moods.isOpened(locked.id), isFalse);
    });

    testWidgets('yeni açılan kapsül ilk açılışta CircleReveal ile, sonra düz açılır', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices();
      final fresh = s.moods.getByDayKey('2026-09-19')!;
      await tester.pumpWidget(wrapApp(s, const MoodCalendarView()));
      await tester.pumpAndSettle();
      await tester.tap(byTip(AppStrings.previousMonth));
      await tester.pumpAndSettle();
      expect(find.text('Eylül 2026'), findsOneWidget);

      await tester.tap(find.text('19'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final reveal = find.byWidgetPredicate((w) => w is ClipPath && w.clipper is CircleReveal);
      expect(reveal, findsOneWidget);
      await tester.pumpAndSettle();
      final quote = fresh.note.isEmpty ? AppStrings.emptyCapsuleNote : AppStrings.quoted(fresh.note);
      expect(find.text(quote), findsOneWidget);
      expect(s.moods.isOpened(fresh.id), isTrue);

      await tester.tap(byTip(AppStrings.close));
      await tester.pumpAndSettle();
      await tester.tap(find.text('19'));
      await tester.pumpAndSettle();
      expect(reveal, findsNothing);
      expect(find.text(quote), findsOneWidget);
    });

    testWidgets('Yıl görünümü 12 mini ay gösterir ve aya geçer', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices();
      await tester.pumpWidget(wrapApp(s, const MoodCalendarView()));
      await tester.tap(find.text(AppStrings.viewYear));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.yearColored(69)), findsOneWidget);
      // Aynı satırdaki mini aylar eşit yüksekliktedir (CSS ızgarası gibi).
      final cards = find.byType(MiniMonthCard);
      expect(tester.getSize(cards.at(0)).height, tester.getSize(cards.at(2)).height);
      for (var m = 1; m <= 12; m++) {
        expect(find.text(AppStrings.monthShort(m)), findsOneWidget);
      }
      await tester.tap(find.text('Ağu'));
      await tester.pumpAndSettle();
      expect(find.text('Ağustos 2026'), findsOneWidget);
    });
  });

  group('İstatistik (mood_stats)', () {
    testWidgets('aylık dağılım ve boş ay durumu', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices();
      await tester.pumpWidget(wrapApp(s, const MoodStatsView()));
      await tester.pumpAndSettle();
      expect(find.text('17'), findsOneWidget);
      expect(find.text(AppStrings.topMood(24, Mood.joyful.label)), findsOneWidget);
      expect(find.text('%12'), findsOneWidget);
      // Yığılmış şerit dilimleri 18 px yüksekliğinde çizilir.
      final segment = find.descendant(of: find.byType(StackBar), matching: find.byType(ColoredBox)).first;
      expect(tester.getSize(segment).height, 18);

      for (var i = 0; i < 3; i++) {
        await tester.tap(byTip(AppStrings.previousMonth));
        await tester.pumpAndSettle();
      }
      expect(find.text('Temmuz 2026'), findsOneWidget);
      expect(find.text(AppStrings.statsEmptyTitle), findsOneWidget);
    });
  });

  group('Ana kabuk (home)', () {
    testWidgets('3 sekme arasında gezinme ve kademeli giriş', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices();
      await tester.pumpWidget(wrapApp(s, const HomeShellView()));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.todayTitle), findsOneWidget);

      await tester.tap(find.text(AppStrings.tabMap));
      await tester.pump(const Duration(milliseconds: 60));
      final faded = tester.widgetList<Opacity>(find.byType(Opacity)).where((o) => o.opacity < 1);
      expect(faded, isNotEmpty);
      await tester.pumpAndSettle();
      expect(find.text(trUpper(AppStrings.mapEyebrow)), findsOneWidget);

      await tester.tap(find.text(AppStrings.tabStats));
      await tester.pumpAndSettle();
      expect(find.text(trUpper(AppStrings.statsEyebrow)), findsOneWidget);
    });
  });
}
