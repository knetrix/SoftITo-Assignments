import '../../features/mood_entry/models/mood_entry_model.dart'; // MoodEntry Model Class'ını import Eder.
import '../constants/app_colors.dart'; // Mood Enum'unu import Eder.
import '../utils/clock.dart'; // DateHelpers Tarih Yardımcılarını import Eder.

/// `digura-prototip.html` ile birebir aynı deterministik örnek veri.
///
/// Bugünden 85 gün öncesinden dünü de kapsayacak şekilde (prototipte
/// 1 Ağustos – 24 Ekim 2026) aynı Park–Miller üreteciyle (tohum 7) üretilir:
/// açılmış kapsüller, yeni açılmış (`fresh`) kapsüller, notsuz kayıtlar ve
/// hâlâ kilitli kapsüller birlikte bulunur.
abstract final class MockMoodData { // Deterministik Örnek Kayıtları Üreten Class'tır.
  /// Örnek veriyle birlikte kullanılan demo PIN.
  static const String demoPin = '2580'; // Demo Modunda Kullanılan PIN'dir.

  static const int spanDays = 85; // Örnek Verinin Kapsadığı Gün Sayısıdır.
  static const int _seed = 7; // Rastgele Üretecin Tohum Değeridir.
  static const int _modulus = 2147483647; // Park–Miller Üretecinin Modülüdür.
  static const int _multiplier = 16807; // Park–Miller Üretecinin Çarpanıdır.
  static const double _skipChance = 0.16; // Bir Günün Kayıtsız Bırakılma Olasılığıdır.
  static const double _emptyNoteChance = 0.12; // Kaydın Notsuz Olma Olasılığıdır.

  static const List<(Mood, double)> _weights = [ // Duyguların Seçilme Ağırlıklarını Tutan Listedir.
    (Mood.joyful, 0.26), // Neşeli Duygunun Ağırlığıdır.
    (Mood.serene, 0.24), // Dingin Duygunun Ağırlığıdır.
    (Mood.calmSad, 0.18), // Sakin / Hüzünlü Duygunun Ağırlığıdır.
    (Mood.tired, 0.18), // Yorgun Duygunun Ağırlığıdır.
    (Mood.angryStressed, 0.14), // Öfkeli / Stresli Duygunun Ağırlığıdır.
  ];

  static const Map<Mood, List<String>> notes = { // Her Duygu İçin Örnek Not Havuzunu Tutan Map'tir.
    Mood.joyful: [ // Neşeli Duygunun Örnek Notlarıdır.
      'Annemle uzun bir kahvaltı yaptık, saatlerce güldük.', // Neşeli Örnek Notudur.
      'Sunumum beklediğimden çok daha iyi geçti.', // Neşeli Örnek Notudur.
      'Sahilde yürürken eski bir arkadaşa rastladım.', // Neşeli Örnek Notudur.
      'İlk kez kendi ekmeğimi pişirdim ve gerçekten güzel oldu.', // Neşeli Örnek Notudur.
      "Meryem'le planladığımız konsere bilet bulduk!", // Neşeli Örnek Notudur.
    ],
    Mood.calmSad: [ // Sakin / Hüzünlü Duygunun Örnek Notlarıdır.
      'Yağmuru izleyip eski fotoğraflara baktım.', // Hüzünlü Örnek Notudur.
      'Dedemi özledim, akşam onun sevdiği şarkıyı dinledim.', // Hüzünlü Örnek Notudur.
      'Bugün biraz içime kapandım ama kötü değildi.', // Hüzünlü Örnek Notudur.
      'Arkadaşım başka şehre taşındı, ev sessiz.', // Hüzünlü Örnek Notudur.
    ],
    Mood.angryStressed: [ // Öfkeli / Stresli Duygunun Örnek Notlarıdır.
      'Teslim tarihi bir gün öne çekildi, gün boyu koştum.', // Stresli Örnek Notudur.
      'Trafikte iki saat kaldım ve toplantıyı kaçırdım.', // Stresli Örnek Notudur.
      'Kod derlenmedi, sebebini gece yarısı buldum.', // Stresli Örnek Notudur.
      'Kira artışı haberi bütün günü bozdu.', // Stresli Örnek Notudur.
    ],
    Mood.serene: [ // Dingin Duygunun Örnek Notlarıdır.
      'Telefonu bırakıp parkta kitap okudum.', // Dingin Örnek Notudur.
      'Sabah koşusundan sonra her şey yerli yerinde gibiydi.', // Dingin Örnek Notudur.
      'Balkondaki fesleğen nihayet çiçek açtı.', // Dingin Örnek Notudur.
      'Akşam çayı, battaniye ve hiçbir plan.', // Dingin Örnek Notudur.
      'Uzun bir yoga seansı, zihnim sakin.', // Dingin Örnek Notudur.
    ],
    Mood.tired: [ // Yorgun Duygunun Örnek Notlarıdır.
      'Gece iyi uyuyamadım, gün çok uzun geçti.', // Yorgun Örnek Notudur.
      'Üç ders üst üste, kafam tamamen doldu.', // Yorgun Örnek Notudur.
      'Taşınma kolilerini kaldırmaktan bitkinim.', // Yorgun Örnek Notudur.
      '', // Notsuz Kayıt İçin Boş Nottur.
    ],
  };

  /// [today] hariç son [spanDays] gün için kayıtları üretir.
  static Map<String, MoodEntry> generate(DateTime today) { // Gün Anahtarına Göre Örnek Kayıt Map'i Üretir.
    var state = _seed; // Üretecin Durumunu Tohumla Başlatır.
    double rnd() { // 0 İle 1 Arasında Sözde Rastgele Sayı Üretir.
      state = (state * _multiplier) % _modulus; // Park–Miller Formülüyle Durumu İlerletir.
      return state / _modulus; // Durumu 0–1 Aralığına Ölçekleyip Döndürür.
    }

    final end = DateHelpers.dateOnly(today); // Bitiş Gününü Bugün Olarak Normalize Eder.
    final out = <String, MoodEntry>{}; // Üretilen Kayıtları Tutacak Boş Map'tir.
    for (var day = DateHelpers.addDays(end, -spanDays); day.isBefore(end); day = DateHelpers.addDays(day, 1)) { // spanDays Gün Öncesinden Düne Kadar Her Günü Gezer.
      if (rnd() < _skipChance) continue; // Olasılığa Göre Günü Kayıtsız Bırakır.
      var r = rnd(); // Duygu Seçimi İçin Rastgele Değer Alır.
      var mood = Mood.joyful; // Varsayılan Duyguyu Neşeli Olarak Ayarlar.
      for (final (candidate, weight) in _weights) { // Ağırlık Listesini Sırayla Gezer.
        r -= weight; // Rastgele Değerden Ağırlığı Düşer.
        if (r <= 0) { // Değer Sıfırın Altına İnince Duyguyu Seçer.
          mood = candidate; // Seçilen Duyguyu Atar.
          break; // Döngüden Çıkar.
        }
      }
      final pool = notes[mood]!; // Seçilen Duygunun Not Havuzunu Alır.
      final note = rnd() < _emptyNoteChance ? '' : pool[(rnd() * pool.length).floor()]; // Olasılığa Göre Boş ya da Rastgele Bir Not Seçer.
      final entry = MoodEntry.forDay(day, mood, note: note); // O Gün İçin MoodEntry Oluşturur.
      out[entry.id] = entry; // Kaydı Gün Anahtarıyla Map'e Ekler.
    }
    return out; // Üretilen Kayıtları Döndürür.
  }
}
