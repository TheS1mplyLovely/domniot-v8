import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('tr')
  ];

  /// The title of the application
  ///
  /// In tr, this message translates to:
  /// **'DOMINOiT'**
  String get appTitle;

  /// Subtitle of the app
  ///
  /// In tr, this message translates to:
  /// **'Akıllı Bitki İzleme'**
  String get smartPlantMonitoring;

  /// Developed by text on splash
  ///
  /// In tr, this message translates to:
  /// **'Geliştiren'**
  String get splashDevelopedBy;

  /// Team name on splash
  ///
  /// In tr, this message translates to:
  /// **'Ekal Tech Team'**
  String get splashTeam;

  /// Home screen title
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get homeTitle;

  /// Temperature label
  ///
  /// In tr, this message translates to:
  /// **'Sıcaklık'**
  String get temperature;

  /// Humidity label
  ///
  /// In tr, this message translates to:
  /// **'Nem'**
  String get humidity;

  /// Soil moisture label
  ///
  /// In tr, this message translates to:
  /// **'Toprak Nemı'**
  String get soilMoisture;

  /// Plant stress label
  ///
  /// In tr, this message translates to:
  /// **'Bitki Stresi'**
  String get plantStress;

  /// Stress level label
  ///
  /// In tr, this message translates to:
  /// **'Stres Seviyesi'**
  String get stressLevel;

  /// Capture photo button
  ///
  /// In tr, this message translates to:
  /// **'Bitki Fotoğrafı Çek'**
  String get capturePhoto;

  /// Refresh data button
  ///
  /// In tr, this message translates to:
  /// **'Verileri Yenile'**
  String get refreshData;

  /// Settings title
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// ESP32 URL label
  ///
  /// In tr, this message translates to:
  /// **'ESP32 URL'**
  String get esp32Url;

  /// Target RGB values label
  ///
  /// In tr, this message translates to:
  /// **'Hedef RGB Değerleri'**
  String get targetRgb;

  /// Red color label
  ///
  /// In tr, this message translates to:
  /// **'Kırmızı'**
  String get red;

  /// Green color label
  ///
  /// In tr, this message translates to:
  /// **'Yeşil'**
  String get green;

  /// Blue color label
  ///
  /// In tr, this message translates to:
  /// **'Mavi'**
  String get blue;

  /// Dark mode label
  ///
  /// In tr, this message translates to:
  /// **'Karanlık Mod'**
  String get darkMode;

  /// Language label
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// Save button
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// Cancel button
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// Save success message
  ///
  /// In tr, this message translates to:
  /// **'Başarıyla kaydedildi'**
  String get savedSuccessfully;

  /// Error label
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// Connection error message
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı hatası'**
  String get connectionError;

  /// No data message
  ///
  /// In tr, this message translates to:
  /// **'Veri yok'**
  String get noData;

  /// Loading message
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get loading;

  /// Analyzing message
  ///
  /// In tr, this message translates to:
  /// **'Analiz ediliyor...'**
  String get analyzing;

  /// Analysis complete message
  ///
  /// In tr, this message translates to:
  /// **'Analiz tamamlandı'**
  String get analysisComplete;

  /// RGB values label
  ///
  /// In tr, this message translates to:
  /// **'RGB Değerleri'**
  String get rgbValues;

  /// Stress score label
  ///
  /// In tr, this message translates to:
  /// **'Stres Skoru'**
  String get stressScore;

  /// Healthy status
  ///
  /// In tr, this message translates to:
  /// **'Sağlıklı'**
  String get healthy;

  /// Stressed status
  ///
  /// In tr, this message translates to:
  /// **'Stresli'**
  String get stressed;

  /// Critical status
  ///
  /// In tr, this message translates to:
  /// **'Kritik'**
  String get critical;

  /// Notification message for plant stress
  ///
  /// In tr, this message translates to:
  /// **'Bitki stresi tespit edildi! Hemen kontrol edin.'**
  String get plantStressDetected;

  /// Simulation mode label
  ///
  /// In tr, this message translates to:
  /// **'Simülasyon Modu'**
  String get simulationMode;

  /// Use simulation toggle
  ///
  /// In tr, this message translates to:
  /// **'ESP32 simülasyonu kullan'**
  String get useSimulation;

  /// App info section title
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Bilgileri'**
  String get appInfo;

  /// Version label
  ///
  /// In tr, this message translates to:
  /// **'Sürüm'**
  String get version;

  /// Developer label
  ///
  /// In tr, this message translates to:
  /// **'Geliştirici'**
  String get developer;

  /// Team label
  ///
  /// In tr, this message translates to:
  /// **'Ekip'**
  String get team;

  /// Reset to defaults button
  ///
  /// In tr, this message translates to:
  /// **'Varsayılanlara Sıfırla'**
  String get resetDefaults;

  /// Confirm reset message
  ///
  /// In tr, this message translates to:
  /// **'Tüm ayarları varsayılanlara sıfırlamak istediğinizden emin misiniz?'**
  String get confirmReset;

  /// Yes button
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No button
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// Take photo button
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Çek'**
  String get takePhoto;

  /// Choose from gallery button
  ///
  /// In tr, this message translates to:
  /// **'Galeriden Seç'**
  String get chooseFromGallery;

  /// Analyze button
  ///
  /// In tr, this message translates to:
  /// **'Analiz Et'**
  String get analyze;

  /// Result label
  ///
  /// In tr, this message translates to:
  /// **'Sonuç'**
  String get result;

  /// Target color label
  ///
  /// In tr, this message translates to:
  /// **'Hedef Renk'**
  String get targetColor;

  /// Detected color label
  ///
  /// In tr, this message translates to:
  /// **'Tespit Edilen Renk'**
  String get detectedColor;

  /// Difference label
  ///
  /// In tr, this message translates to:
  /// **'Fark'**
  String get difference;

  /// Retry button
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// Back button
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// Celsius unit
  ///
  /// In tr, this message translates to:
  /// **'°C'**
  String get celsius;

  /// Percent unit
  ///
  /// In tr, this message translates to:
  /// **'%'**
  String get percent;

  /// Low status
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get low;

  /// Normal status
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get normal;

  /// High status
  ///
  /// In tr, this message translates to:
  /// **'Yüksek'**
  String get high;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
