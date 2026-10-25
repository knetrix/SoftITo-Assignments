import '../../features/mood_entry/models/mood_entry_model.dart';
import '../constants/app_colors.dart';
import '../utils/clock.dart';

/// `digura-prototip.html` ile birebir aynı deterministik örnek veri.
///
/// Bugünden 85 gün öncesinden dünü de kapsayacak şekilde (prototipte
/// 1 Ağustos – 24 Ekim 2026) aynı Park–Miller üreteciyle (tohum 7) üretilir:
/// açılmış kapsüller, yeni açılmış (`fresh`) kapsüller, notsuz kayıtlar ve
/// hâlâ kilitli kapsüller birlikte bulunur.
abstract final class MockMoodData {
  /// Örnek veriyle birlikte kullanılan demo PIN.
  static const String demoPin = '2580';

  static const int spanDays = 85;
  static const int _seed = 7;
  static const int _modulus = 2147483647;
  static const int _multiplier = 16807;
  static const double _skipChance = 0.16;
  static const double _emptyNoteChance = 0.12;

  static const List<(Mood, double)> _weights = [
    (Mood.joyful, 0.26),
    (Mood.serene, 0.24),
    (Mood.calmSad, 0.18),
    (Mood.tired, 0.18),
    (Mood.angryStressed, 0.14),
  ];

  static const Map<Mood, List<String>> notes = {
    Mood.joyful: [
      'Annemle uzun bir kahvaltı yaptık, saatlerce güldük.',
      'Sunumum beklediğimden çok daha iyi geçti.',
      'Sahilde yürürken eski bir arkadaşa rastladım.',
      'İlk kez kendi ekmeğimi pişirdim ve gerçekten güzel oldu.',
      "Meryem'le planladığımız konsere bilet bulduk!",
    ],
    Mood.calmSad: [
      'Yağmuru izleyip eski fotoğraflara baktım.',
      'Dedemi özledim, akşam onun sevdiği şarkıyı dinledim.',
      'Bugün biraz içime kapandım ama kötü değildi.',
      'Arkadaşım başka şehre taşındı, ev sessiz.',
    ],
    Mood.angryStressed: [
      'Teslim tarihi bir gün öne çekildi, gün boyu koştum.',
      'Trafikte iki saat kaldım ve toplantıyı kaçırdım.',
      'Kod derlenmedi, sebebini gece yarısı buldum.',
      'Kira artışı haberi bütün günü bozdu.',
    ],
    Mood.serene: [
      'Telefonu bırakıp parkta kitap okudum.',
      'Sabah koşusundan sonra her şey yerli yerinde gibiydi.',
      'Balkondaki fesleğen nihayet çiçek açtı.',
      'Akşam çayı, battaniye ve hiçbir plan.',
      'Uzun bir yoga seansı, zihnim sakin.',
    ],
    Mood.tired: [
      'Gece iyi uyuyamadım, gün çok uzun geçti.',
      'Üç ders üst üste, kafam tamamen doldu.',
      'Taşınma kolilerini kaldırmaktan bitkinim.',
      '',
    ],
  };

  /// [today] hariç son [spanDays] gün için kayıtları üretir.
  static Map<String, MoodEntry> generate(DateTime today) {
    var state = _seed;
    double rnd() {
      state = (state * _multiplier) % _modulus;
      return state / _modulus;
    }

    final end = DateHelpers.dateOnly(today);
    final out = <String, MoodEntry>{};
    for (var day = DateHelpers.addDays(end, -spanDays); day.isBefore(end); day = DateHelpers.addDays(day, 1)) {
      if (rnd() < _skipChance) continue;
      var r = rnd();
      var mood = Mood.joyful;
      for (final (candidate, weight) in _weights) {
        r -= weight;
        if (r <= 0) {
          mood = candidate;
          break;
        }
      }
      final pool = notes[mood]!;
      final note = rnd() < _emptyNoteChance ? '' : pool[(rnd() * pool.length).floor()];
      final entry = MoodEntry.forDay(day, mood, note: note);
      out[entry.id] = entry;
    }
    return out;
  }
}
