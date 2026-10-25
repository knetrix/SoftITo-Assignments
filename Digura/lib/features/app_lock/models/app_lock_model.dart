import 'package:flutter/foundation.dart';

/// Parmak izi panelinin durumu (`FingerprintSheet`).
enum FingerprintSheetStatus { scanning, failed, lockout, verified }

/// Açılış kilidi durumu (PROJECT_NEW.md 6.3).
@immutable
class AppLockState {
  static const int maxPinAttempts = 5;
  static const int lockoutSeconds = 30;
  static const int maxBiometricFailures = 3;

  final bool hasPin;
  final bool biometricEnabled;
  final int remainingPinAttempts;

  /// 0 ya da 30'dan geri sayım.
  final int lockoutRemainingSeconds;
  final int biometricFailCount;
  final bool biometricTemporarilyDisabled;

  /// Girilen haneler (en çok 4).
  final String entered;
  final String? error;

  /// Her hatada artar; görünüm sallanmayı bununla tetikler.
  final int shakeTick;
  final FingerprintSheetStatus? sheet;
  final bool unlocked;

  const AppLockState({
    this.hasPin = true,
    this.biometricEnabled = false,
    this.remainingPinAttempts = maxPinAttempts,
    this.lockoutRemainingSeconds = 0,
    this.biometricFailCount = 0,
    this.biometricTemporarilyDisabled = false,
    this.entered = '',
    this.error,
    this.shakeTick = 0,
    this.sheet,
    this.unlocked = false,
  });

  bool get isLockedOut => lockoutRemainingSeconds > 0;

  bool get keypadEnabled => !isLockedOut && sheet == null && !unlocked;

  bool get canUseBiometric => biometricEnabled && !biometricTemporarilyDisabled && !isLockedOut;

  int get biometricAttemptsLeft => maxBiometricFailures - biometricFailCount;

  AppLockState copyWith({
    bool? hasPin,
    bool? biometricEnabled,
    int? remainingPinAttempts,
    int? lockoutRemainingSeconds,
    int? biometricFailCount,
    bool? biometricTemporarilyDisabled,
    String? entered,
    String? Function()? error,
    int? shakeTick,
    FingerprintSheetStatus? Function()? sheet,
    bool? unlocked,
  }) {
    return AppLockState(
      hasPin: hasPin ?? this.hasPin,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      remainingPinAttempts: remainingPinAttempts ?? this.remainingPinAttempts,
      lockoutRemainingSeconds: lockoutRemainingSeconds ?? this.lockoutRemainingSeconds,
      biometricFailCount: biometricFailCount ?? this.biometricFailCount,
      biometricTemporarilyDisabled: biometricTemporarilyDisabled ?? this.biometricTemporarilyDisabled,
      entered: entered ?? this.entered,
      error: error != null ? error() : this.error,
      shakeTick: shakeTick ?? this.shakeTick,
      sheet: sheet != null ? sheet() : this.sheet,
      unlocked: unlocked ?? this.unlocked,
    );
  }

  /// PIN haneleri ve hata metni kalıcı hale getirilmez.
  factory AppLockState.fromJson(Map<String, dynamic> json) => AppLockState(
    hasPin: json['hasPin'] as bool? ?? true,
    biometricEnabled: json['biometricEnabled'] as bool? ?? false,
    remainingPinAttempts: json['remainingPinAttempts'] as int? ?? maxPinAttempts,
    lockoutRemainingSeconds: json['lockoutRemainingSeconds'] as int? ?? 0,
    biometricFailCount: json['biometricFailCount'] as int? ?? 0,
    biometricTemporarilyDisabled: json['biometricTemporarilyDisabled'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'hasPin': hasPin,
    'biometricEnabled': biometricEnabled,
    'remainingPinAttempts': remainingPinAttempts,
    'lockoutRemainingSeconds': lockoutRemainingSeconds,
    'biometricFailCount': biometricFailCount,
    'biometricTemporarilyDisabled': biometricTemporarilyDisabled,
  };

  @override
  bool operator ==(Object other) =>
      other is AppLockState &&
      other.hasPin == hasPin &&
      other.biometricEnabled == biometricEnabled &&
      other.remainingPinAttempts == remainingPinAttempts &&
      other.lockoutRemainingSeconds == lockoutRemainingSeconds &&
      other.biometricFailCount == biometricFailCount &&
      other.biometricTemporarilyDisabled == biometricTemporarilyDisabled &&
      other.entered == entered &&
      other.error == error &&
      other.shakeTick == shakeTick &&
      other.sheet == sheet &&
      other.unlocked == unlocked;

  @override
  int get hashCode => Object.hash(
    hasPin,
    biometricEnabled,
    remainingPinAttempts,
    lockoutRemainingSeconds,
    biometricFailCount,
    biometricTemporarilyDisabled,
    entered,
    error,
    shakeTick,
    sheet,
    unlocked,
  );
}
