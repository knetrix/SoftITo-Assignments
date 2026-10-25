import 'package:flutter/foundation.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_strings.dart';

enum HomeTab {
  today(AppStrings.tabToday, AppIcons.sun),
  map(AppStrings.tabMap, AppIcons.grid),
  stats(AppStrings.tabStats, AppIcons.chart);

  final String label;
  final AppIconData icon;

  const HomeTab(this.label, this.icon);
}

/// Kabuk durumu: seçili sekme ve sekme değişim sayacı (giriş animasyonu
/// yalnızca sekme **değişince** oynar).
@immutable
class HomeShellState {
  final HomeTab tab;
  final int enterSequence;

  const HomeShellState({this.tab = HomeTab.today, this.enterSequence = 0});

  HomeShellState copyWith({HomeTab? tab, int? enterSequence}) =>
      HomeShellState(tab: tab ?? this.tab, enterSequence: enterSequence ?? this.enterSequence);

  factory HomeShellState.fromJson(Map<String, dynamic> json) => HomeShellState(
    tab: HomeTab.values.firstWhere((t) => t.name == json['tab'], orElse: () => HomeTab.today),
    enterSequence: json['enterSequence'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {'tab': tab.name, 'enterSequence': enterSequence};

  @override
  bool operator ==(Object other) => other is HomeShellState && other.tab == tab && other.enterSequence == enterSequence;

  @override
  int get hashCode => Object.hash(tab, enterSequence);
}
