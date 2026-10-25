# Digura · Hareket Spesifikasyonu (Flutter)

Hedef kitle: Digura Flutter geliştiricileri. Kaynak: `digura-onboarding.html`, `digura-onboarding-akis.html`, `digura-prototip.html`, `digura-kilit.html` içindeki hareket katmanı. Değerler prototipte denenmiş değerlerdir; Flutter karşılıkları aşağıda verilmiştir.

> Paket politikası (Bölüm 4.4) korunur: hiçbir ek paket gerekmez. Tüm hareket Flutter çekirdek API'siyle (`Animated*`, `AnimationController`, `PageController`, `TweenSequence`) yazılır.

---

## 1. Ilkeler

1. **Hareket bir durumu onaylar, gösteri yapmaz.** Kullanıcı bir şey yaptıktan sonra, yaptığının sonucunu gösterir (basma, seçme, açılma).
2. **Tek dil.** Tüm arayüz geçişleri aynı eğriyi (`easeOut`) kullanır. Yalnızca alttan açılan paneller kendi eğrisini (`drawer`) kullanır.
3. **Arayüz geçişleri 300 ms'nin altında.** Tek istisna: ilk açılışta bir kez oynayan giriş (420 ms).
4. **Sık yapılan işler animasyonsuz ya da çok kısa.** Not yazma ve PIN tuş takımında hızlı ardışık girişlerde hareket yoktur; PIN noktası yalnızca 140 ms.
5. **Hareket tek başına bilgi taşımaz.** Hata sallanması kapalıyken bile renk ve metin durumu anlatır.
6. **Ucuz özellikler.** Mümkün olduğunca kaydırma, ölçek ve saydamlık (`SlideTransition`, `ScaleTransition`, `FadeTransition`). Düzen değiştiren animasyonlar (genişlik gibi) yalnızca küçük, tek elemanlı yerlerde.

---

## 2. Jetonlar

Önerilen dosya: `lib/core/constants/app_motion.dart` (renk/metin kuralındaki gibi tek kaynak; widget içinde `Duration(...)` ve `Cubic(...)` yazılmaz).

```dart
import 'package:flutter/animation.dart';

abstract final class AppMotion {
  // Süreler
  static const Duration micro = Duration(milliseconds: 140);   // PIN noktası
  static const Duration press = Duration(milliseconds: 160);   // basma geri bildirimi
  static const Duration ui = Duration(milliseconds: 200);      // diyalog, scrim, snackbar, anahtar
  static const Duration settle = Duration(milliseconds: 240);  // renk dairesi, içerik girişi
  static const Duration slide = Duration(milliseconds: 300);   // onboarding sayfa geçişi
  static const Duration sheet = Duration(milliseconds: 300);   // alt panel (açılış)
  static const Duration intro = Duration(milliseconds: 420);   // yalnızca ilk açılış, tek sefer
  static const Duration shake = Duration(milliseconds: 360);   // hatalı PIN
  static const Duration stagger = Duration(milliseconds: 40);  // art arda giren bloklar

  // Eğriler
  static const Curve easeOut = Cubic(0.23, 1, 0.32, 1);  // varsayılan: giren/çıkan her şey
  static const Curve drawer = Cubic(0.32, 0.72, 0, 1);   // alttan açılan paneller

  // Ölçekler
  static const double pressButton = 0.97;
  static const double pressKey = 0.94;
  static const double pressSwatch = 0.92;
  static const double enterOffset = 8;      // dp, aşağıdan yukarı
  static const double dialogFrom = 0.96;
}
```

Hareket azaltma için tek yardımcı:

```dart
extension MotionContext on BuildContext {
  /// Sistem "Hareketi azalt" ayarı (iOS) / "Animasyonları kaldır" (Android).
  bool get reduceMotion => MediaQuery.of(this).disableAnimations;
}
```

---

## 3. Hareket azaltma kuralı

`context.reduceMotion == true` iken:

| Kaldır | Koru |
| --- | --- |
| Kayma (translate), ölçek (scale), sallanma, parallax | Saydamlık geçişi (fade), renk geçişi |
| Sayfa kaydırma | Çapraz solma ile sayfa değişimi |
| Dönen yükleme halkası hızlanması | Halka dönmeye devam eder (durum bilgisi), ama 60 sn'de durur |

Uygulama: süreyi sıfıra çekmek yerine `Offset.zero` / `1.0` değerlerini kullan ve `FadeTransition` bırak. Örnek:

```dart
final Duration d = context.reduceMotion ? AppMotion.ui : AppMotion.slide;
```

---

## 4. Genel bileşenler

### 4.1 Basma geri bildirimi
Tüm birincil/ikincil düğmeler, ikon düğmeleri, tuşlar. Basılıyken ölçek küçülür, bırakılınca geri döner.

| Eleman | Ölçek | Süre | Eğri |
| --- | --- | --- | --- |
| Düğme, metin düğmesi, ikon düğmesi | 0,97 | `press` | `easeOut` |
| PIN tuşu, alt menü göstergesi | 0,94 | `press` | `easeOut` |
| Duygu rengi seçici (swatch, halka) | 0,92–0,94 | `press` | `easeOut` |
| Isı haritası hücresi | 0,96 | `press` | `easeOut` |

```dart
class Pressable extends StatefulWidget { /* child, onTap, scale */ }
// build: GestureDetector(onTapDown/Up/Cancel) + AnimatedScale(scale: _down ? scale : 1, duration: AppMotion.press, curve: AppMotion.easeOut)
```
`Pressable` yerel UI durumu olduğu için `StatefulWidget` kabul edilir (Bölüm 4.1 istisnası). `InkWell` ripple'ı ayrıca kalabilir.

Fare üzerine gelince büyüme (hover) yalnızca masaüstü içindir ve MVP'de (Android/iOS) yoktur.

### 4.2 Alt panel (Kapsül Detay Modalı, parmak izi paneli)
- Açılış: aşağıdan yukarı, `sheet` (300 ms), `drawer` eğrisi.
- Kapanış: `ui` (200 ms) `easeOut`.
- Scrim: saydamlık, `ui`.

```dart
showModalBottomSheet<void>(
  context: context,
  sheetAnimationStyle: AnimationStyle(
    duration: AppMotion.sheet,
    reverseDuration: AppMotion.ui,
    curve: AppMotion.drawer,
    reverseCurve: AppMotion.easeOut,
  ),
  builder: (_) => const CapsuleDetailSheet(),
);
```

### 4.3 Diyalog (kayıt onayı, PIN'imi unuttum)
Saydamlık 0 → 1 ve ölçek 0,96 → 1, `ui` (200 ms), `easeOut`. Kapanışta aynısı tersine.

```dart
showDialog<void>(
  context: context,
  animationStyle: AnimationStyle(duration: AppMotion.ui, curve: AppMotion.easeOut),
  builder: (_) => const SaveConfirmDialog(),
);
```
`animationStyle` parametresi SDK'nda yoksa `showGeneralDialog` + `transitionBuilder` içinde `FadeTransition` ve `ScaleTransition(scale: Tween(begin: AppMotion.dialogFrom, end: 1))` kullan.

### 4.4 Snackbar / bildirim
Saydamlık ve 8 dp aşağıdan yukarı, `ui`. Arka arkaya gelen bildirim animasyonu baştan oynatmaz, kaldığı yerden devam eder (aynı controller'ı `forward(from: current)` ile sür; yeni `AnimationController` açma).

### 4.5 Anahtar (hatırlatıcı, parmak izi)
Material `Switch` kullan. Yuvarlağın kayma süresi `ui`, renk geçişi `press`. Özel anahtar yazılırsa yuvarlak yalnızca kaydırılır ve ölçeklenir, konum/boyut yeniden hesaplatılmaz.

### 4.6 Sayfa noktaları (pagination)
Etkin nokta 8 → 24 dp genişler, `ui`, `easeOut`; renk `border` → `fg`.

```dart
AnimatedContainer(
  duration: AppMotion.ui,
  curve: AppMotion.easeOut,
  width: active ? 24 : 8,
  height: 8,
  decoration: BoxDecoration(color: active ? scheme.onSurface : scheme.outlineVariant, borderRadius: BorderRadius.circular(999)),
)
```
Bu, düzen değiştiren tek animasyondur; tek ve küçük bir eleman olduğu için kabul edilir.

---

## 5. Ekran ekran

### 5.1 Onboarding (`features/onboarding/` — onay sonrası)

**Sayfa geçişi (Devam / Geri / kaydırma).** `PageView` + `PageController`.

| Özellik | Değer |
| --- | --- |
| Süre / eğri | `slide` (300 ms) / `easeOut` |
| Yön | Devam: sağdan sola. Geri: soldan sağa |
| Ayrılan sayfa | Kayarken saydamlığı 1 → 0 |
| Gelen sayfa | Saydamlığı 0 → 1 |
| Sabit kalanlar | Üst çubuk, sayfa noktaları, ana düğme (düğme metni cross-fade) |

```dart
_controller.nextPage(
  duration: context.reduceMotion ? AppMotion.ui : AppMotion.slide,
  curve: AppMotion.easeOut,
);
```
- Parmakla kaydırma `PageView` ile ücretsiz gelir.
- Hareket azaltma: `physics` korunur ama geçiş `FadeTransition` ile yapılır (`AnimatedSwitcher`; `PageView` yerine). Basit çözüm: süreyi `ui`'ye indir.
- **Onboarding → Bugün geçişi.** Atla ve son ekrandaki ana düğme Bugün ekranına geçirir. Bugün sağdan kayarak gelir (`slide`, 300 ms, `easeOut`); onboarding aynı anda %22 sola kayıp solar (hafif parallax). Geri dönüş yoktur, onboarding bir daha gösterilmez.

```dart
Navigator.of(context).pushReplacement(PageRouteBuilder<void>(
  transitionDuration: context.reduceMotion ? AppMotion.ui : AppMotion.slide,
  pageBuilder: (_, __, ___) => const HomeShell(),
  transitionsBuilder: (_, anim, sec, child) {
    final a = CurvedAnimation(parent: anim, curve: AppMotion.easeOut);
    if (context.reduceMotion) return FadeTransition(opacity: a, child: child);
    return SlideTransition(position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(a), child: child);
  },
));
```
  Giden sayfanın parallax'ı için `secondaryAnimation` (`sec`) ile eski sayfayı `Offset(-0.22, 0)`'a kaydırıp soldur; bunun için eski sayfayı `SlideTransition` + `FadeTransition` ile sarmalayan bir `PageTransitionsTheme` ya da özel route gerekir.

**İlk açılış girişi (yalnızca bir kez).** Görsel, metin, düğme: saydamlık + 8 dp yukarı, `intro` (420 ms), `easeOut`, gecikmeler 0 / 60 / 120 ms. Sayfalar arası geçişte **tekrarlanmaz**.

**Duygu halkası (Ekran 1).** Bir renge dokunma: merkez daire arka planı `settle` (240 ms) ile yeni renge geçer ve 0,94 → 1 ölçekle yerleşir. Etikete `AnimatedSwitcher` (fade, `ui`).

**Hatırlatıcı anahtarı (Ekran 3).** Bölüm 4.5.

### 5.2 Bugün (`features/mood_entry/`)

| Olay | Hareket |
| --- | --- |
| Sekme açılışı | Bloklar saydamlık + 8 dp yukarı, `settle` (240 ms), her blok `stagger` (40 ms) arayla; ilk 3 blok farklı, 4+ aynı gecikmeyi (120 ms) paylaşır. Sekmeye her dönüşte değil, sekme **değişince** oynar |
| Renk seçimi | Büyük daire rengi `settle` ile değişir, 0,94 → 1 ölçek |
| Renk swatch'ına basma | Bölüm 4.1 (0,94) |
| Kayıt onayı | Diyalog (4.3) |
| Kayıttan sonra | Daire bir kez 0,94 → 1 ölçek ve saydamlık 0,7 → 1, 320 ms (`savedNow` bayrağı sekmeye dönünce tekrar oynamaz) |
| Not alanı | **Hareket yok** (sık yazılır) |

```dart
// Sekme girişi: Interval ile kademeli
final anim = CurvedAnimation(
  parent: _controller, // 240 ms + 120 ms gecikme payı
  curve: Interval(delay / total, 1, curve: AppMotion.easeOut),
);
// FadeTransition(opacity: anim, child: SlideTransition(position: Tween(begin: Offset(0, 8 / h), end: Offset.zero).animate(anim), ...))
```

### 5.3 Harita (`features/mood_calendar/`)
- Ay ↔ Yıl ve ay değişimi: MVP'de **animasyonsuz** bırakılabilir (hücre sayısı yüksek); istenirse sekme girişi (5.2) uygulanır.
- Hücreye basma: 0,96 (4.1).
- Kapsül Detay Modalı: 4.2.
- 365 hücreli yıl ısı haritasında **hücre başına animasyon yok**. Hücreler `const` kalır (Bölüm 4.2).

**Kapsül açılış anı (Kapsül Detay Modalı, ilk görünüm).** Kayıt 30. günü doldurduktan sonra ilk kez açıldığında bir kez oynar; sonraki açılışlar düz modaldır. "İlk görünüm" kayıt bazında saklanır (`MoodRepository` dışında, yerel tercih; Hive'a not eklenmez).

| Adım | Hareket | Süre |
| --- | --- | --- |
| Halka | Renk kutusunun çerçevesi 1 → 1,9 ölçeklenir, saydamlık 0,7 → 0 | 640 ms, `easeOut` |
| Renk yayılması | Not paneli (duygu renginde) kutudan dairesel olarak açılır | 560 ms, `easeOut` |
| Not | Metin saydamlık 0 → 1 | 300 ms, 320 ms gecikmeli |

```dart
// Dairesel açılış: ClipPath + CustomClipper (reveal: 0 → 1)
class CircleReveal extends CustomClipper<Path> {
  CircleReveal(this.reveal, this.center) : super(reclip: reveal);
  final Animation<double> reveal; final Offset center;
  @override
  Path getClip(Size s) => Path()..addOval(Rect.fromCircle(center: center, radius: reveal.value * s.longestSide * 1.4));
  @override
  bool shouldReclip(CircleReveal old) => old.center != center;
}
// Eşlik: HapticFeedback.mediumImpact() tam açılış anında bir kez.
```
Hareket azaltma: halka ve dairesel açılış yok; panel yalnızca solarak gelir. Ekran okuyucu notu panel gelince `SemanticsService.announce` ile okur. Kilitli kayıtlarda panel hiçbir koşulda oluşturulmaz (Bölüm 4.3).

### 5.4 İstatistik (`features/mood_stats/`)
- Sekme girişi 5.2'deki gibi.
- Dağılım şeritleri: ilk gösterimde genişlik 0 → hedef (`settle`) isteğe bağlıdır. Uygulanırsa `TweenAnimationBuilder<double>` ile ve yalnızca ilk görünümde.

### 5.5 Kilit ve Ayarlar (`features/app_lock/` — onay sonrası)

| Olay | Hareket | Süre |
| --- | --- | --- |
| PIN'e rakam girilir | Yeni nokta 0,6 → 1 ölçek | `micro` 140 ms |
| Hatalı PIN | Satır ±8 dp yatay salınım (20/40/60/80 % anahtar karelerinde), noktalar kırmızıya döner | `shake` 360 ms |
| Kilit açıldı | İçerik 0,96 → 1 ölçek + saydamlık, çocuklar 40 ms arayla | 260 ms |
| Parmak izi paneli | Alt panel (4.2) | 300 / 200 ms |
| Parmak izi hata/onay simgesi | Simge değişirken 0,96 → 1 ölçek + saydamlık | `ui` |
| Taranıyor halkası | Sürekli dönme, doğrusal eğri, 900 ms/tur | en çok 60 sn, sonra dur |
| 5 yanlış denemede 30 sn bekleme | Tuş takımı soluklaşır (opaklık geçişi), geri sayım metni değişir | `ui` |

Hatalı PIN sallanması:

```dart
final shake = TweenSequence<double>([
  TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 20),
  TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 40),
  TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 20),
  TweenSequenceItem(tween: Tween(begin: -8, end: 0), weight: 20),
]).animate(CurvedAnimation(parent: _c, curve: AppMotion.easeOut)); // _c.duration = AppMotion.shake
```

Hareket azaltma açıkken sallanma **yok**; kırmızı noktalar ve "PIN'ler eşleşmedi" metni durumu anlatır. Hata `Semantics(liveRegion: true)` ile okunur.

---

## 6. Yapma

- 300 ms üstünde arayüz animasyonu (yalnızca `intro` istisnası).
- Eğrileri ya da süreleri widget içinde yazmak; hep `AppMotion`.
- Sürekli dönen ya da yanıp sönen şeyi 60 sn'den fazla çalıştırmak. Zaman aşımında hata/yeniden dene durumuna geç.
- Saniyede 3'ten fazla parlama.
- Hareketi tek durum işareti yapmak (renk ve metin her zaman da vardır).
- Isı haritasında hücre başına animasyon; yıl görünümünde 365 controller.
- Not yazarken ve PIN girerken ek geçişler.
- Controller'ı `dispose()` etmemek (Bölüm 4.1). `SingleTickerProviderStateMixin` + `dispose` zorunlu.

---

## 7. Test

- `tester.pumpAndSettle()` ile animasyonlu akışlar bitirilir; sürekli dönen halka içeren ekranlarda `pump(Duration)` kullan (`pumpAndSettle` zaman aşımına düşer).
- Hareket azaltma testi: `MediaQuery(data: MediaQueryData(disableAnimations: true), child: ...)` ile sarmala; sallanma/kayma `Transform` widget'larının bulunmadığını doğrula.
- Zamana bağlı testlerde proje dokümanındaki `Clock` soyutlaması kullanılır; animasyon süreleri gerçek zamana değil `tester`'a bağlıdır.

---

## 8. Hızlı başvuru

| Ne | Süre | Eğri | Değer |
| --- | --- | --- | --- |
| Basma | 160 ms | easeOut | ölçek 0,97 / 0,94 / 0,92 |
| PIN noktası | 140 ms | easeOut | ölçek 0,6 → 1 |
| Diyalog, scrim, snackbar, anahtar, noktalar | 200 ms | easeOut | ölçek 0,96 / ofset 8 dp |
| Renk dairesi, sekme girişi | 240 ms | easeOut | ölçek 0,94 / ofset 8 dp |
| Sayfa geçişi (onboarding) | 300 ms | easeOut | tam sayfa kayması |
| Alt panel açılış / kapanış | 300 / 200 ms | drawer / easeOut | tam yükseklik |
| Hatalı PIN | 360 ms | easeOut | ±8 dp |
| İlk açılış girişi | 420 ms (tek sefer) | easeOut | ofset 8 dp, 60 ms aralık |
