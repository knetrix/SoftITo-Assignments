/// Kullanıcıya görünen tüm Türkçe metinler (DESIGN.md Bölüm 8).
///
/// Widget dosyalarında sabit metin yazılmaz; parametreli metinler burada
/// küçük yardımcı fonksiyonlar olarak durur.
abstract final class AppStrings {
  // ─── Uygulama ───
  static const String appName = 'Digura';
  static const String appVersion = 'Sürüm 0.1.0 (MVP) · Android ve iOS';

  // ─── Duygular ───
  static const String moodJoyful = 'Neşeli';
  static const String moodCalmSad = 'Sakin / Hüzünlü';
  static const String moodAngryStressed = 'Öfkeli / Stresli';
  static const String moodSerene = 'Dingin';
  static const String moodTired = 'Yorgun';

  // ─── Takvim ───
  static const List<String> months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  /// `DateTime.weekday` sırası: 1 = Pazartesi … 7 = Pazar.
  static const List<String> weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
  static const List<String> weekdaysShort = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];

  // ─── Ortak eylemler ───
  static const String cancel = 'Vazgeç';
  static const String ok = 'Tamam';
  static const String save = 'Kaydet';
  static const String next = 'Devam';
  static const String back = 'Geri';
  static const String close = 'Kapat';
  static const String previousMonth = 'Önceki ay';
  static const String nextMonth = 'Sonraki ay';

  // ─── Alt gezinme ───
  static const String navLabel = 'Ana gezinme';
  static const String tabToday = 'Bugün';
  static const String tabMap = 'Harita';
  static const String tabStats = 'İstatistik';

  // ─── Bugün (mood_entry) ───
  static const String todayTitle = 'Bugün nasıldın?';
  static const String todaySavedTitle = 'Bugünün rengi kaydedildi';
  static const String settingsTooltip = 'Ayarlar';
  static const String pickColor = 'Bir renk seç';
  static const String pickColorHint = 'Renk zorunlu, not isteğe bağlı';
  static const String selectedMood = 'Seçilen duygu';
  static const String moodPickerLabel = 'Duygu rengi';
  static const String noteLabel = 'Tek cümlelik not · isteğe bağlı';
  static const String notePlaceholder = 'Bugünü tek cümleyle anlat…';
  static const String noteLocked = '30 gün kilitli kalır';
  static const String saveColor = 'Rengi kaydet';
  static const String savedPermanent = 'Kayıt kalıcıdır · düzenlenemez';
  static const String noteSealed = 'Notun kapsüle kilitlendi';
  static const String noNoteToday = 'Bugün not bırakmadın';
  static const String seeOnMap = 'Haritada gör';
  static const String tomorrowHint = 'Yarın yeni bir renk seçebilirsin.';
  static const String savedSnack = 'Bugünün rengi kaydedildi';
  static const String alreadySavedSnack = 'Bugün için zaten bir kayıt var';
  static const String confirmTitle = 'Bugünün rengi kaydedilsin mi?';
  static const String confirmBody =
      'Zaman kapsülü gereği bu kayıt sonradan düzenlenemez veya silinemez. Notun 30 gün kilitli kalır.';
  static const String withNote = 'notlu';
  static const String withoutNote = 'notsuz';

  static String noteCount(int length, int max) => '$length/$max';
  static String unlockOn(String date) => 'Açılış: $date';
  static String capsuleRemaining(int days) => 'Kapsülün açılmasına $days gün kaldı';
  static String lockProgress(int elapsed, int total) => '$elapsed/$total';

  // ─── Harita (mood_calendar) ───
  static const String mapEyebrow = 'Renk haritası';
  static const String mapTitle = 'Harita';
  static const String viewLabel = 'Görünüm';
  static const String viewMonth = 'Ay';
  static const String viewYear = 'Yıl';
  static const String noEntry = 'Kayıt yok';
  static const String mapHint =
      'Kilit simgeli günlerin notları, kayıttan 30 gün sonra açılır. Noktalı günlerin kapsülü yeni açıldı; dokunarak aç.';
  static const String capsuleDetail = 'Kapsül detayı';
  static const String emptyCapsuleNote = 'Bu gün için not bırakılmamış.';
  static const String freshCapsule = 'yeni açıldı';
  static const String lockedCapsule = 'kilitli';

  static String monthColored(int count, int days) => '$count / $days gün renklendi';
  static String yearColored(int count) => '$count gün renklendi';
  static String capsuleOpened(String date) => 'Kapsül açıldı · $date';
  static String quoted(String note) => '“$note”';
  static String monthShort(int month) => months[month - 1].substring(0, 3);
  static String miniMonthLabel(String month, int year, int count) => '$month $year, $count kayıt';
  static String dayCellLabel(int day, String month, String mood, String? state) =>
      state == null ? '$day $month, $mood' : '$day $month, $mood, $state';

  // ─── İstatistik (mood_stats) ───
  static const String statsEyebrow = 'Yalnızca renkler';
  static const String statsTitle = 'İstatistik';
  static const String statsSub = 'Aylık duygu dağılımı';
  static const String statsEntriesThisMonth = 'kayıt bu ay';
  static const String statsMostFrequent = 'En sık';
  static const String statsDistribution = 'Duygu dağılımı';
  static const String statsEmptyTitle = 'Bu ay henüz kayıt yok';
  static const String statsEmptyBody = 'Günün rengini seçtiğinde dağılım burada görünecek.';
  static const String statsPrivacy =
      'İstatistikler yalnızca renkleri kullanır. Kilitli notlarına erişilmez, veriler cihazından çıkmaz.';

  static String percent(int value) => '%$value';
  static String topMood(int value, String label) => '%$value $label';
  static String dayCount(int count) => '$count gün';

  // ─── Karşılama (onboarding) ───
  static const String skip = 'Atla';
  static const String startToday = 'Günün rengini seç';
  static const String onboardingPalette = 'Duygu renkleri';
  static const String welcomeTitle = 'Her gün tek bir renk.';
  static const String welcomeBody =
      'Gününü beş duygu renginden biriyle ve en fazla 140 karakterlik tek bir cümleyle kaydet. Denemek için bir renge dokun.';
  static const String capsuleTitle = 'Yazdıkların 30 gün kilitli kalır.';
  static const String capsuleBody =
      'Rengini her zaman görürsün ama notunu hemen okuyamazsın. Kapsül açıldığında o günkü sana geri dönersin. Kayıtlar düzenlenemez, silinemez.';
  static const String capsuleSampleDate = '12 Eylül 2026 · Cumartesi';
  static const String capsuleSampleSub = 'Not, kayıttan 30 gün sonra okunabilir';
  static const String timelineStart = 'Kayıt';
  static const String timelineMid = '18. gün';
  static const String timelineEnd = '30. gün';
  static const String mapPreviewTitle = 'Geçmişin, renk renk';
  static const String mapPreviewSub = 'örnek ay';
  static const String startTitle = 'Geçmişini bir haritada gör.';
  static const String startBody = 'Günler ısı haritasında renklenir, her ayın duygu dağılımı istatistiklerde görünür.';
  static const String privacyTitle = 'Hesap yok, internet yok';
  static const String privacySub = 'Tüm kayıtlar yalnızca bu cihazda saklanır';
  static const String reminderOnboarding = "Her akşam 21:00'de hatırlat";
  static const String reminderOptional = 'İsteğe bağlı';
  static const String reminderPermission = 'Açık · bildirim izni istenecek';

  static String stepOf(int step, int total) => 'Adım $step / $total';

  // ─── Kilit (app_lock) ───
  static const String pinHintCreate = '4 rakam';
  static const String pinHintConfirm = '2. kez';
  static const String restart = 'Baştan';
  static const String pinCreateTitle = 'Bir PIN oluştur';
  static const String pinCreateSub = 'Digura her açıldığında bu 4 haneli PIN sorulur. Notların böylece korunur.';
  static const String pinConfirmTitle = "PIN'ini tekrar gir";
  static const String pinConfirmSub = 'Doğru yazdığından emin olalım.';
  static const String pinCreated = 'PIN oluşturuldu';
  static const String pinCreatedSub = 'Bu PIN yalnızca bu cihazda, şifrelenmiş olarak saklanır.';
  static const String weakPin = 'Bu PIN tahmin edilmesi kolay. Sıralı ya da aynı rakamlardan oluşmayan bir PIN seç.';
  static const String pinMismatch = "PIN'ler eşleşmedi. Yeni PIN'i baştan gir.";
  static const String keypadLabel = 'Rakam tuşları';
  static const String deleteKey = 'Sil';

  static const String notNow = 'Şimdi değil';
  static const String bioSetupTitle = 'Parmak izi ile aç';
  static const String bioSetupSub = 'Her seferinde PIN yazmadan, tek dokunuşla aç. PIN yedek olarak hep kalır.';
  static const String bioOnTitle = 'Parmak izi açık';
  static const String bioOnSub = 'Bir sonraki açılışta parmağını sensöre koyman yeterli.';
  static const String bioFactDevice = "Parmak izin Digura'ya ulaşmaz, eşleştirmeyi telefonun kendisi yapar.";
  static const String bioFactFallback = 'Sensör tanımazsa her zaman PIN ile açabilirsin.';
  static const String bioPlaceFinger = 'Parmağını sensöre koy…';
  static const String bioUse = 'Parmak izini kullan';
  static const String bioScanning = 'Taranıyor…';
  static const String bioSetupFailed = 'Parmak izi doğrulanamadı. Tekrar dene ya da şimdilik geç.';
  static const String bioUnavailable = 'Bu cihazda parmak izi kullanılamıyor. Kilit yalnızca PIN ile açılır.';
  static const String bioIconLabel = 'Parmak izi simgesi';
  static const String bioIconOnLabel = 'Parmak izi etkin';
  static const String bioSkippedSnack = "Parmak izi kapalı. Ayarlar'dan sonra açabilirsin.";

  static const String lockPromptBio = "PIN'ini gir ya da parmak izini kullan";
  static const String lockPromptPin = "Devam etmek için PIN'ini gir";
  static const String bioTemporarilyOff = 'Parmak izi geçici olarak kapalı. PIN ile aç.';
  static const String bioKeyLabel = 'Parmak izi ile aç';
  static const String bioKeyOffLabel = 'Parmak izi geçici olarak kapalı';
  static const String forgotPin = "PIN'imi unuttum";
  static const String unlockedTitle = 'Kilit açıldı';
  static const String unlockedSub = 'Bugün sekmesi açılıyor…';
  static const String bioSheetTitle = "Digura'yı aç";
  static const String bioSheetSub = 'Parmak izini doğrula';
  static const String bioSheetPlace = 'Parmağını sensöre koy';
  static const String bioSheetOk = 'Doğrulandı';
  static const String bioSheetLockout =
      'Parmak izi 3 kez tanınmadı. Güvenliğin için sensör geçici olarak kapatıldı; PIN ile açtığında yeniden açılır.';
  static const String usePin = 'PIN kullan';
  static const String continueWithPin = 'PIN ile devam et';
  static const String retry = 'Tekrar dene';
  static const String forgotTitle = 'PIN kurtarılamaz';
  static const String forgotBody1 =
      "Digura'da hesap ya da sunucu olmadığı için PIN'i sıfırlayacak bir e-posta veya kod yok.";
  static const String forgotBody2Lead = 'Tek seçenek uygulamayı sıfırlamak. Bu işlem bu cihazdaki ';
  static const String forgotBody2Strong = 'tüm renkleri ve kilitli notları kalıcı olarak siler';
  static const String forgotBody2Tail = '.';
  static const String wipeAll = 'Her şeyi sil ve sıfırla';
  static const String biometricReason = "Digura'yı açmak için kimliğini doğrula";

  static String wrongPin(int left) => 'Yanlış PIN. $left deneme hakkın kaldı.';
  static String lockoutWait(int seconds) => 'Çok fazla yanlış deneme. $seconds sn sonra tekrar dene.';
  static String bioFail(int left) =>
      'Parmak izi tanınmadı. Sensörü tamamen kapladığından emin ol. $left deneme hakkın kaldı.';

  // ─── PIN değiştirme ───
  static const String changePinTitle = "PIN'i değiştir";
  static const String changeCurrentTitle = "Mevcut PIN'ini gir";
  static const String changeCurrentSub = 'Değişikliği onaylamak için.';
  static const String changeNextTitle = "Yeni PIN'ini gir";
  static const String changeNextSub = "Mevcut PIN'den farklı 4 rakam seç.";
  static const String changeConfirmTitle = "Yeni PIN'i tekrar gir";
  static const String changeConfirmSub = 'Doğru yazdığından emin olalım.';
  static const String currentPinWrong = 'Mevcut PIN yanlış. Tekrar dene.';
  static const String samePin = 'Yeni PIN, mevcut PIN ile aynı olamaz.';
  static const String pinChangedSnack = 'PIN değiştirildi. Bir sonraki açılışta yeni PIN sorulur.';

  // ─── Ayarlar ───
  static const String settingsTitle = 'Ayarlar';
  static const String groupPrivacy = 'Gizlilik ve güvenlik';
  static const String security = 'Güvenlik';
  static const String groupNotifications = 'Bildirimler';
  static const String reminder = 'Günlük hatırlatıcı';
  static const String reminderOn = 'Her akşam saat 21:00';
  static const String reminderOff = 'Kapalı';
  static const String groupAppearance = 'Görünüm';
  static const String theme = 'Tema';
  static const String themeSystem = 'Sistem varsayılanı';
  static const String themeSystemSub = 'Telefonun açık / koyu ayarını izler';
  static const String themeSystemSuffix = ' · telefonun ayarını izler';
  static const String themeLight = 'Açık';
  static const String themeLightSub = 'Her zaman açık tema';
  static const String themeDark = 'Koyu';
  static const String themeDarkSub = 'Her zaman koyu tema';
  static const String groupSampleData = 'Örnek veri';
  static const String resetSample = 'Örnek veriye dön';
  static const String resetSampleSub = 'Örnek kayıtları yükler · demo PIN 2580';
  static const String resetSampleTitle = 'Örnek veriye dönülsün mü?';
  static const String resetSampleBody =
      'Bu cihazdaki tüm kayıtlar örnek veriyle değiştirilir, açılmış kapsül işaretleri sıfırlanır ve PIN demo PIN olan 2580 olur.';
  static const String resetSampleSnack = 'Örnek veri yüklendi · PIN: 2580';
  static const String groupAbout = 'Hakkında';
  static const String backToSettings = "Ayarlar'a dön";
  static const String groupAppLock = 'Uygulama kilidi';
  static const String changePinSub = 'Her açılışta sorulan 4 haneli PIN';
  static const String bioRow = 'Parmak izi ile aç';
  static const String bioRowOn = 'Açık · PIN yedek olarak kalır';
  static const String bioRowOff = 'Kapalı · kilit yalnızca PIN ile açılır';
  static const String securityNote =
      'PIN ve parmak izi ayarı yalnızca bu cihazda tutulur. Digura bunları hiçbir yere göndermez.';
  static const String reminderOnSnack = 'Hatırlatıcı açıldı: her akşam 21:00.';
  static const String reminderOffSnack = 'Hatırlatıcı kapatıldı.';
  static const String reminderDeniedSnack = 'Bildirim izni verilmedi. Hatırlatıcı açılamadı.';
  static const String bioOnSnack = 'Parmak izi açıldı.';
  static const String bioOffSnack = 'Parmak izi kapatıldı. Kilit yalnızca PIN ile açılır.';

  static String securitySub(bool bioOn) => 'PIN · parmak izi ${bioOn ? 'açık' : 'kapalı'}';
  static String themeSnack(String name) => 'Tema: $name · tüm ekranlara uygulandı';

  // ─── Bildirim ───
  static const String reminderChannelId = 'digura_daily_reminder';
  static const String reminderChannelName = 'Günlük hatırlatıcı';
  static const String reminderChannelDescription = 'Her akşam 21:00 günün rengini hatırlatır.';
  static const String reminderNotificationTitle = 'Bugün nasıldın?';
  static const String reminderNotificationBody = 'Günün rengini seçmeyi unutma.';
}
