import 'dart:async'; // Timer Class'ını Sağlayan Dart async Kütüphanesini import Eder.

import 'package:flutter/foundation.dart'; // ValueNotifier ve ValueListenable Tiplerini import Eder.
import 'package:flutter/widgets.dart'; // Listenable ve characters Uzantısı İçin Flutter Widgets Kütüphanesini import Eder.

import '../../../core/constants/app_colors.dart'; // Mood enum'unu import Eder.
import '../../../core/constants/app_motion.dart'; // AppMotion Süre Sabitlerini import Eder.
import '../../../core/data/mood_repository.dart'; // Kayıtlara Erişen MoodRepository Class'ını import Eder.
import '../models/mood_entry_draft_model.dart'; // Kaydedilmemiş Seçimi Tutan MoodEntryDraftModel'i import Eder.
import '../models/mood_entry_model.dart'; // MoodEntry Model Class'ını import Eder.

enum SaveOutcome { saved, alreadySaved, noMood } // Kayıt Denemesinin Olası Sonuçlarını Tanımlayan enum'dur.

/// Bugün sekmesinin iş mantığı: seçim, tek cümle kuralı ve günde bir kayıt.
class MoodEntryController { // Bugün Sekmesinin Durumunu Yöneten Controller Class'ıdır.
  final MoodRepository _repository; // Kayıtların Okunup Yazıldığı Repository'dir.
  final ValueListenable<DateTime> _today; // Güncel Günü Yayınlayan ValueListenable'dır.

  final ValueNotifier<MoodEntryDraftModel> draft = ValueNotifier(const MoodEntryDraftModel()); // Seçili Renk ve Notu Tutan Taslak ValueNotifier'ıdır.

  /// Kayıttan hemen sonra dairenin bir kez "yerleşme" animasyonu için.
  final ValueNotifier<bool> savedNow = ValueNotifier(false); // Kaydın Az Önce Yapıldığını Belirten bool ValueNotifier'dır.

  Timer? _savedNowTimer; // savedNow Bayrağını Sıfırlayan Zamanlayıcıdır.

  MoodEntryController(this._repository, this._today); // Repository ve Bugün Kaynağını Alan Constructor'dır.

  /// Bugün değiştiğinde ya da kayıt eklendiğinde yeniden çizim tetikleyicisi.
  Listenable get changes => Listenable.merge([_repository.entries, _today]); // Kayıtlar ve Gün Değişimini Tek Listenable'da Birleştirir.

  DateTime get today => _today.value; // Güncel Günü Döndüren Getter'dır.

  MoodEntry? get savedToday => _repository.entryFor(_today.value); // Bugüne Ait Kaydı Varsa Döndüren Getter'dır.

  void selectMood(Mood mood) => draft.value = draft.value.copyWith(selectedMood: mood); // Seçilen Duyguyu Taslağa Yazar.

  /// Satır sonları boşluğa döner, 140 karakteri aşan kısım kesilir.
  void updateNote(String raw) { // Kullanıcının Yazdığı Notu Taslağa İşleyen Metottur.
    final single = raw.replaceAll(RegExp(r'[\r\n]+'), ' '); // Satır Sonlarını Boşluğa Çevirir.
    final chars = single.characters; // Metni Grafem Bazlı Karakterlere Ayırır.
    final clipped = chars.length > MoodEntryDraftModel.maxNoteLength // Karakter Sayısı Sınırı Aşıyor Mu Kontrol Eder.
        ? chars.take(MoodEntryDraftModel.maxNoteLength).toString() // Aşıyorsa İlk 140 Karakteri Alır.
        : single; // Aşmıyorsa Metni Olduğu Gibi Kullanır.
    draft.value = draft.value.copyWith(note: clipped); // Kırpılmış Notu Taslağa Yazar.
  }

  Future<SaveOutcome> save() async { // Taslağı Bugünün Kaydı Olarak Saklayan async Metottur.
    final mood = draft.value.selectedMood; // Taslaktaki Seçili Duyguyu Alır.
    if (mood == null) return SaveOutcome.noMood; // Duygu Seçilmemişse noMood Döndürür.
    final ok = await _repository.saveToday(mood, draft.value.note.trim()); // Duygu ve Kırpılmış Notu Repository'ye Kaydeder.
    if (!ok) return SaveOutcome.alreadySaved; // Bugün Zaten Kayıt Varsa alreadySaved Döndürür.
    draft.value = const MoodEntryDraftModel(); // Taslağı Sıfırlar.
    savedNow.value = true; // Yerleşme Animasyonu İçin Bayrağı Açar.
    _savedNowTimer?.cancel(); // Önceki Zamanlayıcıyı İptal Eder.
    _savedNowTimer = Timer(AppMotion.savedNowWindow, () => savedNow.value = false); // Süre Dolunca Bayrağı Kapatan Timer Kurar.
    return SaveOutcome.saved; // Başarılı Kayıt Sonucunu Döndürür.
  }

  void dispose() { // Controller Kaynaklarını Serbest Bırakan Metottur.
    _savedNowTimer?.cancel(); // Bekleyen Zamanlayıcıyı İptal Eder.
    draft.dispose(); // draft ValueNotifier'ını dispose Eder.
    savedNow.dispose(); // savedNow ValueNotifier'ını dispose Eder.
  }
}
