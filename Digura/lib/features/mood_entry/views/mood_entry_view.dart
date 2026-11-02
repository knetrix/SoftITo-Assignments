import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // Mood enum'u ve palette Uzantısını import Eder.
import '../../../core/constants/app_icons.dart'; // AppIcons Simge Tanımlarını import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Gösterilen AppStrings Metinlerini import Eder.
import '../../../core/theme/app_theme.dart'; // AppTypography Yazı Stillerini import Eder.
import '../../../core/utils/clock.dart'; // Tarih Biçimlendirme İçin DateHelpers'ı import Eder.
import '../../../core/widgets/app_buttons.dart'; // PrimaryButton, AppTextButton ve AppIconButton Widget'larını import Eder.
import '../../../core/widgets/app_scope.dart'; // Servislere Erişim Sağlayan AppScope'u import Eder.
import '../../../core/widgets/app_snack.dart'; // showAppSnack Bildirim Fonksiyonunu import Eder.
import '../../../core/widgets/entrance.dart'; // EntranceScope ve EntranceItem Giriş Animasyonu Widget'larını import Eder.
import '../../../core/widgets/layout_parts.dart'; // ScreenHeader ve InfoHint Gibi Yerleşim Parçalarını import Eder.
import '../controllers/mood_entry_controller.dart'; // MoodEntryController ve SaveOutcome'u import Eder.
import '../models/mood_entry_draft_model.dart'; // MoodEntryDraftModel'i import Eder.
import '../models/mood_entry_model.dart'; // MoodEntry Model Class'ını import Eder.
import '../widgets/mood_orb.dart'; // MoodOrb Renk Dairesi Widget'ını import Eder.
import '../widgets/mood_swatch_picker.dart'; // MoodSwatchPicker Duygu Seçici Widget'ını import Eder.
import '../widgets/note_field.dart'; // NoteField Not Alanı Widget'ını import Eder.
import '../widgets/save_confirm_dialog.dart'; // SaveConfirmDialog Onay Diyaloğunu import Eder.
import '../widgets/saved_capsule_card.dart'; // SavedCapsuleCard Kapsül Kartı Widget'ını import Eder.

/// Bugün sekmesi: renk dairesi, 5 duygu seçici, 140 karakterlik not ve
/// onaylı kayıt; kayıttan sonra kilitli kapsül kartı.
class MoodEntryView extends StatefulWidget { // Bugün Sekmesi Ekranını Oluşturan StatefulWidget'tır.
  final Object? entranceTrigger; // Giriş Animasyonunu Yeniden Tetikleyen Değerdir.
  final VoidCallback onOpenSettings; // Ayarlar Ekranını Açan Callback'tir.
  final VoidCallback onShowMap; // Takvim Haritasına Geçiren Callback'tir.
  final ScrollController? scrollController; // Kaydırmayı Dışarıdan Kontrol Eden İsteğe Bağlı ScrollController'dır.

  const MoodEntryView({ // MoodEntryView'in const Constructor'ıdır.
    super.key, // key Parametresini Superclass'a İletir.
    required this.onOpenSettings, // onOpenSettings Field'ını required Yapar.
    required this.onShowMap, // onShowMap Field'ını required Yapar.
    this.entranceTrigger, // İsteğe Bağlı entranceTrigger Field'ını Atar.
    this.scrollController, // İsteğe Bağlı scrollController Field'ını Atar.
  });

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<MoodEntryView> createState() => _MoodEntryViewState(); // Widget'ın State Nesnesini Oluşturur.
}

class _MoodEntryViewState extends State<MoodEntryView> { // MoodEntryView'in Durumunu Yöneten State Class'ıdır.
  MoodEntryController? _controller; // Ekranın İş Mantığını Taşıyan Controller'dır.

  MoodEntryController get controller => _controller!; // Oluşturulmuş Controller'ı null Olmadan Döndüren Getter'dır.

  @override // Superclass'taki didChangeDependencies Metodunun Override Edildiğini Belirtir.
  void didChangeDependencies() { // Bağımlılıklar Hazır Olduğunda Çağrılan Metottur.
    super.didChangeDependencies(); // Superclass'ın didChangeDependencies Metodunu Çağırır.
    if (_controller == null) { // Controller Henüz Oluşturulmadıysa Kontrol Eder.
      final services = AppScope.of(context); // AppScope'tan Uygulama Servislerini Alır.
      _controller = MoodEntryController(services.moods, services.today); // Repository ve Bugün Kaynağıyla Controller Oluşturur.
    }
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Temizleyen Metottur.
    _controller?.dispose(); // Controller'ı dispose Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  Future<void> _askSave() async { // Onay Alarak Kaydı Gerçekleştiren async Metottur.
    final draft = controller.draft.value; // Güncel Taslağı Alır.
    final mood = draft.selectedMood; // Taslaktaki Seçili Duyguyu Alır.
    if (mood == null) return; // Duygu Seçilmemişse İşlemi Sonlandırır.
    FocusScope.of(context).unfocus(); // Klavyeyi Kapatmak İçin Odağı Kaldırır.
    final confirmed = await SaveConfirmDialog.show(context, mood: mood, hasNote: draft.hasNote); // Kayıt Onay Diyaloğunu Gösterir.
    if (!confirmed || !mounted) return; // Onaylanmadıysa Ya Da Widget Kaldırıldıysa Çıkar.
    final outcome = await controller.save(); // Taslağı Kaydeder ve Sonucu Alır.
    if (!mounted) return; // Widget Kaldırıldıysa Çıkar.
    showAppSnack(context, outcome == SaveOutcome.saved ? AppStrings.savedSnack : AppStrings.alreadySavedSnack); // Sonuca Göre Bildirim Gösterir.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Ekranın Widget Tree'sini Oluşturan Metottur.
    return GestureDetector( // Boş Alana Dokunmayı Yakalayan Widget'ı Döndürür.
      onTap: () => FocusScope.of(context).unfocus(), // Dokunulunca Klavyeyi Kapatır.
      behavior: HitTestBehavior.translucent, // Alttaki Widget'ların da Dokunuş Almasına İzin Verir.
      child: EntranceScope( // Alt Öğelerin Giriş Animasyonunu Yöneten Kapsamdır.
        trigger: widget.entranceTrigger, // Animasyonu Yeniden Başlatan Tetikleyiciyi Verir.
        child: ListenableBuilder( // Kayıt ve Gün Değişikliklerinde Yeniden Çizer.
          listenable: controller.changes, // Dinlenecek Birleşik Listenable'ı Verir.
          builder: (context, _) { // Değişiklikte Çalışan builder Callback'idir.
            final saved = controller.savedToday; // Bugünün Kaydını Alır.
            return SingleChildScrollView( // Kaydırılabilir İçerik Döndürür.
              controller: widget.scrollController, // Dışarıdan Gelen ScrollController'ı Bağlar.
              padding: const EdgeInsets.only(top: 4, bottom: 24), // Üst ve Alt Boşluğu Belirler.
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // Kaydırınca Klavyeyi Kapatır.
              child: saved == null ? _buildDraft() : _buildSaved(saved), // Kayıt Yoksa Taslağı, Varsa Kayıtlı Görünümü Gösterir.
            );
          },
        ),
      ),
    );
  }

  Widget _header(String title) => ScreenHeader( // Tarih ve Başlık İçeren Ekran Başlığını Oluşturur.
    eyebrow: DateHelpers.formatWithWeekday(controller.today), // Üst Satıra Haftanın Günüyle Tarihi Yazar.
    title: title, // Başlık Metnini Verir.
    trailing: AppIconButton( // Sağdaki Ayarlar Butonunu Oluşturur.
      icon: AppIcons.gear, // Dişli Simgesini Kullanır.
      iconSize: 22, // Simge Boyutunu 22 Yapar.
      tooltip: AppStrings.settingsTooltip, // Erişilebilirlik İpucu Metnini Verir.
      onPressed: widget.onOpenSettings, // Basılınca Ayarları Açar.
    ),
  );

  Widget _buildDraft() { // Kayıt Öncesi Seçim Görünümünü Oluşturan Metottur.
    return ValueListenableBuilder<MoodEntryDraftModel>( // Taslak Değiştikçe Yeniden Çizer.
      valueListenable: controller.draft, // Dinlenecek Taslak ValueNotifier'ını Verir.
      builder: (context, draft, _) { // Güncel Taslakla Çalışan builder Callback'idir.
        final mood = draft.selectedMood; // Seçili Duyguyu Alır.
        return Column( // Öğeleri Dikey Dizen Column Döndürür.
          crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
          children: [ // Taslak Ekranının Öğe Listesidir.
            EntranceItem(index: 0, child: _header(AppStrings.todayTitle)), // İlk Sırada Bugün Başlığını Gösterir.
            EntranceItem( // İkinci Sıradaki Animasyonlu Öğedir.
              index: 1, // Giriş Sırasını 1 Yapar.
              child: _OrbBlock( // Renk Dairesi ve Başlık Bloğunu Gösterir.
                orb: MoodOrb(mood: mood), // Seçili Duyguyla Daireyi Çizer.
                title: mood?.label ?? AppStrings.pickColor, // Duygu Adını Ya Da Renk Seç Metnini Gösterir.
                titleMuted: mood == null, // Seçim Yoksa Başlığı Soluk Gösterir.
                meta: mood == null ? AppStrings.pickColorHint : AppStrings.selectedMood, // Duruma Göre Alt Bilgiyi Seçer.
              ),
            ),
            EntranceItem( // Üçüncü Sıradaki Animasyonlu Öğedir.
              index: 2, // Giriş Sırasını 2 Yapar.
              child: MoodSwatchPicker(selected: mood, onSelect: controller.selectMood), // Beşli Duygu Seçiciyi Gösterir.
            ),
            EntranceItem( // Dördüncü Sıradaki Animasyonlu Öğedir.
              index: 3, // Giriş Sırasını 3 Yapar.
              child: Padding( // Not Alanına Kenar Boşluğu Verir.
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0), // Yatay 20, Üst 22 Boşluk Uygular.
                child: NoteField(value: draft.note, onChanged: controller.updateNote), // Not Alanını Taslağa Bağlar.
              ),
            ),
            EntranceItem( // Beşinci Sıradaki Animasyonlu Öğedir.
              index: 4, // Giriş Sırasını 4 Yapar.
              child: Padding( // Kaydet Butonuna Kenar Boşluğu Verir.
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0), // Yatay 20, Üst 18 Boşluk Uygular.
                child: PrimaryButton(label: AppStrings.saveColor, onPressed: draft.canSave ? _askSave : null), // Duygu Seçiliyse Etkin Kaydet Butonunu Gösterir.
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSaved(MoodEntry saved) { // Kayıt Sonrası Görünümü Oluşturan Metottur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    return Column( // Öğeleri Dikey Dizen Column Döndürür.
      crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
      children: [ // Kayıtlı Ekranın Öğe Listesidir.
        EntranceItem(index: 0, child: _header(AppStrings.todaySavedTitle)), // İlk Sırada Kaydedildi Başlığını Gösterir.
        EntranceItem( // İkinci Sıradaki Animasyonlu Öğedir.
          index: 1, // Giriş Sırasını 1 Yapar.
          child: _OrbBlock( // Renk Dairesi ve Başlık Bloğunu Gösterir.
            orb: MoodOrb(mood: saved.mood, showCheck: true, popOnMount: controller.savedNow.value), // Onay İşaretli Daireyi, Yeni Kayıtsa Yerleşme Animasyonuyla Çizer.
            title: saved.mood.label, // Kaydedilen Duygunun Adını Gösterir.
            meta: AppStrings.savedPermanent, // Kaydın Kalıcı Olduğunu Belirten Alt Bilgiyi Gösterir.
          ),
        ),
        EntranceItem( // Üçüncü Sıradaki Animasyonlu Öğedir.
          index: 2, // Giriş Sırasını 2 Yapar.
          child: Padding( // Kapsül Kartına Kenar Boşluğu Verir.
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0), // Yatay 20, Üst 18 Boşluk Uygular.
            child: SavedCapsuleCard(entry: saved, today: controller.today), // Kilitli Kapsül Kartını Gösterir.
          ),
        ),
        EntranceItem( // Dördüncü Sıradaki Animasyonlu Öğedir.
          index: 3, // Giriş Sırasını 3 Yapar.
          child: Padding( // Harita Butonuna Kenar Boşluğu Verir.
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0), // Yatay 20, Üst 14 Boşluk Uygular.
            child: Center( // Butonu Ortalar.
              child: AppTextButton.strong( // Vurgulu Metin Butonunu Oluşturur.
                label: AppStrings.seeOnMap, // Haritada Gör Etiketini Verir.
                trailingIcon: AppIcons.right, // Sağa Ok Simgesini Ekler.
                color: p.fg, // Ön Plan Rengini Kullanır.
                onPressed: widget.onShowMap, // Basılınca Haritayı Gösterir.
              ),
            ),
          ),
        ),
        const EntranceItem(index: 4, child: InfoHint.textOnly(text: AppStrings.tomorrowHint)), // Son Sırada Yarın İçin Bilgi Notunu Gösterir.
      ],
    );
  }
}

/// Daire + başlık + mono alt bilgi (`orb-wrap`).
class _OrbBlock extends StatelessWidget { // Daireyi, Başlığı ve Alt Bilgiyi Bir Arada Gösteren StatelessWidget'tır.
  final Widget orb; // Gösterilecek Daire Widget'ıdır.
  final String title; // Daire Altındaki Başlık Metnidir.
  final bool titleMuted; // Başlığın Soluk Gösterilip Gösterilmeyeceğidir.
  final String meta; // Başlık Altındaki Mono Alt Bilgidir.

  const _OrbBlock({required this.orb, required this.title, required this.meta, this.titleMuted = false}); // orb, title ve meta'yı required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Bloğun Widget Tree'sini Oluşturan Metottur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    return Padding( // Bloğa Dikey Boşluk Veren Padding Döndürür.
      padding: const EdgeInsets.only(top: 6, bottom: 18), // Üst 6, Alt 18 Boşluk Uygular.
      child: Column( // Öğeleri Dikey Dizer.
        children: [ // Bloğun Öğe Listesidir.
          orb, // Renk Dairesini Yerleştirir.
          const SizedBox(height: 14), // Daire ile Metin Arasına 14 px Boşluk Koyar.
          ConstrainedBox( // Metin Alanına Asgari Yükseklik Verir.
            constraints: const BoxConstraints(minHeight: 52), // Asgari Yüksekliği 52 Yapar.
            child: Semantics( // Erişilebilirlik Bilgisi Ekler.
              liveRegion: true, // Değişikliklerin Ekran Okuyucuya Duyurulmasını Sağlar.
              child: Column( // Başlık ve Alt Bilgiyi Dikey Dizer.
                children: [ // Metin Öğelerinin Listesidir.
                  ConstrainedBox( // Başlığa Asgari Yükseklik Verir.
                    constraints: const BoxConstraints(minHeight: 27), // Asgari Yüksekliği 27 Yapar.
                    child: Text( // Başlık Metnini Gösterir.
                      title, // Gösterilecek Başlıktır.
                      textAlign: TextAlign.center, // Metni Ortalar.
                      style: AppTypography.display( // Display Yazı Stilini Uygular.
                        22, // Yazı Boyutunu 22 Yapar.
                        height: 1.2, // Satır Yüksekliğini 1.2 Yapar.
                        tracking: -0.015, // Harf Aralığını Hafifçe Daraltır.
                        color: titleMuted ? p.muted : p.fg, // Duruma Göre Soluk Ya Da Normal Renk Seçer.
                      ),
                    ),
                  ),
                  const SizedBox(height: 6), // Başlık ile Alt Bilgi Arasına 6 px Boşluk Koyar.
                  Text( // Alt Bilgi Metnini Gösterir.
                    meta, // Gösterilecek Alt Bilgidir.
                    textAlign: TextAlign.center, // Metni Ortalar.
                    style: AppTypography.mono(12, color: p.muted), // 12 px Soluk Mono Stil Uygular.
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
