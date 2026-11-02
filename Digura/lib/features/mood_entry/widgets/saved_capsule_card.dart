import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // palette Uzantısını import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Gösterilen AppStrings Metinlerini import Eder.
import '../../../core/theme/app_theme.dart'; // AppTypography Yazı Stillerini import Eder.
import '../../../core/widgets/layout_parts.dart'; // AppCard, CapsuleLine ve CapsuleProgressBar Widget'larını import Eder.
import '../models/mood_entry_model.dart'; // MoodEntry Model Class'ını import Eder.

/// Kayıttan sonra Bugün'deki kilitli kapsül kartı. Not metni burada da
/// gösterilmez; yalnızca notlu/notsuz bilgisi, açılış tarihi ve ilerleme.
class SavedCapsuleCard extends StatelessWidget { // Bugünün Kilitli Kapsül Bilgisini Gösteren StatelessWidget'tır.
  final MoodEntry entry; // Gösterilen Günün Kaydıdır.
  final DateTime today; // Kalan Süre Hesabında Kullanılan Bugündür.

  const SavedCapsuleCard({super.key, required this.entry, required this.today}); // entry ve today'i required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Kartın Widget Tree'sini Oluşturan Metottur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    final remaining = entry.remainingDays(today); // Açılışa Kalan Gün Sayısını Hesaplar.
    final meta = AppTypography.mono(12, color: p.muted); // Alt Bilgiler İçin Soluk Mono Stili Oluşturur.
    return AppCard( // Kart Kapsayıcısını Döndürür.
      child: Column( // Kart İçeriğini Dikey Dizer.
        crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
        children: [ // Kart Öğelerinin Listesidir.
          CapsuleLine( // Kapsül Başlığı ve Açılış Tarihini Gösterir.
            title: entry.hasNote ? AppStrings.noteSealed : AppStrings.noNoteToday, // Not Varsa Mühürlendi, Yoksa Notsuz Metnini Seçer.
            unlockDate: entry.unlockDate, // Notun Açılacağı Tarihi Verir.
          ),
          const SizedBox(height: 12), // Başlık ile İlerleme Çubuğu Arasına 12 px Boşluk Koyar.
          CapsuleProgressBar(value: entry.lockProgress(today)), // Kilit İlerlemesini Çubukla Gösterir.
          const SizedBox(height: 12), // Çubuk ile Alt Satır Arasına 12 px Boşluk Koyar.
          Row( // Kalan Gün ve İlerleme Metinlerini Yatay Dizer.
            children: [ // Alt Satır Öğelerinin Listesidir.
              Expanded(child: Text(AppStrings.capsuleRemaining(remaining), style: meta)), // Kalan Gün Metnini Gösterir.
              Text(AppStrings.lockProgress(MoodEntry.lockDays - remaining, MoodEntry.lockDays), style: meta), // Geçen/Toplam Gün Metnini Gösterir.
            ],
          ),
        ],
      ),
    );
  }
}
