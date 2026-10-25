import 'package:digura/core/constants/app_strings.dart';
import 'package:digura/core/services/biometric_service.dart';
import 'package:digura/core/utils/clock.dart';
import 'package:digura/features/app_lock/controllers/app_lock_controller.dart';
import 'package:digura/features/app_lock/controllers/pin_change_controller.dart';
import 'package:digura/features/app_lock/controllers/pin_setup_controller.dart';
import 'package:digura/features/app_lock/models/app_lock_model.dart';
import 'package:digura/features/app_lock/models/pin_flow_model.dart';
import 'package:digura/core/widgets/app_scope.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void enter(void Function(String) input, String pin) {
  for (final d in pin.split('')) {
    input(d);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLockController', () {
    late AppServices services;
    late FakeBiometricAuthenticator bio;

    Future<void> setUpServices({List<BiometricResult>? results}) async {
      bio = FakeBiometricAuthenticator(results);
      services = await buildTestServices(pin: '2580', biometric: true, biometrics: bio);
    }

    test('doğru PIN kilidi açar', () async {
      await setUpServices();
      fakeAsync((async) {
        final c = AppLockController(services.lock, services.prefs, bio, services.clock);
        enter(c.inputDigit, '2580');
        async.elapse(const Duration(milliseconds: 300));
        expect(c.state.value.unlocked, isTrue);
        expect(bio.pinUnlocks, 1);
        c.dispose();
      });
    });

    test('5 yanlış PIN → 30 sn bekleme, geri sayım ve hakların yenilenmesi', () async {
      await setUpServices();
      fakeAsync((async) {
        final start = DateTime(2026, 10, 25, 12);
        final clock = Clock(() => start.add(async.elapsed));
        final c = AppLockController(services.lock, services.prefs, bio, clock);
        for (var i = 1; i <= 4; i++) {
          enter(c.inputDigit, '1111');
          async.elapse(const Duration(milliseconds: 300));
          expect(c.state.value.remainingPinAttempts, 5 - i);
          expect(c.state.value.error, AppStrings.wrongPin(5 - i));
          expect(c.state.value.shakeTick, i);
        }
        enter(c.inputDigit, '1111');
        async.elapse(const Duration(milliseconds: 300));
        expect(c.state.value.isLockedOut, isTrue);
        expect(c.state.value.lockoutRemainingSeconds, 30);
        expect(c.state.value.error, AppStrings.lockoutWait(30));
        expect(services.prefs.lockoutUntil, isNotNull);

        // Bekleme sırasında tuş takımı kapalıdır.
        c.inputDigit('2');
        expect(c.state.value.entered, isEmpty);

        async.elapse(const Duration(seconds: 10));
        expect(c.state.value.lockoutRemainingSeconds, 20);
        async.elapse(const Duration(seconds: 21));
        expect(c.state.value.isLockedOut, isFalse);
        expect(c.state.value.remainingPinAttempts, AppLockState.maxPinAttempts);
        expect(c.state.value.error, isNull);
        c.dispose();
      });
    });

    test('bekleme süresi uygulama yeniden açılsa da korunur', () async {
      await setUpServices();
      await services.prefs.setLockoutUntil(DateTime(2026, 10, 25, 12, 0, 20));
      fakeAsync((async) {
        final start = DateTime(2026, 10, 25, 12);
        final c = AppLockController(services.lock, services.prefs, bio, Clock(() => start.add(async.elapsed)));
        expect(c.state.value.lockoutRemainingSeconds, 20);
        async.elapse(const Duration(seconds: 21));
        expect(c.state.value.isLockedOut, isFalse);
        c.dispose();
      });
    });

    test('3 hatalı parmak izi sensörü kapatır; PIN ile giriş yeniden açar', () async {
      await setUpServices(results: [BiometricResult.failure]);
      fakeAsync((async) {
        final c = AppLockController(services.lock, services.prefs, bio, services.clock);
        c.startBiometric();
        async.flushMicrotasks();
        expect(c.state.value.sheet, FingerprintSheetStatus.failed);
        expect(c.state.value.biometricAttemptsLeft, 2);
        c.startBiometric();
        async.flushMicrotasks();
        c.startBiometric();
        async.flushMicrotasks();
        expect(c.state.value.sheet, FingerprintSheetStatus.lockout);
        expect(c.state.value.biometricTemporarilyDisabled, isTrue);
        expect(services.prefs.biometricSuspended, isTrue);

        // Kapalıyken yeni tarama başlamaz.
        expect(c.closeSheet(), isTrue);
        c.startBiometric();
        async.flushMicrotasks();
        expect(bio.calls, 3);

        enter(c.inputDigit, '2580');
        async.elapse(const Duration(milliseconds: 300));
        expect(c.state.value.unlocked, isTrue);
        expect(c.state.value.biometricTemporarilyDisabled, isFalse);
        expect(services.prefs.biometricSuspended, isFalse);
        c.dispose();
      });
    });

    test('başarılı parmak izi: "Doğrulandı" sonra kilit açılır', () async {
      await setUpServices(results: [BiometricResult.success]);
      fakeAsync((async) {
        final c = AppLockController(services.lock, services.prefs, bio, services.clock);
        c.startBiometric();
        async.flushMicrotasks();
        expect(c.state.value.sheet, FingerprintSheetStatus.verified);
        expect(c.closeSheet(), isFalse);
        async.elapse(const Duration(seconds: 1));
        expect(c.state.value.sheet, isNull);
        expect(c.state.value.unlocked, isTrue);
        c.dispose();
      });
    });
  });

  group('SimulatedBiometricAuthenticator (prototip demo sensörü)', () {
    test('kurulumda tanır, kilitte PIN ile açılana dek tanımaz', () {
      fakeAsync((async) {
        final sim = SimulatedBiometricAuthenticator();
        BiometricResult? r;
        sim.authenticate(BiometricPurpose.enroll).then((v) => r = v);
        async.elapse(const Duration(seconds: 2));
        expect(r, BiometricResult.success);
        sim.authenticate(BiometricPurpose.unlock).then((v) => r = v);
        async.elapse(const Duration(seconds: 2));
        expect(r, BiometricResult.failure);
        sim.onPinUnlocked(hadBiometricFailures: true);
        sim.authenticate(BiometricPurpose.unlock).then((v) => r = v);
        async.elapse(const Duration(seconds: 2));
        expect(r, BiometricResult.success);
      });
    });
  });

  group('PinSetupController', () {
    test('zayıf PIN reddedilir, eşleşmeyen tekrar baştan başlatır, eşleşen kaydeder', () async {
      final services = await buildTestServices();
      fakeAsync((async) {
        final c = PinSetupController(services.lock);
        enter(c.inputDigit, '1234');
        async.elapse(const Duration(milliseconds: 300));
        expect(c.state.value.error, AppStrings.weakPin);
        expect(c.state.value.stage, PinSetupStage.create);

        enter(c.inputDigit, '2580');
        async.elapse(const Duration(milliseconds: 300));
        expect(c.state.value.stage, PinSetupStage.confirm);
        enter(c.inputDigit, '2581');
        async.elapse(const Duration(milliseconds: 300));
        expect(c.state.value.stage, PinSetupStage.create);
        expect(c.state.value.error, AppStrings.pinMismatch);

        enter(c.inputDigit, '2580');
        async.elapse(const Duration(milliseconds: 300));
        enter(c.inputDigit, '2580');
        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();
        expect(c.state.value.stage, PinSetupStage.done);
        expect(services.lock.hasPin.value, isTrue);
        c.dispose();
      });
      expect(await services.lock.verifyPin('2580'), isTrue);
    });
  });

  group('PinChangeController', () {
    test('1/3 mevcut → 2/3 yeni → 3/3 tekrar', () async {
      final services = await buildTestServices(pin: '2580');
      fakeAsync((async) {
        final c = PinChangeController(services.lock);
        enter(c.inputDigit, '0000');
        async.elapse(const Duration(milliseconds: 300));
        expect(c.state.value.error, AppStrings.currentPinWrong);

        enter(c.inputDigit, '2580');
        async.elapse(const Duration(milliseconds: 300));
        expect(c.state.value.step, PinChangeStep.next);

        enter(c.inputDigit, '2580');
        async.elapse(const Duration(milliseconds: 300));
        expect(c.state.value.error, AppStrings.samePin);
        enter(c.inputDigit, '9876');
        async.elapse(const Duration(milliseconds: 300));
        expect(c.state.value.error, AppStrings.weakPin);

        enter(c.inputDigit, '1357');
        async.elapse(const Duration(milliseconds: 300));
        expect(c.state.value.step, PinChangeStep.confirm);
        enter(c.inputDigit, '1358');
        async.elapse(const Duration(milliseconds: 300));
        expect(c.state.value.step, PinChangeStep.next);
        expect(c.state.value.error, AppStrings.pinMismatch);

        enter(c.inputDigit, '1357');
        async.elapse(const Duration(milliseconds: 300));
        enter(c.inputDigit, '1357');
        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();
        expect(c.state.value.completed, isTrue);
        c.dispose();
      });
      expect(await services.lock.verifyPin('1357'), isTrue);
    });
  });
}
