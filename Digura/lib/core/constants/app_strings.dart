/// Kullanıcıya görünen tüm Türkçe metinler (DESIGN.md Bölüm 8).
///
/// Widget dosyalarında sabit metin yazılmaz; parametreli metinler burada
/// küçük yardımcı fonksiyonlar olarak durur.
abstract final class AppStrings { // Kullanıcıya Görünen Tüm Metinleri Tutan Class'tır.
  // ─── Uygulama ───
  static const String appName = 'Digura'; // Uygulamanın Adıdır.
  static const String appVersion = 'Sürüm 0.1.0 (MVP) · Android ve iOS'; // Hakkında Bölümündeki Sürüm Metnidir.

  // ─── Duygular ───
  static const String moodJoyful = 'Neşeli'; // Neşeli Duygunun Etiketidir.
  static const String moodCalmSad = 'Sakin / Hüzünlü'; // Sakin / Hüzünlü Duygunun Etiketidir.
  static const String moodAngryStressed = 'Öfkeli / Stresli'; // Öfkeli / Stresli Duygunun Etiketidir.
  static const String moodSerene = 'Dingin'; // Dingin Duygunun Etiketidir.
  static const String moodTired = 'Yorgun'; // Yorgun Duygunun Etiketidir.

  // ─── Takvim ───
  static const List<String> months = [ // Ay Adlarının Listesidir.
    'Ocak', // 1. Ayın Adıdır.
    'Şubat', // 2. Ayın Adıdır.
    'Mart', // 3. Ayın Adıdır.
    'Nisan', // 4. Ayın Adıdır.
    'Mayıs', // 5. Ayın Adıdır.
    'Haziran', // 6. Ayın Adıdır.
    'Temmuz', // 7. Ayın Adıdır.
    'Ağustos', // 8. Ayın Adıdır.
    'Eylül', // 9. Ayın Adıdır.
    'Ekim', // 10. Ayın Adıdır.
    'Kasım', // 11. Ayın Adıdır.
    'Aralık', // 12. Ayın Adıdır.
  ];

  /// `DateTime.weekday` sırası: 1 = Pazartesi … 7 = Pazar.
  static const List<String> weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar']; // Gün Adlarının Listesidir.
  static const List<String> weekdaysShort = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz']; // Kısa Gün Adlarının Listesidir.

  // ─── Ortak eylemler ───
  static const String cancel = 'Vazgeç'; // Vazgeç Butonunun Metnidir.
  static const String ok = 'Tamam'; // Tamam Butonunun Metnidir.
  static const String save = 'Kaydet'; // Kaydet Butonunun Metnidir.
  static const String next = 'Devam'; // Devam Butonunun Metnidir.
  static const String back = 'Geri'; // Geri Butonunun Metnidir.
  static const String close = 'Kapat'; // Kapat Butonunun Metnidir.
  static const String previousMonth = 'Önceki ay'; // Önceki Ay Butonunun Etiketidir.
  static const String nextMonth = 'Sonraki ay'; // Sonraki Ay Butonunun Etiketidir.

  // ─── Alt gezinme ───
  static const String navLabel = 'Ana gezinme'; // Alt Gezinme Çubuğunun Erişilebilirlik Etiketidir.
  static const String tabToday = 'Bugün'; // Bugün Sekmesinin Metnidir.
  static const String tabMap = 'Harita'; // Harita Sekmesinin Metnidir.
  static const String tabStats = 'İstatistik'; // İstatistik Sekmesinin Metnidir.

  // ─── Bugün (mood_entry) ───
  static const String todayTitle = 'Bugün nasıldın?'; // Bugün Ekranının Başlığıdır.
  static const String todaySavedTitle = 'Bugünün rengi kaydedildi'; // Kayıt Sonrası Bugün Ekranı Başlığıdır.
  static const String settingsTooltip = 'Ayarlar'; // Ayarlar Butonunun Tooltip Metnidir.
  static const String pickColor = 'Bir renk seç'; // Renk Seçimi Çağrı Metnidir.
  static const String pickColorHint = 'Renk zorunlu, not isteğe bağlı'; // Renk Seçimi İpucu Metnidir.
  static const String selectedMood = 'Seçilen duygu'; // Seçilen Duygu Etiketidir.
  static const String moodPickerLabel = 'Duygu rengi'; // Duygu Seçicinin Erişilebilirlik Etiketidir.
  static const String noteLabel = 'Tek cümlelik not · isteğe bağlı'; // Not Alanının Etiketidir.
  static const String notePlaceholder = 'Bugünü tek cümleyle anlat…'; // Not Alanının Yer Tutucu Metnidir.
  static const String noteLocked = '30 gün kilitli kalır'; // Notun Kilitli Kalacağını Belirten Metindir.
  static const String saveColor = 'Rengi kaydet'; // Rengi Kaydet Butonunun Metnidir.
  static const String savedPermanent = 'Kayıt kalıcıdır · düzenlenemez'; // Kaydın Kalıcı Olduğunu Belirten Metindir.
  static const String noteSealed = 'Notun kapsüle kilitlendi'; // Notun Kilitlendiğini Bildiren Metindir.
  static const String noNoteToday = 'Bugün not bırakmadın'; // Not Bırakılmadığını Belirten Metindir.
  static const String seeOnMap = 'Haritada gör'; // Haritada Gör Butonunun Metnidir.
  static const String tomorrowHint = 'Yarın yeni bir renk seçebilirsin.'; // Yarın Yeni Kayıt Yapılabileceği İpucudur.
  static const String savedSnack = 'Bugünün rengi kaydedildi'; // Kayıt Başarılı Snackbar Metnidir.
  static const String alreadySavedSnack = 'Bugün için zaten bir kayıt var'; // Mevcut Kayıt Uyarısı Snackbar Metnidir.
  static const String confirmTitle = 'Bugünün rengi kaydedilsin mi?'; // Kayıt Onay Diyaloğu Başlığıdır.
  static const String confirmBody = // Kayıt Onay Diyaloğu Gövde Metnidir.
      'Zaman kapsülü gereği bu kayıt sonradan düzenlenemez veya silinemez. Notun 30 gün kilitli kalır.'; // Kaydın Değiştirilemeyeceğini Açıklayan Metindir.
  static const String withNote = 'notlu'; // Notlu Kayıt Etiketidir.
  static const String withoutNote = 'notsuz'; // Notsuz Kayıt Etiketidir.

  static String noteCount(int length, int max) => '$length/$max'; // Not Karakter Sayacı Metnini Üretir.
  static String unlockOn(String date) => 'Açılış: $date'; // Kapsül Açılış Tarihi Metnini Üretir.
  static String capsuleRemaining(int days) => 'Kapsülün açılmasına $days gün kaldı'; // Kalan Gün Metnini Üretir.
  static String lockProgress(int elapsed, int total) => '$elapsed/$total'; // Kilit İlerleme Metnini Üretir.

  // ─── Harita (mood_calendar) ───
  static const String mapEyebrow = 'Renk haritası'; // Harita Ekranının Üstbilgi Metnidir.
  static const String mapTitle = 'Harita'; // Harita Ekranının Başlığıdır.
  static const String viewLabel = 'Görünüm'; // Görünüm Seçicinin Etiketidir.
  static const String viewMonth = 'Ay'; // Ay Görünümü Seçeneğidir.
  static const String viewYear = 'Yıl'; // Yıl Görünümü Seçeneğidir.
  static const String noEntry = 'Kayıt yok'; // Kayıtsız Gün Etiketidir.
  static const String mapHint = // Harita Ekranının İpucu Metnidir.
      'Kilit simgeli günlerin notları, kayıttan 30 gün sonra açılır. Noktalı günlerin kapsülü yeni açıldı; dokunarak aç.'; // Kilit ve Nokta Simgelerini Açıklayan Metindir.
  static const String capsuleDetail = 'Kapsül detayı'; // Kapsül Detay Panelinin Başlığıdır.
  static const String emptyCapsuleNote = 'Bu gün için not bırakılmamış.'; // Notsuz Kapsül Metnidir.
  static const String freshCapsule = 'yeni açıldı'; // Yeni Açılmış Kapsül Durum Etiketidir.
  static const String lockedCapsule = 'kilitli'; // Kilitli Kapsül Durum Etiketidir.

  static String monthColored(int count, int days) => '$count / $days gün renklendi'; // Ayda Renklenen Gün Sayısı Metnini Üretir.
  static String yearColored(int count) => '$count gün renklendi'; // Yılda Renklenen Gün Sayısı Metnini Üretir.
  static String capsuleOpened(String date) => 'Kapsül açıldı · $date'; // Kapsül Açılış Tarihi Metnini Üretir.
  static String quoted(String note) => '“$note”'; // Notu Tırnak İçine Alır.
  static String monthShort(int month) => months[month - 1].substring(0, 3); // Ay Adının İlk Üç Harfini Döndürür.
  static String miniMonthLabel(String month, int year, int count) => '$month $year, $count kayıt'; // Mini Ay Hücresinin Erişilebilirlik Etiketini Üretir.
  static String dayCellLabel(int day, String month, String mood, String? state) => // Gün Hücresinin Erişilebilirlik Etiketini Üretir.
      state == null ? '$day $month, $mood' : '$day $month, $mood, $state'; // Durum Varsa Etikete Ekler.

  // ─── İstatistik (mood_stats) ───
  static const String statsEyebrow = 'Yalnızca renkler'; // İstatistik Ekranının Üstbilgi Metnidir.
  static const String statsTitle = 'İstatistik'; // İstatistik Ekranının Başlığıdır.
  static const String statsSub = 'Aylık duygu dağılımı'; // İstatistik Ekranının Alt Başlığıdır.
  static const String statsEntriesThisMonth = 'kayıt bu ay'; // Bu Ayki Kayıt Sayısının Etiketidir.
  static const String statsMostFrequent = 'En sık'; // En Sık Duygu Etiketidir.
  static const String statsDistribution = 'Duygu dağılımı'; // Dağılım Bölümünün Başlığıdır.
  static const String statsEmptyTitle = 'Bu ay henüz kayıt yok'; // Boş İstatistik Başlığıdır.
  static const String statsEmptyBody = 'Günün rengini seçtiğinde dağılım burada görünecek.'; // Boş İstatistik Açıklamasıdır.
  static const String statsPrivacy = // İstatistik Gizlilik Notunun Metnidir.
      'İstatistikler yalnızca renkleri kullanır. Kilitli notlarına erişilmez, veriler cihazından çıkmaz.'; // Notlara Erişilmediğini Açıklayan Metindir.

  static String percent(int value) => '%$value'; // Yüzde Metnini Üretir.
  static String topMood(int value, String label) => '%$value $label'; // En Sık Duygu Yüzde Metnini Üretir.
  static String dayCount(int count) => '$count gün'; // Gün Sayısı Metnini Üretir.

  // ─── Karşılama (onboarding) ───
  static const String skip = 'Atla'; // Atla Butonunun Metnidir.
  static const String startToday = 'Günün rengini seç'; // Karşılama Bitiş Butonunun Metnidir.
  static const String onboardingPalette = 'Duygu renkleri'; // Karşılamadaki Palet Etiketidir.
  static const String welcomeTitle = 'Her gün tek bir renk.'; // Karşılama 1. Adım Başlığıdır.
  static const String welcomeBody = // Karşılama 1. Adım Gövde Metnidir.
      'Gününü beş duygu renginden biriyle ve en fazla 140 karakterlik tek bir cümleyle kaydet. Denemek için bir renge dokun.'; // Uygulamanın Temel Kullanımını Açıklayan Metindir.
  static const String capsuleTitle = 'Yazdıkların 30 gün kilitli kalır.'; // Karşılama 2. Adım Başlığıdır.
  static const String capsuleBody = // Karşılama 2. Adım Gövde Metnidir.
      'Rengini her zaman görürsün ama notunu hemen okuyamazsın. Kapsül açıldığında o günkü sana geri dönersin. Kayıtlar düzenlenemez, silinemez.'; // Zaman Kapsülü Kuralını Açıklayan Metindir.
  static const String capsuleSampleDate = '12 Eylül 2026 · Cumartesi'; // Örnek Kapsül Tarihidir.
  static const String capsuleSampleSub = 'Not, kayıttan 30 gün sonra okunabilir'; // Örnek Kapsül Alt Metnidir.
  static const String timelineStart = 'Kayıt'; // Zaman Çizelgesinin Başlangıç Etiketidir.
  static const String timelineMid = '18. gün'; // Zaman Çizelgesinin Orta Etiketidir.
  static const String timelineEnd = '30. gün'; // Zaman Çizelgesinin Bitiş Etiketidir.
  static const String mapPreviewTitle = 'Geçmişin, renk renk'; // Harita Önizleme Başlığıdır.
  static const String mapPreviewSub = 'örnek ay'; // Harita Önizleme Alt Metnidir.
  static const String startTitle = 'Geçmişini bir haritada gör.'; // Karşılama 3. Adım Başlığıdır.
  static const String startBody = 'Günler ısı haritasında renklenir, her ayın duygu dağılımı istatistiklerde görünür.'; // Karşılama 3. Adım Gövde Metnidir.
  static const String privacyTitle = 'Hesap yok, internet yok'; // Gizlilik Kartı Başlığıdır.
  static const String privacySub = 'Tüm kayıtlar yalnızca bu cihazda saklanır'; // Gizlilik Kartı Alt Metnidir.
  static const String reminderOnboarding = "Her akşam 21:00'de hatırlat"; // Karşılamadaki Hatırlatıcı Seçeneği Metnidir.
  static const String reminderOptional = 'İsteğe bağlı'; // Hatırlatıcının İsteğe Bağlı Olduğunu Belirten Metindir.
  static const String reminderPermission = 'Açık · bildirim izni istenecek'; // Bildirim İzni İsteneceğini Belirten Metindir.

  static String stepOf(int step, int total) => 'Adım $step / $total'; // Adım Göstergesi Metnini Üretir.

  // ─── Kilit (app_lock) ───
  static const String pinHintCreate = '4 rakam'; // PIN Oluşturma İpucudur.
  static const String pinHintConfirm = '2. kez'; // PIN Onaylama İpucudur.
  static const String restart = 'Baştan'; // Baştan Başla Butonunun Metnidir.
  static const String pinCreateTitle = 'Bir PIN oluştur'; // PIN Oluşturma Başlığıdır.
  static const String pinCreateSub = 'Digura her açıldığında bu 4 haneli PIN sorulur. Notların böylece korunur.'; // PIN Oluşturma Açıklamasıdır.
  static const String pinConfirmTitle = "PIN'ini tekrar gir"; // PIN Onaylama Başlığıdır.
  static const String pinConfirmSub = 'Doğru yazdığından emin olalım.'; // PIN Onaylama Açıklamasıdır.
  static const String pinCreated = 'PIN oluşturuldu'; // PIN Oluşturuldu Başlığıdır.
  static const String pinCreatedSub = 'Bu PIN yalnızca bu cihazda, şifrelenmiş olarak saklanır.'; // PIN Saklama Açıklamasıdır.
  static const String weakPin = 'Bu PIN tahmin edilmesi kolay. Sıralı ya da aynı rakamlardan oluşmayan bir PIN seç.'; // Zayıf PIN Uyarısıdır.
  static const String pinMismatch = "PIN'ler eşleşmedi. Yeni PIN'i baştan gir."; // PIN Eşleşmeme Uyarısıdır.
  static const String keypadLabel = 'Rakam tuşları'; // Tuş Takımının Erişilebilirlik Etiketidir.
  static const String deleteKey = 'Sil'; // Silme Tuşunun Etiketidir.

  static const String notNow = 'Şimdi değil'; // Şimdi Değil Butonunun Metnidir.
  static const String bioSetupTitle = 'Parmak izi ile aç'; // Biyometrik Kurulum Başlığıdır.
  static const String bioSetupSub = 'Her seferinde PIN yazmadan, tek dokunuşla aç. PIN yedek olarak hep kalır.'; // Biyometrik Kurulum Açıklamasıdır.
  static const String bioOnTitle = 'Parmak izi açık'; // Parmak İzi Açık Başlığıdır.
  static const String bioOnSub = 'Bir sonraki açılışta parmağını sensöre koyman yeterli.'; // Parmak İzi Açık Açıklamasıdır.
  static const String bioFactDevice = "Parmak izin Digura'ya ulaşmaz, eşleştirmeyi telefonun kendisi yapar."; // Parmak İzinin Cihazda Kaldığını Açıklayan Metindir.
  static const String bioFactFallback = 'Sensör tanımazsa her zaman PIN ile açabilirsin.'; // PIN Yedeğini Açıklayan Metindir.
  static const String bioPlaceFinger = 'Parmağını sensöre koy…'; // Parmak Yerleştirme Yönergesidir.
  static const String bioUse = 'Parmak izini kullan'; // Parmak İzini Kullan Butonunun Metnidir.
  static const String bioScanning = 'Taranıyor…'; // Tarama Durumu Metnidir.
  static const String bioSetupFailed = 'Parmak izi doğrulanamadı. Tekrar dene ya da şimdilik geç.'; // Biyometrik Kurulum Hata Metnidir.
  static const String bioUnavailable = 'Bu cihazda parmak izi kullanılamıyor. Kilit yalnızca PIN ile açılır.'; // Biyometrik Desteklenmiyor Metnidir.
  static const String bioIconLabel = 'Parmak izi simgesi'; // Parmak İzi Simgesinin Erişilebilirlik Etiketidir.
  static const String bioIconOnLabel = 'Parmak izi etkin'; // Etkin Parmak İzi Simgesinin Etiketidir.
  static const String bioSkippedSnack = "Parmak izi kapalı. Ayarlar'dan sonra açabilirsin."; // Biyometrik Atlandı Snackbar Metnidir.

  static const String lockPromptBio = "PIN'ini gir ya da parmak izini kullan"; // Biyometrik Açıkken Kilit Ekranı Yönergesidir.
  static const String lockPromptPin = "Devam etmek için PIN'ini gir"; // Yalnızca PIN İle Kilit Ekranı Yönergesidir.
  static const String bioTemporarilyOff = 'Parmak izi geçici olarak kapalı. PIN ile aç.'; // Biyometriğin Geçici Kapalı Olduğu Uyarısıdır.
  static const String bioKeyLabel = 'Parmak izi ile aç'; // Parmak İzi Tuşunun Etiketidir.
  static const String bioKeyOffLabel = 'Parmak izi geçici olarak kapalı'; // Devre Dışı Parmak İzi Tuşunun Etiketidir.
  static const String forgotPin = "PIN'imi unuttum"; // PIN'imi Unuttum Bağlantısının Metnidir.
  static const String unlockedTitle = 'Kilit açıldı'; // Kilit Açıldı Başlığıdır.
  static const String unlockedSub = 'Bugün sekmesi açılıyor…'; // Kilit Açıldı Alt Metnidir.
  static const String bioSheetTitle = "Digura'yı aç"; // Biyometrik Panel Başlığıdır.
  static const String bioSheetSub = 'Parmak izini doğrula'; // Biyometrik Panel Alt Başlığıdır.
  static const String bioSheetPlace = 'Parmağını sensöre koy'; // Biyometrik Panel Yönergesidir.
  static const String bioSheetOk = 'Doğrulandı'; // Biyometrik Doğrulama Başarı Metnidir.
  static const String bioSheetLockout = // Biyometrik Kilitlenme Metnidir.
      'Parmak izi 3 kez tanınmadı. Güvenliğin için sensör geçici olarak kapatıldı; PIN ile açtığında yeniden açılır.'; // Sensörün Geçici Kapatıldığını Açıklayan Metindir.
  static const String usePin = 'PIN kullan'; // PIN Kullan Butonunun Metnidir.
  static const String continueWithPin = 'PIN ile devam et'; // PIN İle Devam Et Butonunun Metnidir.
  static const String retry = 'Tekrar dene'; // Tekrar Dene Butonunun Metnidir.
  static const String forgotTitle = 'PIN kurtarılamaz'; // PIN Unutma Diyaloğu Başlığıdır.
  static const String forgotBody1 = // PIN Unutma Diyaloğunun İlk Paragrafıdır.
      "Digura'da hesap ya da sunucu olmadığı için PIN'i sıfırlayacak bir e-posta veya kod yok."; // PIN'in Neden Kurtarılamadığını Açıklayan Metindir.
  static const String forgotBody2Lead = 'Tek seçenek uygulamayı sıfırlamak. Bu işlem bu cihazdaki '; // İkinci Paragrafın Giriş Kısmıdır.
  static const String forgotBody2Strong = 'tüm renkleri ve kilitli notları kalıcı olarak siler'; // İkinci Paragrafın Vurgulu Kısmıdır.
  static const String forgotBody2Tail = '.'; // İkinci Paragrafın Bitiş Kısmıdır.
  static const String wipeAll = 'Her şeyi sil ve sıfırla'; // Tümünü Sil Butonunun Metnidir.
  static const String biometricReason = "Digura'yı açmak için kimliğini doğrula"; // Sistem Biyometrik İsteminin Gerekçe Metnidir.

  static String wrongPin(int left) => 'Yanlış PIN. $left deneme hakkın kaldı.'; // Kalan Deneme Hakkıyla Yanlış PIN Metnini Üretir.
  static String lockoutWait(int seconds) => 'Çok fazla yanlış deneme. $seconds sn sonra tekrar dene.'; // Bekleme Süresi Metnini Üretir.
  static String bioFail(int left) => // Kalan Hakla Parmak İzi Hata Metnini Üretir.
      'Parmak izi tanınmadı. Sensörü tamamen kapladığından emin ol. $left deneme hakkın kaldı.'; // Kalan Deneme Hakkını İçeren Metindir.

  // ─── PIN değiştirme ───
  static const String changePinTitle = "PIN'i değiştir"; // PIN Değiştirme Başlığıdır.
  static const String changeCurrentTitle = "Mevcut PIN'ini gir"; // Mevcut PIN Adımının Başlığıdır.
  static const String changeCurrentSub = 'Değişikliği onaylamak için.'; // Mevcut PIN Adımının Açıklamasıdır.
  static const String changeNextTitle = "Yeni PIN'ini gir"; // Yeni PIN Adımının Başlığıdır.
  static const String changeNextSub = "Mevcut PIN'den farklı 4 rakam seç."; // Yeni PIN Adımının Açıklamasıdır.
  static const String changeConfirmTitle = "Yeni PIN'i tekrar gir"; // Yeni PIN Onay Adımının Başlığıdır.
  static const String changeConfirmSub = 'Doğru yazdığından emin olalım.'; // Yeni PIN Onay Adımının Açıklamasıdır.
  static const String currentPinWrong = 'Mevcut PIN yanlış. Tekrar dene.'; // Mevcut PIN Yanlış Uyarısıdır.
  static const String samePin = 'Yeni PIN, mevcut PIN ile aynı olamaz.'; // Aynı PIN Uyarısıdır.
  static const String pinChangedSnack = 'PIN değiştirildi. Bir sonraki açılışta yeni PIN sorulur.'; // PIN Değişti Snackbar Metnidir.

  // ─── Ayarlar ───
  static const String settingsTitle = 'Ayarlar'; // Ayarlar Ekranının Başlığıdır.
  static const String groupPrivacy = 'Gizlilik ve güvenlik'; // Gizlilik Grubunun Başlığıdır.
  static const String security = 'Güvenlik'; // Güvenlik Satırının Metnidir.
  static const String groupNotifications = 'Bildirimler'; // Bildirimler Grubunun Başlığıdır.
  static const String reminder = 'Günlük hatırlatıcı'; // Hatırlatıcı Satırının Metnidir.
  static const String reminderOn = 'Her akşam saat 21:00'; // Hatırlatıcı Açık Alt Metnidir.
  static const String reminderOff = 'Kapalı'; // Hatırlatıcı Kapalı Alt Metnidir.
  static const String groupAppearance = 'Görünüm'; // Görünüm Grubunun Başlığıdır.
  static const String theme = 'Tema'; // Tema Satırının Metnidir.
  static const String themeSystem = 'Sistem varsayılanı'; // Sistem Teması Seçeneğidir.
  static const String themeSystemSub = 'Telefonun açık / koyu ayarını izler'; // Sistem Teması Açıklamasıdır.
  static const String themeSystemSuffix = ' · telefonun ayarını izler'; // Sistem Teması Satır Eki Metnidir.
  static const String themeLight = 'Açık'; // Açık Tema Seçeneğidir.
  static const String themeLightSub = 'Her zaman açık tema'; // Açık Tema Açıklamasıdır.
  static const String themeDark = 'Koyu'; // Koyu Tema Seçeneğidir.
  static const String themeDarkSub = 'Her zaman koyu tema'; // Koyu Tema Açıklamasıdır.
  static const String groupSampleData = 'Örnek veri'; // Örnek Veri Grubunun Başlığıdır.
  static const String resetSample = 'Örnek veriye dön'; // Örnek Veriye Dön Satırının Metnidir.
  static const String resetSampleSub = 'Örnek kayıtları yükler · demo PIN 2580'; // Örnek Veriye Dön Alt Metnidir.
  static const String resetSampleTitle = 'Örnek veriye dönülsün mü?'; // Örnek Veri Onay Diyaloğu Başlığıdır.
  static const String resetSampleBody = // Örnek Veri Onay Diyaloğu Gövde Metnidir.
      'Bu cihazdaki tüm kayıtlar örnek veriyle değiştirilir, açılmış kapsül işaretleri sıfırlanır ve PIN demo PIN olan 2580 olur.'; // Sıfırlamanın Etkilerini Açıklayan Metindir.
  static const String resetSampleSnack = 'Örnek veri yüklendi · PIN: 2580'; // Örnek Veri Yüklendi Snackbar Metnidir.
  static const String groupAbout = 'Hakkında'; // Hakkında Grubunun Başlığıdır.
  static const String backToSettings = "Ayarlar'a dön"; // Ayarlara Dön Butonunun Metnidir.
  static const String groupAppLock = 'Uygulama kilidi'; // Uygulama Kilidi Grubunun Başlığıdır.
  static const String changePinSub = 'Her açılışta sorulan 4 haneli PIN'; // PIN Değiştir Satırının Alt Metnidir.
  static const String bioRow = 'Parmak izi ile aç'; // Parmak İzi Satırının Metnidir.
  static const String bioRowOn = 'Açık · PIN yedek olarak kalır'; // Parmak İzi Açık Alt Metnidir.
  static const String bioRowOff = 'Kapalı · kilit yalnızca PIN ile açılır'; // Parmak İzi Kapalı Alt Metnidir.
  static const String securityNote = // Güvenlik Notunun Metnidir.
      'PIN ve parmak izi ayarı yalnızca bu cihazda tutulur. Digura bunları hiçbir yere göndermez.'; // Verilerin Cihazda Kaldığını Açıklayan Metindir.
  static const String reminderOnSnack = 'Hatırlatıcı açıldı: her akşam 21:00.'; // Hatırlatıcı Açıldı Snackbar Metnidir.
  static const String reminderOffSnack = 'Hatırlatıcı kapatıldı.'; // Hatırlatıcı Kapatıldı Snackbar Metnidir.
  static const String reminderDeniedSnack = 'Bildirim izni verilmedi. Hatırlatıcı açılamadı.'; // Bildirim İzni Reddedildi Snackbar Metnidir.
  static const String bioOnSnack = 'Parmak izi açıldı.'; // Parmak İzi Açıldı Snackbar Metnidir.
  static const String bioOffSnack = 'Parmak izi kapatıldı. Kilit yalnızca PIN ile açılır.'; // Parmak İzi Kapatıldı Snackbar Metnidir.

  static String securitySub(bool bioOn) => 'PIN · parmak izi ${bioOn ? 'açık' : 'kapalı'}'; // Parmak İzi Durumuna Göre Güvenlik Alt Metnini Üretir.
  static String themeSnack(String name) => 'Tema: $name · tüm ekranlara uygulandı'; // Tema Değişti Snackbar Metnini Üretir.

  // ─── Bildirim ───
  static const String reminderChannelId = 'digura_daily_reminder'; // Android Bildirim Kanalının id'sidir.
  static const String reminderChannelName = 'Günlük hatırlatıcı'; // Bildirim Kanalının Adıdır.
  static const String reminderChannelDescription = 'Her akşam 21:00 günün rengini hatırlatır.'; // Bildirim Kanalının Açıklamasıdır.
  static const String reminderNotificationTitle = 'Bugün nasıldın?'; // Hatırlatıcı Bildiriminin Başlığıdır.
  static const String reminderNotificationBody = 'Günün rengini seçmeyi unutma.'; // Hatırlatıcı Bildiriminin Gövde Metnidir.
}
