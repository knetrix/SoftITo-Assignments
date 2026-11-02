import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.
import 'package:flutter/services.dart'; // TextInputFormatter ve TextEditingValue Tiplerini import Eder.

import '../../../core/constants/app_colors.dart'; // palette Uzantısını import Eder.
import '../../../core/constants/app_icons.dart'; // AppIcons Simge Tanımlarını import Eder.
import '../../../core/constants/app_motion.dart'; // AppMotion Süre ve Eğri Sabitlerini import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Gösterilen AppStrings Metinlerini import Eder.
import '../../../core/theme/app_theme.dart'; // AppTypography Yazı Stillerini import Eder.
import '../../../core/widgets/app_icon.dart'; // SVG Tabanlı AppIcon Widget'ını import Eder.
import '../models/mood_entry_draft_model.dart'; // maxNoteLength Sabiti İçin MoodEntryDraftModel'i import Eder.

/// Tek cümle kuralı: satır atlama boşluğa döner, 140 karakter (grafem) üstü kesilir.
class SingleSentenceFormatter extends TextInputFormatter { // Girişi Tek Cümle Kuralına Uyduran TextInputFormatter'dır.
  final int maxLength; // İzin Verilen Azami Karakter Sayısıdır.

  const SingleSentenceFormatter([this.maxLength = MoodEntryDraftModel.maxNoteLength]); // Varsayılan Sınırı 140 Olan const Constructor'dır.

  @override // Superclass'taki formatEditUpdate Metodunun Override Edildiğini Belirtir.
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) { // Her Düzenlemede Yeni Değeri Biçimlendiren Metottur.
    var text = newValue.text.replaceAll(RegExp(r'[\r\n]+'), ' '); // Satır Sonlarını Boşluğa Çevirir.
    final chars = text.characters; // Metni Grafem Bazlı Karakterlere Ayırır.
    if (chars.length > maxLength) text = chars.take(maxLength).toString(); // Sınırı Aşan Kısmı Keser.
    if (text == newValue.text) return newValue; // Metin Değişmediyse Yeni Değeri Aynen Döndürür.
    final offset = newValue.selection.baseOffset.clamp(0, text.length); // İmleç Konumunu Yeni Metin Sınırlarına Çeker.
    return TextEditingValue( // Düzeltilmiş Değeri Döndürür.
      text: text, // Biçimlendirilmiş Metni Verir.
      selection: TextSelection.collapsed(offset: offset), // İmleci Hesaplanan Konuma Yerleştirir.
    );
  }
}

/// Not alanı (`note-field`): 18 px yarıçap, odakta kenar `fg`; altta kilit
/// bilgisi ve mono `0/140` sayaç (sınırda tehlike rengi). Yazarken hareket yok.
class NoteField extends StatefulWidget { // Tek Cümlelik Not Giriş Alanını Oluşturan StatefulWidget'tır.
  final String value; // Alanda Gösterilecek Güncel Not Metnidir.
  final ValueChanged<String> onChanged; // Metin Değiştiğinde Çağrılan Callback'tir.
  final bool showLockIcon; // Alttaki Kilit Simgesinin Gösterilip Gösterilmeyeceğidir.

  const NoteField({super.key, required this.value, required this.onChanged, this.showLockIcon = true}); // value ve onChanged'i required Yapan const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<NoteField> createState() => _NoteFieldState(); // Widget'ın State Nesnesini Oluşturur.
}

class _NoteFieldState extends State<NoteField> { // Not Alanının Durumunu Yöneten State Class'ıdır.
  late final TextEditingController _text = TextEditingController(text: widget.value); // Başlangıç Değeriyle Oluşturulan TextEditingController'dır.
  final FocusNode _focus = FocusNode(); // Alanın Odak Durumunu Takip Eden FocusNode'dur.

  @override // Superclass'taki initState Metodunun Override Edildiğini Belirtir.
  void initState() { // State İlk Oluşturulduğunda Çağrılan Metottur.
    super.initState(); // Superclass'ın initState Metodunu Çağırır.
    _focus.addListener(() => setState(() {})); // Odak Değişince Kenar Rengi İçin Yeniden Çizer.
  }

  @override // Superclass'taki didUpdateWidget Metodunun Override Edildiğini Belirtir.
  void didUpdateWidget(NoteField oldWidget) { // Widget Parametreleri Değiştiğinde Çağrılan Metottur.
    super.didUpdateWidget(oldWidget); // Superclass'ın didUpdateWidget Metodunu Çağırır.
    if (widget.value != _text.text) _text.text = widget.value; // Dış Değer Farklıysa Controller Metnini Eşitler.
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Temizleyen Metottur.
    _text.dispose(); // TextEditingController'ı dispose Eder.
    _focus.dispose(); // FocusNode'u dispose Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Not Alanının Widget Tree'sini Oluşturan Metottur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    final length = widget.value.characters.length; // Notun Grafem Bazlı Uzunluğunu Hesaplar.
    final atLimit = length >= MoodEntryDraftModel.maxNoteLength; // Karakter Sınırına Ulaşılıp Ulaşılmadığını Belirler.
    final small = AppTypography.body(12, height: 1.4, color: p.muted); // Küçük Soluk Yardımcı Yazı Stilini Oluşturur.
    return GestureDetector( // Kutuya Dokunmayı Yakalayan Widget'ı Döndürür.
      onTap: _focus.requestFocus, // Dokunulunca Metin Alanına Odaklanır.
      child: AnimatedContainer( // Kenar Rengini Animasyonlu Değiştiren Kutuyu Oluşturur.
        duration: AppMotion.press, // Geçiş Süresini Belirler.
        curve: AppMotion.easeOut, // Geçiş Eğrisini Belirler.
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10), // Kutu İç Boşluğunu Belirler.
        decoration: BoxDecoration( // Kutunun Görünümünü Tanımlar.
          color: p.surface, // Yüzey Rengini Zemin Yapar.
          borderRadius: BorderRadius.circular(18), // Köşeleri 18 px Yuvarlar.
          border: Border.all(color: _focus.hasFocus ? p.fg : p.border), // Odaktayken Kenarı fg Rengine Çevirir.
        ),
        child: Column( // İçeriği Dikey Dizer.
          crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
          children: [ // Not Alanı İçeriğinin Listesidir.
            Text(AppStrings.noteLabel, style: small), // Üstteki Not Etiketini Gösterir.
            const SizedBox(height: 4), // Etiket ile Metin Alanı Arasına 4 px Boşluk Koyar.
            SizedBox( // Metin Alanına Sabit Yükseklik Verir.
              height: 46, // Yüksekliği 46 Yapar.
              child: TextField( // Notun Yazıldığı TextField'dır.
                controller: _text, // Metni Yöneten Controller'ı Bağlar.
                focusNode: _focus, // Odak Takibi İçin FocusNode'u Bağlar.
                onChanged: widget.onChanged, // Metin Değişince onChanged Callback'ini Çağırır.
                inputFormatters: const [SingleSentenceFormatter()], // Tek Cümle Kuralını Uygular.
                minLines: 2, // Asgari İki Satır Gösterir.
                maxLines: 2, // Azami İki Satır Gösterir.
                keyboardType: TextInputType.text, // Düz Metin Klavyesi Açar.
                textInputAction: TextInputAction.done, // Klavyede Bitti Eylemini Gösterir.
                textCapitalization: TextCapitalization.sentences, // Cümle Başlarını Büyük Harf Yapar.
                style: AppTypography.body(16, height: 1.4, color: p.fg), // 16 px Gövde Yazı Stilini Uygular.
                cursorColor: p.fg, // İmleç Rengini fg Yapar.
                decoration: InputDecoration( // Alanın Süslemesini Tanımlar.
                  isCollapsed: true, // Varsayılan İç Boşlukları Kaldırır.
                  border: InputBorder.none, // Kenar Çizgisini Kaldırır.
                  hintText: AppStrings.notePlaceholder, // Boşken Gösterilen İpucu Metnini Verir.
                  hintStyle: AppTypography.body(16, height: 1.4, color: p.muted), // İpucu Metnini Soluk Gösterir.
                  contentPadding: EdgeInsets.zero, // İçerik Boşluğunu Sıfırlar.
                ),
              ),
            ),
            const SizedBox(height: 6), // Metin Alanı ile Alt Satır Arasına 6 px Boşluk Koyar.
            Row( // Kilit Bilgisi ve Sayacı Yatay Dizer.
              children: [ // Alt Satır Öğelerinin Listesidir.
                if (widget.showLockIcon) ...[ // İstenirse Kilit Simgesini Ekler.
                  AppIcon(AppIcons.lock, size: 14, color: p.muted), // Soluk Kilit Simgesini Çizer.
                  const SizedBox(width: 5), // Simge ile Metin Arasına 5 px Boşluk Koyar.
                ],
                Expanded(child: Text(AppStrings.noteLocked, style: small)), // Notun Kilitleneceğini Belirten Metni Gösterir.
                Text( // Karakter Sayacını Gösterir.
                  AppStrings.noteCount(length, MoodEntryDraftModel.maxNoteLength), // Güncel/Azami Karakter Metnini Üretir.
                  style: AppTypography.mono( // Mono Yazı Stilini Uygular.
                    12, // Yazı Boyutunu 12 Yapar.
                    weight: atLimit ? FontWeight.w600 : FontWeight.w400, // Sınırdaysa Kalın Yazar.
                    color: atLimit ? p.danger : p.muted, // Sınırdaysa Tehlike Rengi Kullanır.
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
