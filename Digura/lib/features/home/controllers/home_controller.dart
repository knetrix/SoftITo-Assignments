import 'package:flutter/foundation.dart';

import '../models/home_model.dart';

class HomeController {
  final ValueNotifier<HomeShellState> state = ValueNotifier(const HomeShellState());

  void select(HomeTab tab) {
    if (state.value.tab == tab) return;
    state.value = state.value.copyWith(tab: tab, enterSequence: state.value.enterSequence + 1);
  }

  /// Sekmenin giriş animasyonu tetikleyicisi (yalnızca etkin sekmede değişir).
  Object? entranceTriggerFor(HomeTab tab) => state.value.tab == tab ? state.value.enterSequence : null;

  void dispose() => state.dispose();
}
