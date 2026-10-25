import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/data/app_lock_repository.dart';
import '../../../core/utils/pin_validator.dart';
import '../models/pin_flow_model.dart';

/// PIN değiştirme: 1/3 mevcut PIN → 2/3 yeni PIN → 3/3 yeni PIN tekrar.
class PinChangeController {
  final AppLockRepository _lock;
  final ValueNotifier<PinChangeState> state = ValueNotifier(const PinChangeState());

  String _current = '';
  String _first = '';
  Timer? _timer;
  bool _disposed = false;

  PinChangeController(this._lock);

  PinChangeState get _s => state.value;

  void _emit(PinChangeState next) {
    if (!_disposed) state.value = next;
  }

  void inputDigit(String digit) {
    if (_s.completed || _s.entered.length >= PinValidator.length) return;
    _emit(_s.copyWith(entered: _s.entered + digit, error: () => null));
    if (_s.entered.length == PinValidator.length) _timer = Timer(AppMotion.pinEvaluate, _evaluate);
  }

  void deleteDigit() {
    if (_s.entered.isEmpty || _timer?.isActive == true) return;
    _emit(_s.copyWith(entered: _s.entered.substring(0, _s.entered.length - 1)));
  }

  PinChangeState _fail(String message, {PinChangeStep? step}) =>
      _s.copyWith(step: step, entered: '', error: () => message, shakeTick: _s.shakeTick + 1);

  Future<void> _evaluate() async {
    final value = _s.entered;
    switch (_s.step) {
      case PinChangeStep.current:
        if (!await _lock.verifyPin(value)) {
          _emit(_fail(AppStrings.currentPinWrong));
          return;
        }
        _current = value;
        _emit(_s.copyWith(step: PinChangeStep.next, entered: ''));
      case PinChangeStep.next:
        if (value == _current) {
          _emit(_fail(AppStrings.samePin));
        } else if (PinValidator.isWeak(value)) {
          _emit(_fail(AppStrings.weakPin));
        } else {
          _first = value;
          _emit(_s.copyWith(step: PinChangeStep.confirm, entered: ''));
        }
      case PinChangeStep.confirm:
        if (value != _first) {
          _first = '';
          _emit(_fail(AppStrings.pinMismatch, step: PinChangeStep.next));
          return;
        }
        await _lock.setPin(value);
        _current = '';
        _first = '';
        _emit(_s.copyWith(entered: '', completed: true));
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    state.dispose();
  }
}
