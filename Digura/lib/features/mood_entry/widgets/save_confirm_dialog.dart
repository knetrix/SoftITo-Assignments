import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // Mood enum'u ve palette Uzantısını import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Gösterilen AppStrings Metinlerini import Eder.
import '../../../core/theme/app_theme.dart'; // AppTypography Yazı Stillerini import Eder.
import '../../../core/widgets/app_buttons.dart'; // AppTextButton Widget'ını import Eder.
import '../../../core/widgets/app_dialog.dart'; // AppDialog ve showAppDialog'u import Eder.

/// Geri alınamaz eylem onayı: kayıt düzenlenemez ve silinemez.
class SaveConfirmDialog extends StatelessWidget { // Kayıt Öncesi Onay İsteyen Diyalog StatelessWidget'ıdır.
  final Mood mood; // Kaydedilecek Duygudur.
  final bool hasNote; // Kayıtta Not Olup Olmadığıdır.

  const SaveConfirmDialog({super.key, required this.mood, required this.hasNote}); // mood ve hasNote'u required Yapan const Constructor'dır.

  static Future<bool> show(BuildContext context, {required Mood mood, required bool hasNote}) async { // Diyaloğu Açıp Kullanıcı Kararını Döndüren static Metottur.
    final result = await showAppDialog<bool>( // Diyaloğu Gösterir ve Sonucu Bekler.
      context: context, // Diyaloğun Açılacağı context'i Verir.
      builder: (_) => SaveConfirmDialog(mood: mood, hasNote: hasNote), // Diyalog İçeriğini Oluşturur.
    );
    return result ?? false; // Diyalog Kapatıldıysa false Döndürür.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Diyaloğun Widget Tree'sini Oluşturan Metottur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    return AppDialog( // Uygulama Diyaloğunu Döndürür.
      title: AppStrings.confirmTitle, // Onay Başlığını Verir.
      body: Column( // Gövde İçeriğini Dikey Dizer.
        crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
        children: [ // Gövde Öğelerinin Listesidir.
          Text(AppStrings.confirmBody, style: AppTypography.body(15, height: 1.4, color: p.muted)), // Geri Alınamazlık Açıklamasını Gösterir.
          const SizedBox(height: 16), // Açıklama ile Özet Arasına 16 px Boşluk Koyar.
          Container( // Kayıt Özetini Gösteren Kutudur.
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Kutu İç Boşluğunu Belirler.
            decoration: BoxDecoration(color: p.borderSoft, borderRadius: BorderRadius.circular(14)), // Yumuşak Zemin ve Yuvarlak Köşe Verir.
            child: Row( // Renk Karesi ve Metni Yatay Dizer.
              children: [ // Özet Satırı Öğelerinin Listesidir.
                Container( // Duygu Rengini Gösteren Küçük Karedir.
                  width: 18, // Genişliği 18 Yapar.
                  height: 18, // Yüksekliği 18 Yapar.
                  decoration: BoxDecoration(color: p.mood(mood), borderRadius: BorderRadius.circular(6)), // Duygu Rengiyle Yuvarlak Köşeli Kare Çizer.
                ),
                const SizedBox(width: 10), // Kare ile Metin Arasına 10 px Boşluk Koyar.
                Expanded( // Metnin Kalan Genişliği Almasını Sağlar.
                  child: Text.rich( // Farklı Stilli Parçalardan Metin Oluşturur.
                    TextSpan( // Kök TextSpan'dır.
                      children: [ // Metin Parçalarının Listesidir.
                        TextSpan( // Duygu Adı Parçasıdır.
                          text: mood.label, // Duygu Adını Yazar.
                          style: const TextStyle(fontWeight: FontWeight.w600), // Duygu Adını Kalın Yazar.
                        ),
                        TextSpan(text: ' · ${hasNote ? AppStrings.withNote : AppStrings.withoutNote}'), // Notlu Ya Da Notsuz Bilgisini Ekler.
                      ],
                    ),
                    style: AppTypography.body(14, height: 1.4, color: p.fg), // Metnin Temel Stilini Belirler.
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4), // Gövde Sonuna 4 px Boşluk Koyar.
        ],
      ),
      actions: [ // Diyalog Butonlarının Listesidir.
        AppTextButton.strong(label: AppStrings.cancel, color: p.fg, onPressed: () => Navigator.of(context).pop(false)), // Vazgeç Butonu Diyaloğu false İle Kapatır.
        AppTextButton.strong( // Kaydet Butonunu Oluşturur.
          label: AppStrings.save, // Kaydet Etiketini Verir.
          color: p.accentOn, // Vurgu Üzeri Metin Rengini Kullanır.
          background: p.accent, // Vurgu Rengini Zemin Yapar.
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Butonun İç Boşluğunu Belirler.
          onPressed: () => Navigator.of(context).pop(true), // Basılınca Diyaloğu true İle Kapatır.
        ),
      ],
    );
  }
}
