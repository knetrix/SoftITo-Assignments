import 'package:flutter/foundation.dart'; // ValueNotifier Class'ını Sağlayan Foundation Kütüphanesini import Eder.

import '../models/home_model.dart'; // HomeShellState ve HomeTab Tiplerini import Eder.

class HomeController { // Ana Kabuğun Sekme Durumunu Yöneten Controller Class'ıdır.
  final ValueNotifier<HomeShellState> state = ValueNotifier(const HomeShellState()); // Varsayılan Kabuk Durumuyla Başlayan ValueNotifier'dır.

  void select(HomeTab tab) { // Verilen Sekmeyi Seçili Yapar.
    if (state.value.tab == tab) return; // Sekme Zaten Seçiliyse Hiçbir Şey Yapmaz.
    state.value = state.value.copyWith(tab: tab, enterSequence: state.value.enterSequence + 1); // Sekmeyi Değiştirir ve Giriş Sayacını Artırır.
  }

  /// Sekmenin giriş animasyonu tetikleyicisi (yalnızca etkin sekmede değişir).
  Object? entranceTriggerFor(HomeTab tab) => state.value.tab == tab ? state.value.enterSequence : null; // Etkin Sekmeyse Sayacı, Değilse null Döndürür.

  void dispose() => state.dispose(); // ValueNotifier'ı dispose Eder.
}
