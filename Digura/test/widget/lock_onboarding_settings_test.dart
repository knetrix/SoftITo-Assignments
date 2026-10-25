import 'package:digura/core/constants/app_strings.dart';
import 'package:digura/core/services/biometric_service.dart';
import 'package:digura/core/widgets/pressable.dart';
import 'package:digura/features/app_lock/views/biometric_setup_view.dart';
import 'package:digura/features/app_lock/views/lock_view.dart';
import 'package:digura/features/app_lock/views/pin_setup_view.dart';
import 'package:digura/features/app_lock/widgets/pin_widgets.dart';
import 'package:digura/features/onboarding/views/onboarding_view.dart';
import 'package:digura/features/settings/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

Future<void> typePin(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.widgetWithText(PinKey, d));
    await tester.pump(const Duration(milliseconds: 20));
  }
}

/// PIN noktalarının altındaki sallanma `Transform`'u.
Finder shakeTransform() => find.descendant(of: find.byType(PinDots), matching: find.byType(Transform));

void main() {
  group('Açılış kilidi', () {
    testWidgets('doğru PIN → "Kilit açıldı" → onUnlocked', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices(pin: '2580');
      var unlocked = false;
      await tester.pumpWidget(wrapApp(s, LockView(onUnlocked: () => unlocked = true, onWipeRequested: () {})));
      expect(find.text(AppStrings.lockPromptPin), findsOneWidget);
      await typePin(tester, '2580');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(AppStrings.unlockedTitle), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(unlocked, isTrue);
    });

    testWidgets('yanlış PIN: kırmızı mesaj + sallanma', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices(pin: '2580');
      await tester.pumpWidget(wrapApp(s, LockView(onUnlocked: () {}, onWipeRequested: () {})));
      await typePin(tester, '1111');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(AppStrings.wrongPin(4)), findsOneWidget);
      expect(shakeTransform(), findsWidgets);
      await tester.pump(const Duration(seconds: 1));
      expect(shakeTransform(), findsNothing);
    });

    testWidgets('hareket azaltma: sallanma yok, hata metni ve renk kalır', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices(pin: '2580');
      await tester.pumpWidget(wrapApp(s, LockView(onUnlocked: () {}, onWipeRequested: () {}), reduceMotion: true));
      await typePin(tester, '1111');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(AppStrings.wrongPin(4)), findsOneWidget);
      expect(shakeTransform(), findsNothing);
      expect(tester.widget<PinDots>(find.byType(PinDots)).tone, PinTone.error);
    });

    testWidgets('5 yanlış denemede 30 sn bekleme ve geri sayım', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices(pin: '2580');
      await tester.pumpWidget(wrapApp(s, LockView(onUnlocked: () {}, onWipeRequested: () {})));
      for (var i = 0; i < 5; i++) {
        await typePin(tester, '1111');
        await tester.pump(const Duration(milliseconds: 400));
      }
      expect(find.text(AppStrings.lockoutWait(30)), findsOneWidget);
      // Tuşlar pasif: yeni hane girilmez.
      await typePin(tester, '2');
      expect(tester.widget<PinDots>(find.byType(PinDots)).filled, 0);
    });

    testWidgets('parmak izi paneli: 3 hata sensörü kapatır', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices(
        pin: '2580',
        biometric: true,
        biometrics: FakeBiometricAuthenticator([BiometricResult.failure]),
      );
      await tester.pumpWidget(wrapApp(s, LockView(onUnlocked: () {}, onWipeRequested: () {})));
      expect(find.text(AppStrings.lockPromptBio), findsOneWidget);
      await tester.tap(find.byWidgetPredicate((w) => w is PinKey && w.label == AppStrings.bioKeyLabel));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.bioFail(2)), findsOneWidget);
      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.bioSheetLockout), findsOneWidget);
      await tester.tap(find.text(AppStrings.continueWithPin));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.bioTemporarilyOff), findsOneWidget);
      expect(find.text(AppStrings.lockPromptPin), findsOneWidget);
    });

    testWidgets('PIN\'imi unuttum → Her şeyi sil ve sıfırla', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices(pin: '2580');
      var wiped = false;
      await tester.pumpWidget(wrapApp(s, LockView(onUnlocked: () {}, onWipeRequested: () => wiped = true)));
      await tester.tap(find.text(AppStrings.forgotPin));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.forgotTitle), findsOneWidget);
      await tester.tap(find.text(AppStrings.wipeAll));
      await tester.pumpAndSettle();
      expect(wiped, isTrue);
    });
  });

  group('Kilit kurulumu', () {
    testWidgets('1/2 PIN: zayıf PIN reddi, doğrulama ve "PIN oluşturuldu"', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices();
      var done = false;
      await tester.pumpWidget(wrapApp(s, PinSetupView(onCompleted: () => done = true)));
      expect(find.text(AppStrings.pinCreateTitle), findsOneWidget);
      await typePin(tester, '0000');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(AppStrings.weakPin), findsOneWidget);
      await typePin(tester, '2580');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(AppStrings.pinConfirmTitle), findsOneWidget);
      expect(find.text(AppStrings.restart), findsOneWidget);
      await typePin(tester, '2580');
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.pinCreated), findsOneWidget);
      await tester.tap(find.text(AppStrings.next));
      expect(done, isTrue);
      expect(s.lock.hasPin.value, isTrue);
    });

    testWidgets('2/2 parmak izi: etkinleştirme', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices(pin: '2580');
      bool? skipped;
      await tester.pumpWidget(wrapApp(s, BiometricSetupView(onCompleted: (v) => skipped = v)));
      await tester.tap(find.text(AppStrings.bioUse));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(AppStrings.bioOnTitle), findsOneWidget);
      expect(s.lock.biometricEnabled.value, isTrue);
      await tester.tap(find.text(AppStrings.startToday));
      expect(skipped, isFalse);
    });
  });

  group('Karşılama', () {
    testWidgets('3 adım: Devam → Devam → Günün rengini seç', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices();
      var finished = false;
      await tester.pumpWidget(wrapApp(s, OnboardingView(onFinished: () => finished = true)));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.welcomeTitle), findsOneWidget);
      expect(find.text(AppStrings.skip), findsOneWidget);

      await tester.tap(find.byWidgetPredicate((w) => w is Pressable && w.semanticLabel == 'Yorgun'));
      await tester.pumpAndSettle();
      expect(find.text('Yorgun'), findsOneWidget);

      await tester.tap(find.text(AppStrings.next));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.capsuleTitle), findsOneWidget);
      expect(s.prefs.onboardingStep, 1);

      await tester.tap(find.text(AppStrings.next));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.startTitle), findsOneWidget);
      expect(find.text(AppStrings.startToday), findsOneWidget);

      // Test yazı tipi daha geniş olduğundan sayfa kaydırılabilir; anahtar görünür kılınır.
      await tester.ensureVisible(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.reminderPermission), findsOneWidget);

      await tester.tap(find.text(AppStrings.startToday));
      await tester.pumpAndSettle();
      expect(finished, isTrue);
      expect(s.prefs.onboardingDone, isTrue);
      expect(s.prefs.reminderEnabled.value, isTrue);
    });
  });

  group('Ayarlar', () {
    testWidgets('tema diyaloğu, hatırlatıcı ve güvenlik alt ekranı', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices(pin: '2580');
      await tester.pumpWidget(wrapApp(s, const SettingsView()));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.settingsTitle), findsOneWidget);
      expect(find.text(AppStrings.appVersion), findsOneWidget);

      await tester.tap(find.text(AppStrings.theme));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.themeDark));
      await tester.tap(find.text(AppStrings.ok));
      await tester.pumpAndSettle();
      expect(s.prefs.themeMode.value, ThemeMode.dark);
      expect(find.text(AppStrings.themeSnack(AppStrings.themeDark)), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(s.prefs.reminderEnabled.value, isTrue);
      expect(find.text(AppStrings.reminderOn), findsOneWidget);

      await tester.tap(find.text(AppStrings.security));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.changePinTitle), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(s.lock.biometricEnabled.value, isTrue);
      expect(find.text(AppStrings.bioRowOn), findsOneWidget);
    });

    testWidgets('örnek veriye dön: kayıtlar ve demo PIN 2580', (tester) async {
      usePhoneSize(tester);
      final s = await buildTestServices(pin: '1357', seed: false);
      await tester.pumpWidget(wrapApp(s, const SettingsView()));
      await tester.tap(find.text(AppStrings.resetSample));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.resetSample).last);
      await tester.pumpAndSettle();
      expect(s.moods.entries.value.length, 69);
      expect(await s.lock.verifyPin('2580'), isTrue);
    });
  });
}
