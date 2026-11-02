import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // Renk Token'larını import Eder.
import '../../../core/constants/app_icons.dart'; // Uygulama İkon Tanımlarını (AppIcons) import Eder.
import '../../../core/constants/app_motion.dart'; // Süre ve Curve Token'larını (AppMotion) import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Görünen Metinleri (AppStrings) import Eder.
import '../../../core/theme/app_theme.dart'; // palette ve AppTypography'yi import Eder.
import '../../../core/widgets/app_icon.dart'; // SVG Tabanlı AppIcon Widget'ını import Eder.
import '../../../core/widgets/pressable.dart'; // Basma Ölçekli Dokunma Widget'ı Pressable'ı import Eder.
import '../models/mood_calendar_model.dart'; // CalendarMode enum'ını import Eder.

/// Ay / Yıl segment seçici: min 44, hap; seçili `borderSoft` zemin + 600 + onay.
class ViewSegment extends StatelessWidget { // Ay ve Yıl Görünümü Arasında Seçim Yapan StatelessWidget'tır.
  final CalendarMode mode; // Seçili Görünüm Modudur.
  final ValueChanged<CalendarMode> onChanged; // Mod Değiştiğinde Çağrılan Callback'tir.

  const ViewSegment({super.key, required this.mode, required this.onChanged}); // key'i Superclass'a İleten ve Field'ları required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Segment Seçicinin Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    return Semantics( // Seçiciyi Etiketli Bir Semantik Grup Yapar.
      label: AppStrings.viewLabel, // Grubun Erişilebilirlik Etiketini Verir.
      container: true, // Ayrı Bir Semantik Kapsayıcı Oluşturur.
      child: Container( // Hap Şeklindeki Dış Kabı Oluşturur.
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14), // Dış Boşluğu Verir.
        padding: const EdgeInsets.all(3), // İç Boşluğu Verir.
        decoration: ShapeDecoration( // Hap Şekilli Dekorasyonu Tanımlar.
          color: p.surface, // Yüzey Rengini Verir.
          shape: StadiumBorder(side: BorderSide(color: p.border)), // Kenarlıklı Hap Şekli Çizer.
        ),
        child: Row( // İki Segment Butonunu Yatay Dizer.
          children: [ // Satır Çocuklarıdır.
            Expanded( // Ay Butonunu Yarı Genişliğe Yayar.
              child: _SegmentButton( // Ay Segment Butonunu Oluşturur.
                label: AppStrings.viewMonth, // Ay Etiketini Verir.
                selected: mode == CalendarMode.month, // Ay Modu Seçiliyse true Verir.
                onTap: () => onChanged(CalendarMode.month), // Dokununca Ay Moduna Geçer.
              ),
            ),
            Expanded( // Yıl Butonunu Yarı Genişliğe Yayar.
              child: _SegmentButton( // Yıl Segment Butonunu Oluşturur.
                label: AppStrings.viewYear, // Yıl Etiketini Verir.
                selected: mode == CalendarMode.year, // Yıl Modu Seçiliyse true Verir.
                onTap: () => onChanged(CalendarMode.year), // Dokununca Yıl Moduna Geçer.
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget { // Tek Bir Segment Butonunu Gösteren StatelessWidget'tır.
  final String label; // Buton Etiketidir.
  final bool selected; // Butonun Seçili Olup Olmadığıdır.
  final VoidCallback onTap; // Dokunma Callback'idir.

  const _SegmentButton({required this.label, required this.selected, required this.onTap}); // Field'ları required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Segment Butonunun Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    final color = selected ? p.fg : p.muted; // Seçiliyse Ön Plan, Değilse Soluk Rengi Seçer.
    return Pressable( // Basma Ölçekli Dokunulabilir Alan Oluşturur.
      onTap: onTap, // Dokunma Callback'ini Verir.
      selected: selected, // Seçili Durumunu Semantiğe Bildirir.
      semanticLabel: label, // Erişilebilirlik Etiketini Verir.
      child: AnimatedContainer( // Seçim Değişiminde Zemini Animasyonla Değiştirir.
        duration: AppMotion.press, // Animasyon Süresini Verir.
        curve: AppMotion.easeOut, // Animasyon Curve'ünü Verir.
        constraints: const BoxConstraints(minHeight: 44), // En Az 44 px Dokunma Yüksekliği Sağlar.
        decoration: ShapeDecoration(shape: const StadiumBorder(), color: selected ? p.borderSoft : Colors.transparent), // Seçiliyse borderSoft Zeminli Hap Çizer.
        alignment: Alignment.center, // İçeriği Ortalar.
        child: Row( // Onay İkonu ve Etiketi Yatay Dizer.
          mainAxisSize: MainAxisSize.min, // Genişliği İçerik Kadar Tutar.
          children: [ // Satır Çocuklarıdır.
            if (selected) ...[AppIcon(AppIcons.check, size: 16, color: color), const SizedBox(width: 6)], // Seçiliyse Onay İkonu ve Boşluk Ekler.
            Text( // Buton Etiketini Gösterir.
              label, // Etiket Metnidir.
              style: AppTypography.body( // Etiket Stilini Tanımlar.
                14, // Font Boyutudur.
                height: 1.4, // Satır Yüksekliğidir.
                weight: selected ? FontWeight.w600 : FontWeight.w500, // Seçiliyse Daha Kalın Yazar.
                color: color, // Metin Rengini Verir.
              ),
            ),
          ],
        ),
      ),
    );
  }
}
