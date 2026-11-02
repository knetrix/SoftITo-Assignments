import 'package:flutter/foundation.dart'; // ValueNotifier Class'ını import Eder.

import '../../features/mood_entry/models/mood_entry_model.dart'; // MoodEntry Model Class'ını import Eder.
import '../constants/app_colors.dart'; // Mood Enum'unu import Eder.
import '../utils/clock.dart'; // Clock ve DateHelpers Class'larını import Eder.
import 'mock_mood_data.dart'; // MockMoodData Örnek Veri Üretecini import Eder.
import 'preferences_service.dart'; // PreferencesService Kalıcı Depolama Class'ını import Eder.

/// Günlük kayıtlar için tek veri erişim noktası.
///
/// Günde yalnızca bir kayıt yapılır; kayıtlar düzenlenemez ve silinemez
/// (yalnızca "Her şeyi sil" ve "Örnek veriye dön" toplu işlemleri hariç).
class MoodRepository { // Günlük Kayıtlara Tek Erişim Noktası Olan Repository'dir.
  final PreferencesService _prefs; // Kayıtların Kalıcı Saklandığı Tercih Servisidir.
  final Clock _clock; // Bugünü Hesaplamak İçin Kullanılan Zaman Kaynağıdır.

  final ValueNotifier<Map<String, MoodEntry>> entries; // Gün Anahtarına Göre Kayıtları Yayınlayan Notifier'dır.

  /// Açılış anı (`CircleReveal`) oynatılmış kapsül kimlikleri.
  final ValueNotifier<Set<String>> openedCapsules; // Açılış Animasyonu Oynatılmış Kapsül id'lerini Yayınlar.

  MoodRepository(this._prefs, this._clock, {bool seedMockData = true}) // Tercih Servisi, Clock ve Örnek Veri Bayrağını Alan Constructor'dır.
    : entries = ValueNotifier(const {}), // entries'i Boş Map İle Başlatır.
      openedCapsules = ValueNotifier(const {}) { // openedCapsules'ı Boş Set İle Başlatır.
    if (!_prefs.hasStoredEntries && seedMockData) { // Kayıtlı Veri Yoksa ve Örnek Veri İsteniyorsa Çalışır.
      entries.value = Map.unmodifiable(MockMoodData.generate(_clock.today())); // Örnek Kayıtları Üretip Atar.
      _persist(); // Örnek Kayıtları Kalıcı Depoya Yazar.
    } else { // Aksi Halde Kayıtlı Veriyi Yükler.
      entries.value = Map.unmodifiable({ // Depodaki JSON Kayıtlarından Değiştirilemez Map Oluşturur.
        for (final json in _prefs.readEntries()) (json['id'] as String): MoodEntry.fromJson(json), // Her JSON'u id Anahtarıyla MoodEntry'ye Çevirir.
      });
    }
    openedCapsules.value = Set.unmodifiable(_prefs.openedCapsules); // Açılmış Kapsülleri Depodan Yükler.
  }

  MoodEntry? getByDayKey(String dayKey) => entries.value[dayKey]; // Gün Anahtarına Göre Kaydı Döndürür.

  MoodEntry? entryFor(DateTime day) => entries.value[DateHelpers.dayKey(day)]; // Verilen Günün Kaydını Döndürür.

  /// Günde yalnızca bir kayıt; mevcut kaydın üzerine yazılmaz.
  Future<bool> addEntry(MoodEntry entry) async { // Yeni Kaydı Ekler, Gün Doluysa false Döndürür.
    if (entries.value.containsKey(entry.id)) return false; // O Gün Zaten Kayıt Varsa false Döndürür.
    final clean = entry.copyWith(note: MoodEntry.sanitizeNote(entry.note)); // Notu Temizlenmiş Kopya Oluşturur.
    entries.value = Map.unmodifiable({...entries.value, clean.id: clean}); // Yeni Kaydı Map'e Ekleyip Yayınlar.
    await _persist(); // Kayıtları Kalıcı Depoya Yazar.
    return true; // Eklemenin Başarılı Olduğunu Döndürür.
  }

  Future<bool> saveToday(Mood mood, String note) => addEntry(MoodEntry.forDay(_clock.today(), mood, note: note)); // Bugün İçin Duygu ve Not Kaydeder.

  List<MoodEntry> entriesForMonth(int year, int month) => // Verilen Ayın Kayıtlarını Döndürür.
      entries.value.values.where((e) => e.entryDate.year == year && e.entryDate.month == month).toList(growable: false); // Yıl ve Aya Göre Filtreleyip Sabit Liste Döndürür.

  int countForYear(int year) => entries.value.values.where((e) => e.entryDate.year == year).length; // Verilen Yıldaki Kayıt Sayısını Döndürür.

  /// Kaydı olan en eski yıl (yoksa bugünün yılı).
  int get earliestYear { // En Eski Kayıt Yılını Döndüren Getter'dır.
    var year = _clock.today().year; // Başlangıç Değeri Olarak Bugünün Yılını Alır.
    for (final e in entries.value.values) { // Tüm Kayıtları Gezer.
      if (e.entryDate.year < year) year = e.entryDate.year; // Daha Eski Yıl Bulunursa Günceller.
    }
    return year; // En Eski Yılı Döndürür.
  }

  bool isOpened(String id) => openedCapsules.value.contains(id); // Kapsülün Açılış Animasyonunun Oynatılıp Oynatılmadığını Döndürür.

  Future<void> markOpened(String id) async { // Kapsülü Açılmış Olarak İşaretler.
    if (isOpened(id)) return; // Zaten Açılmışsa Çıkar.
    openedCapsules.value = Set.unmodifiable({...openedCapsules.value, id}); // id'yi Açılmış Kapsüllere Ekler.
    await _prefs.setOpenedCapsules(openedCapsules.value); // Güncel Seti Kalıcı Depoya Yazar.
  }

  /// Ayarlar › "Örnek veriye dön".
  Future<void> resetToMockData() async { // Tüm Kayıtları Örnek Veriyle Değiştirir.
    entries.value = Map.unmodifiable(MockMoodData.generate(_clock.today())); // Örnek Kayıtları Yeniden Üretip Atar.
    openedCapsules.value = const {}; // Açılmış Kapsül İşaretlerini Sıfırlar.
    await _prefs.setOpenedCapsules(const {}); // Boş Kapsül Setini Depoya Yazar.
    await _persist(); // Yeni Kayıtları Kalıcı Depoya Yazar.
  }

  /// "Her şeyi sil ve sıfırla" sonrası bellek durumunu boşaltır.
  void clearInMemory() { // Bellekteki Kayıtları ve Kapsül İşaretlerini Temizler.
    entries.value = const {}; // Kayıt Map'ini Boşaltır.
    openedCapsules.value = const {}; // Açılmış Kapsül Setini Boşaltır.
  }

  Future<void> _persist() { // Kayıtları JSON Olarak Kalıcı Depoya Yazar.
    final list = entries.value.values.toList()..sort((a, b) => a.id.compareTo(b.id)); // Kayıtları id'ye Göre Sıralı Listeye Çevirir.
    return _prefs.writeEntries([for (final e in list) e.toJson()]); // Her Kaydı JSON'a Çevirip Yazar.
  }

  void dispose() { // Notifier'ları Serbest Bırakır.
    entries.dispose(); // entries Notifier'ını Kapatır.
    openedCapsules.dispose(); // openedCapsules Notifier'ını Kapatır.
  }
}
