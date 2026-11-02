import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // context.palette Extension'ını import Eder.
import '../../../core/widgets/app_page_route.dart'; // Özel Geçişli AppPageRoute'u import Eder.
import '../../mood_calendar/views/mood_calendar_view.dart'; // Harita Sekmesi İçin MoodCalendarView'u import Eder.
import '../../mood_entry/views/mood_entry_view.dart'; // Bugün Sekmesi İçin MoodEntryView'u import Eder.
import '../../mood_stats/views/mood_stats_view.dart'; // İstatistik Sekmesi İçin MoodStatsView'u import Eder.
import '../../settings/views/settings_view.dart'; // Ayarlar Ekranı SettingsView'u import Eder.
import '../controllers/home_controller.dart'; // Sekme Durumunu Yöneten HomeController'ı import Eder.
import '../models/home_model.dart'; // HomeTab ve HomeShellState Tiplerini import Eder.
import '../widgets/digura_navigation_bar.dart'; // Alt Gezinme Çubuğu DiguraNavigationBar'ı import Eder.

/// 3 sekmeli ana kabuk: Bugün, Harita, İstatistik. Sekme durumları
/// (`IndexedStack`) korunur; sekme değişince içerik kademeli girer.
class HomeShellView extends StatefulWidget { // Üç Sekmeli Ana Kabuk Ekranı StatefulWidget'ıdır.
  const HomeShellView({super.key}); // key Parametresini Superclass'a İleten const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<HomeShellView> createState() => _HomeShellViewState(); // Kabuğun State Nesnesini Oluşturur.
}

class _HomeShellViewState extends State<HomeShellView> { // Kabuk Durumunu ve Kaydırma Controller'larını Tutan State Class'ıdır.
  final HomeController _controller = HomeController(); // Sekme Seçimini Yöneten Controller'dır.
  final Map<HomeTab, ScrollController> _scrolls = {for (final tab in HomeTab.values) tab: ScrollController()}; // Her Sekme İçin Ayrı ScrollController Tutar.

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Serbest Bırakır.
    _controller.dispose(); // HomeController'ı dispose Eder.
    for (final s in _scrolls.values) { // Tüm ScrollController'ları Dolaşır.
      s.dispose(); // Her ScrollController'ı dispose Eder.
    }
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  void _select(HomeTab tab) { // Sekme Değiştirme İşlemini Yürütür.
    if (tab == _controller.state.value.tab) return; // Sekme Zaten Seçiliyse Çıkar.
    FocusScope.of(context).unfocus(); // Açık Klavye Odağını Kaldırır.
    final scroll = _scrolls[tab]!; // Hedef Sekmenin ScrollController'ını Alır.
    if (scroll.hasClients) scroll.jumpTo(0); // Bağlı Bir Liste Varsa En Üste Kaydırır.
    _controller.select(tab); // Controller Üzerinden Sekmeyi Seçer.
  }

  void _openSettings() { // Ayarlar Ekranını Açar.
    FocusScope.of(context).unfocus(); // Açık Klavye Odağını Kaldırır.
    Navigator.of(context).push(AppPageRoute.of<void>(context, (_) => const SettingsView())); // SettingsView'u AppPageRoute İle Push Eder.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Kabuğun Widget Tree'sini Oluşturur.
    return ValueListenableBuilder<HomeShellState>( // Kabuk Durumu Değiştikçe Yeniden Çizer.
      valueListenable: _controller.state, // Controller'ın state ValueNotifier'ını Dinler.
      builder: (context, state, _) { // Güncel Durumla Arayüzü Oluşturur.
        return Scaffold( // Sayfanın Temel Material Layout'unu Oluşturur.
          backgroundColor: context.palette.bg, // Arka Plan Rengini bg Yapar.
          body: SafeArea( // İçeriği Güvenli Alana Yerleştirir.
            bottom: false, // Alt Güvenli Alanı Gezinme Çubuğuna Bırakır.
            child: IndexedStack( // Tüm Sekmeleri Canlı Tutup Yalnızca Seçiliyi Gösterir.
              index: state.tab.index, // Seçili Sekmenin Sırasını Gösterir.
              children: [ // IndexedStack'in Sekme Listesidir.
                MoodEntryView( // Bugün Sekmesinin Ekranıdır.
                  entranceTrigger: _controller.entranceTriggerFor(HomeTab.today), // Bugün Sekmesinin Giriş Animasyonu Tetikleyicisini Verir.
                  scrollController: _scrolls[HomeTab.today], // Bugün Sekmesinin ScrollController'ını Verir.
                  onOpenSettings: _openSettings, // Ayarları Açma Callback'ini Verir.
                  onShowMap: () => _select(HomeTab.map), // Harita Sekmesine Geçiş Callback'ini Verir.
                ),
                MoodCalendarView( // Harita Sekmesinin Ekranıdır.
                  entranceTrigger: _controller.entranceTriggerFor(HomeTab.map), // Harita Sekmesinin Giriş Animasyonu Tetikleyicisini Verir.
                  scrollController: _scrolls[HomeTab.map], // Harita Sekmesinin ScrollController'ını Verir.
                ),
                MoodStatsView( // İstatistik Sekmesinin Ekranıdır.
                  entranceTrigger: _controller.entranceTriggerFor(HomeTab.stats), // İstatistik Sekmesinin Giriş Animasyonu Tetikleyicisini Verir.
                  scrollController: _scrolls[HomeTab.stats], // İstatistik Sekmesinin ScrollController'ını Verir.
                ),
              ],
            ),
          ),
          bottomNavigationBar: DiguraNavigationBar(selected: state.tab, onSelect: _select), // Seçili Sekmeyle Alt Gezinme Çubuğunu Gösterir.
        );
      },
    );
  }
}
