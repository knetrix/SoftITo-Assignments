# Digura · DESIGN.md

Duygu Haritası & Dijital Zaman Kapsülü için tek görsel dil kaynağı. Kaynak sayfalar: `digura-onboarding.html` / `digura-onboarding-akis.html` (karşılama), `digura-kilit.html` (kilit ve ayarlar), `digura-prototip.html` (uygulama). Tüm değerler bu dosyaların CSS'inden ve etkin Material jeton paketinden okunmuştur; tahmin edilmiş değer yoktur.

**Tek cümle:** Nötr, soğuk Material yüzeyler; renk yalnızca beş duygudan gelir; tek mavi vurgu yalnızca ana eylemdedir.

---

## 1. Atmosfer ve ilkeler

- **Sakin ve minimal.** Ekranın ana vurgusu duygu renkleridir (Flutter dokümanı Bölüm 1). Yüzeyler nötrdür, süs yoktur.
- **Kilit görsel bir fikirdir.** Kapsül, kilit simgesi, soluk satırlar ve ilerleme çubuğu aynı ailedendir; kilitli metin hiçbir yerde gösterilmez.
- **Dürüstlük.** "Hesap yok, internet yok, kurtarma yok" metinde de, davranışta da aynı sertlikte söylenir.
- **Tek dil.** Üç sayfa aynı jetonları kullanır. Serif başlık ve koyu-gri vurgu (eski prototip dili) terk edildi.
- **Hareket onaylar, gösteri yapmaz.** Ayrıntı `motion-spec.md` içinde.

## 2. Renk

### 2.1 Nötr ve vurgu (Material jetonları, açık tema)

| Jeton | Değer | OKLCH |
| --- | --- | --- |
| `--bg` | `#f8fafd` | `oklch(98.4% 0.005 258)` |
| `--surface` | `#ffffff` | `oklch(100% 0 0)` |
| `--surface-warm` | `#e8f0fe` | `oklch(95.3% 0.021 262)` |
| `--fg` | `#202124` | `oklch(24.8% 0.006 271)` |
| `--fg-2` | `#3c4043` | `oklch(36.9% 0.007 240)` |
| `--muted` | `#5f6368` | `oklch(49.8% 0.009 254)` |
| `--border` | `#dadce0` | `oklch(89.4% 0.006 265)` |
| `--border-soft` | `#edf0f2` | `oklch(95.3% 0.004 236)` |
| `--accent` | `#1a73e8` | `oklch(57.4% 0.195 258)` |
| `--accent-on` | `#ffffff` | `oklch(100% 0 0)` |
| `--success` | `#188038` | `oklch(52.7% 0.141 148)` |
| `--warn` | `#f9ab00` | `oklch(79.6% 0.167 76)` |
| `--danger` | `#d93025` | `oklch(57.8% 0.206 29)` |

Hover `--accent-hover` = `--accent` + %8 siyah; active `--accent-active` = %14 siyah (`color-mix in oklab`).

### 2.2 Koyu tema (Material'den türetilmiş, tüm sayfalarda aynı)

| Jeton | Değer |
| --- | --- |
| `--bg` | `oklch(15.5% 0.007 255)` |
| `--surface` | `oklch(19% 0.008 255)` |
| `--surface-warm` | `oklch(28% 0.04 255)` |
| `--fg` / `--fg-2` / `--muted` | `oklch(94% 0.004 255)` / `oklch(86% 0.006 255)` / `oklch(72% 0.01 255)` |
| `--border` / `--border-soft` | `oklch(36% 0.01 255)` / `oklch(26% 0.009 255)` |
| `--accent` / `--accent-on` | `oklch(76% 0.12 255)` / `oklch(18% 0.03 255)` |
| `--accent-hover` / `--accent-active` | vurgu + %12 / %20 beyaz |
| `--empty`, `--key` | `oklch(26% 0.009 255)`, `oklch(25% 0.009 255)` |

Koyu temada vurgu **açık** mavidir ve üstündeki yazı **koyudur**; çiftler birlikte değişir.

### 2.3 Duygu renkleri (alana özgü, tek kaynak)

| `Mood` | Etiket | Açık | Üstündeki yazı (açık) | Koyu | Üstündeki yazı (koyu) |
| --- | --- | --- | --- | --- | --- |
| `joyful` | Neşeli | `oklch(85% 0.16 90)` | `oklch(26% 0.05 80)` | `oklch(84% 0.15 90)` | `oklch(18% 0.02 255)` |
| `calmSad` | Sakin / Hüzünlü | `oklch(54% 0.15 252)` | `oklch(99% 0 0)` | `oklch(70% 0.13 250)` | `oklch(18% 0.02 255)` |
| `angryStressed` | Öfkeli / Stresli | `oklch(57% 0.2 25)` | `oklch(99% 0 0)` | `oklch(68% 0.17 25)` | `oklch(18% 0.02 255)` |
| `serene` | Dingin | `oklch(70% 0.14 155)` | `oklch(22% 0.05 155)` | `oklch(73% 0.12 155)` | `oklch(18% 0.02 255)` |
| `tired` | Yorgun | `oklch(68% 0.012 260)` | `oklch(20% 0.01 260)` | `oklch(62% 0.012 260)` | `oklch(18% 0.02 255)` |

Boş gün `--empty`: açık `oklch(94.5% 0.004 255)`, koyu `oklch(26% 0.009 255)`. Gelecek gün: şeffaf zemin + 1 px `--border` iç çizgi (soluklaştırma yok).

### 2.4 Kullanım kuralları

1. **Mavi vurgu bir ekranda en fazla iki yerde:** ana düğme ve seçili sekmenin zemini (`--surface-warm`). Bağlantı ve odak halkası bu sayıya dahildir.
2. Duygu rengi **hiçbir zaman** metin rengi olmaz; yalnızca dolgu. Üstüne gelen yazı yukarıdaki çiftlerden alınır.
3. Renk tek başına durum taşımaz: hata = renk + metin + simge, kilit = simge + metin.
4. Ham hex yalnızca `:root` bloğunda yaşar. Cihaz çerçevesi (titanyum gradyanı) çizim malzemesidir, jeton değildir.

## 3. Tipografi

| Rol | Yığın | Kullanım |
| --- | --- | --- |
| Display | `"Google Sans", Roboto, Arial, sans-serif` | Başlıklar, rakamlar (PIN tuşları 28 px), marka |
| Gövde | `Roboto, Arial, sans-serif` | Paragraf, etiket, düğme |
| Mono | `"Roboto Mono", ui-monospace, Menlo, monospace` | Tarih, sayaç, adım/üstbilgi etiketleri |

| Öğe | Boyut / ağırlık | Not |
| --- | --- | --- |
| Ekran başlığı (onboarding) | 30 / 500, satır 1,15, izleme −0,01em | `text-wrap: balance` |
| Ekran başlığı (uygulama) | 28 / 500, satır 1,1 | Bugün, Harita, İstatistik |
| Bölüm başlığı | 22 / 500 | |
| Gövde | 15–16, satır 1,5 | `text-wrap: pretty` |
| Düğme | 16 / 500, izleme +0,02em | |
| Küçük | 12–14 | etiket, alt yazı |
| Mono etiket | 11–12, **BÜYÜK HARF + izleme 0,08em** | Büyük harfte pozitif izleme zorunlu |

Ağırlık disiplini: 400 okuma, 500 vurgu/başlık, 600 yalnızca seçili durum ve kısa vurgu. Serif kullanılmaz.

## 4. Aralık, ızgara, yüzey

- **Ölçek:** 4 / 8 / 12 / 16 / 20 / 24 / 32 / 48 (`--space-*`). Yatay ekran kenar boşluğu 20–24, kart iç boşluğu 16–20.
- **Telefon tuvali:** 390 × 844 (iPhone 15 Pro), durum çubuğu 47, ana gösterge 22. İçerik 366 px genişlikte düşünülür.
- **Yarıçap:** küçük 4, orta 12, büyük 24, alt panel ve diyalog 28, kapsül/hap 9999. Takvim hücresi 11, not alanı 18.
- **Yükseklik:** düz yüzey + 1 px `--border`; yalnızca öne çıkan kartta `--elev-raised` (`0 3px 8px rgba(60,64,67,.18)`), koyu temada `0 3px 12px` siyah %40.
- **Ayırma sırası:** önce boşluk, sonra çizgi, en son gölge.

## 5. Bileşenler

| Bileşen | Ölçü / durum |
| --- | --- |
| Ana düğme | Tam genişlik, min 52 px, hap; hover = vurgu %8 koyu, active = %14 + ölçek 0,97; pasif = `--border-soft` zemin + `--muted` yazı |
| Metin düğmesi | Min 44 px, hap, hover `--border-soft` zemin |
| Duygu seçici (swatch) | 48 px daire, seçili = `--bg` + `--fg` çift halka (3 + 5 px) ve onay simgesi |
| Renk dairesi (orb) | 128–152 px; boş = `--empty` + iç çizgi; dolu = duygu rengi + renk gölgesi |
| Not alanı | 18 px yarıçap, odakta kenar `--fg`; 140 karakter, satır atlatmaz, sayaç mono |
| Isı haritası hücresi | ~45 px kare, yarıçap 11; kilitli gün = sağ altta 11 px kilit; bugün = çift halka; yeni açılan = sağ altta 7 px nokta |
| Segment (Ay / Yıl) | Min 44 px, hap, seçili `--border-soft` zemin + 600 |
| Alt menü (NavigationBar) | 3 sekme, min 60 px, gösterge 64 × 32 hap, seçili `--surface-warm` |
| PIN tuşu | 76 px daire, `--key`; hover/active/disabled kademeleri `--key-hover/active/disabled` |
| PIN noktası | 16 px; dolu = `--fg` |
| Alt panel (kapsül detayı) | 28 px üst yarıçap, tutamaç 32 × 4, ölçü kapatma düğmesi 44 px |
| Diyalog | 28 px yarıçap, iki eylem: metin düğmesi + vurgulu metin düğmesi |
| Anahtar | 52 × 32, yuvarlak 24 px (kapalıyken ölçek 0,667) |
| Bildirim (snackbar) | `--fg` zemin, `--surface` yazı, 12 px yarıçap, `role="status"` |
| Kapsül açılış anı | Renk kutusu çerçevesi halka olarak yayılır, not paneli duygu renginde daire biçimli açılır, metin 320 ms sonra belirir |

## 6. Durumlar (her yüzey için)

Yüklenme, boş, hata, dolu ve uç durum zorunludur. Projedeki karşılıkları:

- **Boş:** "Bu ay henüz kayıt yok" (İstatistik); boş gün hücresi; notsuz kapsül "Bu gün için not bırakılmamış".
- **Hata:** yanlış PIN (kırmızı noktalar + "PIN'ler eşleşmedi" + sallanma), zayıf PIN, parmak izi tanınmadı (3 hakta sensör kapanır, PIN'e yönlendirilir), 5 yanlışta 30 sn bekleme.
- **Kilitli:** kalan gün + ilerleme çubuğu; metin DOM'da bile oluşturulmaz.
- **Geri alınamaz eylem:** kayıt öncesi onay diyaloğu (düzenlenemez, silinemez).

## 7. Hareket

Tek eğri ve tek süre ailesi; ayrıntı ve Flutter karşılığı `motion-spec.md`.

| Jeton | Değer |
| --- | --- |
| `--ease-out` | `cubic-bezier(0.23, 1, 0.32, 1)` |
| `--ease-drawer` | `cubic-bezier(0.32, 0.72, 0, 1)` (yalnızca alt panel) |
| Süreler | basma 160 · arayüz 200 · yerleşme 240 · kayma/panel 300 · ilk açılış girişi 420 (tek sefer) |
| Basma ölçeği | düğme 0,97 · tuş 0,94 · renk seçici 0,92–0,94 |

`prefers-reduced-motion`: kayma, ölçek ve sallanma kalkar; solma ve renk geçişi kalır. Hareket tek başına durum taşımaz.

## 8. Metin sesi

- Türkçe, kısa, eylem odaklı. "Rengi kaydet", "Kapsülün açılmasına 12 gün kaldı", "Kaydetmeye geç".
- Etiketler düz ve gerçek: "Sakin / Hüzünlü", "Öfkeli / Stresli". Uydurma metrik yok.
- Güvenlik metni net: "PIN kurtarılamaz", "Veriler yalnızca bu cihazda".
- Kullanıcıya görünen tüm metinler Flutter'da `app_strings.dart` içinde yaşar.

## 9. Erişilebilirlik tabanı

- Normal metin ≥ 4,5:1, büyük metin ve simge ≥ 3:1; durum değişince kontrast düşmez.
- Dokunma hedefi ≥ 44 px (takvim hücresi ~45, segment 44, PIN tuşu 76).
- Her odaklanabilir öğede görünür halka: `0 0 0 4px rgba(26,115,232,.24)`.
- Modal açıkken arka plan etkisiz (`inert`), Esc kapatır. Kilit panelleri kapanınca odak ilk tuşa döner; prototipte kapanış odağı henüz tetikleyiciye taşınmadı.
- Hata ve durum mesajı `role="status"` / `role="alert"`; renk tek işaret değil.

## 10. Sayfalar arası sözleşme

| Anahtar (localStorage) | Anlamı |
| --- | --- |
| `digura.theme` | `system` · `light` · `dark` (Ayarlar › Tema, üç sayfada ortak) |
| `digura.pin` | Prototip PIN'i (demo; gerçek uygulamada güvenli depolama) |
| `digura.pending` | Karşılamada seçilen `{ mood, note }`; prototipte taslak olarak dolar, tüketilince silinir |
| `digura.onboarding.step` | Karşılama konumu (bitince silinir) |
| `digura.proto.v1` | Prototip kayıtları (günde 1, `dayKey` anahtarlı) |
| `digura.proto.opened.<tema>` | Açılış anı oynanmış kapsüller |

Akış: `index.html` → `digura-onboarding-akis.html` → (Bugün) → `digura-prototip.html`; kilit: `digura-kilit.html` → açılınca `digura-prototip.html`; dişli → `digura-kilit.html#ayarlar`.

## 11. Flutter eşlemesi (özet)

- `core/constants/app_colors.dart`: yukarıdaki açık/koyu tablolar + `Mood` rengi ve "üstündeki yazı" çifti. Widget içinde `Color(0xFF…)` yazılmaz.
- `core/theme/app_theme.dart`: Material 3 `ColorScheme` (`primary` = vurgu, `surface`, `surfaceContainer` = `--surface-warm`/`--border-soft`, `outline` = `--border`), `ThemeMode.system`.
- `core/constants/app_motion.dart`: `motion-spec.md` Bölüm 2.
- Yazı stilleri `TextTheme` içinde: display = Google Sans (yoksa Roboto), gövde = Roboto, mono = Roboto Mono.
- Not: Google Sans lisanslı bir yazı tipidir; pakete eklenecekse onay alınmalı, yoksa Roboto ile devam edilir.

## 12. Yapma

- Serif başlık, ikinci bir vurgu rengi, mor/indigo tonları, süs gradyanı.
- Duygu rengini metin rengi yapmak; renk tek başına anlam taşımak.
- Kilitli notu log, bildirim, istatistik ya da DOM'a koymak.
- Emoji simge; uydurma metrik; "lorem ipsum".
- Hover'da yazıyı `--muted`'a çekmek (kontrast düşer).
- Tek ekranda iki solid ana düğme.

## 13. Bilinen açıklar

- Prototipte sayfa üst bölümü (`page-head`, sıfırlama düğmesi) hâlâ jeton dışı gri değerler kullanıyor.
- Bugün ekranı iki yerde (karşılama ve prototip) ayrı kodla yaşıyor; tek kaynağa inmeli.
- Koyu sıralar ve kapsül açılış anı tarayıcıda elle denenmedi.
