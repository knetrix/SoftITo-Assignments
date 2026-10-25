import 'package:flutter/foundation.dart';

enum PinSetupStage { create, confirm, done }

/// 2 adımlı kurulumun 1. adımı: PIN oluştur → tekrar gir → oluşturuldu.
@immutable
class PinSetupState {
  final PinSetupStage stage;
  final String entered;
  final String? error;
  final int shakeTick;

  const PinSetupState({this.stage = PinSetupStage.create, this.entered = '', this.error, this.shakeTick = 0});

  PinSetupState copyWith({PinSetupStage? stage, String? entered, String? Function()? error, int? shakeTick}) =>
      PinSetupState(
        stage: stage ?? this.stage,
        entered: entered ?? this.entered,
        error: error != null ? error() : this.error,
        shakeTick: shakeTick ?? this.shakeTick,
      );

  factory PinSetupState.fromJson(Map<String, dynamic> json) => PinSetupState(
    stage: PinSetupStage.values.firstWhere((s) => s.name == json['stage'], orElse: () => PinSetupStage.create),
  );

  /// Girilen haneler bilinçli olarak dışarıda bırakılır.
  Map<String, dynamic> toJson() => {'stage': stage.name};

  @override
  bool operator ==(Object other) =>
      other is PinSetupState &&
      other.stage == stage &&
      other.entered == entered &&
      other.error == error &&
      other.shakeTick == shakeTick;

  @override
  int get hashCode => Object.hash(stage, entered, error, shakeTick);
}

enum PinChangeStep {
  current(1),
  next(2),
  confirm(3);

  final int number;

  const PinChangeStep(this.number);
}

/// Ayarlar › Güvenlik › PIN'i değiştir (1/3 → 2/3 → 3/3).
@immutable
class PinChangeState {
  final PinChangeStep step;
  final String entered;
  final String? error;
  final int shakeTick;
  final bool completed;

  const PinChangeState({
    this.step = PinChangeStep.current,
    this.entered = '',
    this.error,
    this.shakeTick = 0,
    this.completed = false,
  });

  PinChangeState copyWith({
    PinChangeStep? step,
    String? entered,
    String? Function()? error,
    int? shakeTick,
    bool? completed,
  }) => PinChangeState(
    step: step ?? this.step,
    entered: entered ?? this.entered,
    error: error != null ? error() : this.error,
    shakeTick: shakeTick ?? this.shakeTick,
    completed: completed ?? this.completed,
  );

  factory PinChangeState.fromJson(Map<String, dynamic> json) => PinChangeState(
    step: PinChangeStep.values.firstWhere((s) => s.name == json['step'], orElse: () => PinChangeStep.current),
  );

  Map<String, dynamic> toJson() => {'step': step.name};

  @override
  bool operator ==(Object other) =>
      other is PinChangeState &&
      other.step == step &&
      other.entered == entered &&
      other.error == error &&
      other.shakeTick == shakeTick &&
      other.completed == completed;

  @override
  int get hashCode => Object.hash(step, entered, error, shakeTick, completed);
}

enum BiometricSetupStatus { idle, scanning, enabled, failed, unavailable }
