import 'dart:math' as math; // max Fonksiyonu İçin dart:math Kütüphanesini math Önekiyle import Eder.

import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // AppPalette ve context.palette Extension'ını import Eder.
import '../../../core/constants/app_motion.dart'; // AppMotion Süre ve Curve Sabitlerini import Eder.
import '../../../core/constants/app_strings.dart'; // Gezinme Etiketi İçin AppStrings'i import Eder.
import '../../../core/theme/app_theme.dart'; // AppTypography Yazı Stillerini import Eder.
import '../../../core/widgets/app_icon.dart'; // SVG Tabanlı AppIcon Widget'ını import Eder.
import '../../../core/widgets/pressable.dart'; // Basılma Durumunu Yöneten Pressable Widget'ını import Eder.
import '../models/home_model.dart'; // HomeTab Enum'unu import Eder.

/// Material 3 alt gezinme çubuğu (DESIGN.md 5): 3 sekme, min 60 px, gösterge
/// 64 × 32 hap, seçili `surfaceWarm`. Basılıyken gösterge 0.94 ölçeklenir.
class DiguraNavigationBar extends StatelessWidget { // Üç Sekmeli Alt Gezinme Çubuğu StatelessWidget'ıdır.
  final HomeTab selected; // Seçili Sekmedir.
  final ValueChanged<HomeTab> onSelect; // Sekmeye Dokunulunca Çağrılan Callback'tir.

  const DiguraNavigationBar({super.key, required this.selected, required this.onSelect}); // selected ve onSelect Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Gezinme Çubuğunun Widget Tree'sini Oluşturur.
    final p = context.palette; // Aktif Temanın Renk Paletini Alır.
    final bottom = math.max(22.0, MediaQuery.viewPaddingOf(context).bottom); // Alt Boşluğu En Az 22 veya Güvenli Alan Kadar Yapar.
    return Semantics( // Çubuğa Erişilebilirlik Bilgisi Ekler.
      container: true, // Çubuğu Ayrı Semantik Kapsayıcı Yapar.
      label: AppStrings.navLabel, // Gezinme Etiketini Ayarlar.
      child: Container( // Çubuğun Zeminli Kutusunu Oluşturur.
        decoration: BoxDecoration( // Çubuğun Görünümünü Tanımlar.
          color: p.surface, // Zemin Rengini surface Yapar.
          border: Border(top: BorderSide(color: p.border)), // Üst Kenara İnce Çizgi Çizer.
        ),
        padding: EdgeInsets.fromLTRB(8, 10, 8, 4 + bottom), // İç Boşlukları Güvenli Alanı Hesaba Katarak Ayarlar.
        child: Row( // Sekme Öğelerini Yan Yana Dizer.
          children: [ // Row'un Çocuk Listesidir.
            for (final tab in HomeTab.values) // Her Sekme İçin Öğe Üretir.
              Expanded( // Öğelerin Genişliği Eşit Paylaşmasını Sağlar.
                child: _NavItem(tab: tab, selected: tab == selected, onTap: () => onSelect(tab)), // Sekme Öğesini Seçililik ve Callback İle Oluşturur.
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget { // Tek Bir Gezinme Sekmesini Çizen StatelessWidget'tır.
  final HomeTab tab; // Öğenin Temsil Ettiği Sekmedir.
  final bool selected; // Öğenin Seçili Olup Olmadığıdır.
  final VoidCallback onTap; // Öğeye Dokunulunca Çağrılan Callback'tir.

  const _NavItem({required this.tab, required this.selected, required this.onTap}); // Tüm Field'ları required Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Sekme Öğesinin Widget Tree'sini Oluşturur.
    final p = context.palette; // Aktif Temanın Renk Paletini Alır.
    final color = selected ? p.fg : p.muted; // Seçiliyse fg, Değilse Soluk Renk Kullanır.
    final reduce = context.reduceMotion; // Hareket Azaltma Tercihini Okur.
    return Pressable( // Dokunma ve Basılma Durumunu Yönetir.
      onTap: onTap, // Dokunulunca onTap'i Çağırır.
      scale: 1, // Tüm Öğenin Ölçeklenmesini Kapatır.
      selected: selected, // Seçili Durumunu Erişilebilirliğe Bildirir.
      semanticLabel: tab.label, // Erişilebilirlik Etiketi Olarak Sekme Adını Kullanır.
      builder: (context, pressed) => ConstrainedBox( // Basılma Durumuna Göre Öğeyi Oluşturur.
        constraints: const BoxConstraints(minHeight: 60), // Asgari Yüksekliği 60 Yapar.
        child: Column( // Gösterge ve Etiketi Dikey Dizer.
          mainAxisSize: MainAxisSize.min, // Yüksekliği İçerik Kadar Tutar.
          children: [ // Column'un Çocuk Listesidir.
            AnimatedScale( // Basılıyken Göstergeyi Animasyonlu Küçültür.
              scale: pressed && !reduce ? AppMotion.pressKey : 1, // Basılıysa ve Hareket Azaltma Kapalıysa pressKey Ölçeğini Uygular.
              duration: AppMotion.press, // Ölçek Geçiş Süresini press Yapar.
              curve: AppMotion.easeOut, // Ölçek Curve'ünü easeOut Yapar.
              child: AnimatedContainer( // Seçim Göstergesi Hapını Oluşturur.
                duration: AppMotion.ui, // Renk Geçiş Süresini ui Yapar.
                curve: AppMotion.easeOut, // Renk Geçiş Curve'ünü easeOut Yapar.
                width: 64, // Gösterge Genişliğini 64 Yapar.
                height: 32, // Gösterge Yüksekliğini 32 Yapar.
                decoration: ShapeDecoration( // Göstergenin Şekil ve Rengini Tanımlar.
                  shape: const StadiumBorder(), // Hap Şekli Verir.
                  color: selected ? p.surfaceWarm : Colors.transparent, // Seçiliyse surfaceWarm, Değilse Şeffaf Yapar.
                ),
                alignment: Alignment.center, // Simgeyi Ortalar.
                child: AppIcon(tab.icon, size: 22, color: color), // Sekme Simgesini Çizer.
              ),
            ),
            const SizedBox(height: 4), // Simge İle Etiket Arasına 4 Boşluk Koyar.
            Text( // Sekme Etiketini Yazar.
              tab.label, // Sekmenin Görünen Adıdır.
              style: AppTypography.body( // Etiket İçin Gövde Stili Oluşturur.
                12, // Yazı Boyutunu 12 Yapar.
                height: 1.4, // Satır Yüksekliğini 1.4 Yapar.
                weight: selected ? FontWeight.w600 : FontWeight.w400, // Seçiliyse Yarı Kalın, Değilse Normal Yapar.
                color: color, // Etiket Rengini Uygular.
              ),
            ),
          ],
        ),
      ),
    );
  }
}
