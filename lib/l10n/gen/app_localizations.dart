import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
    Locale('id'),
  ];

  /// No description provided for @logsTitle.
  ///
  /// In en, this message translates to:
  /// **'Mesh logs'**
  String get logsTitle;

  /// No description provided for @logsLocal.
  ///
  /// In en, this message translates to:
  /// **'Local history'**
  String get logsLocal;

  /// No description provided for @logsAll.
  ///
  /// In en, this message translates to:
  /// **'All devices'**
  String get logsAll;

  /// No description provided for @logsThisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device (control)'**
  String get logsThisDevice;

  /// No description provided for @logsLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get logsLive;

  /// No description provided for @logsPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get logsPaused;

  /// No description provided for @logsReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting · check connection and device approval'**
  String get logsReconnecting;

  /// No description provided for @logsConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get logsConnecting;

  /// No description provided for @logsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load logs'**
  String get logsError;

  /// No description provided for @logsPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get logsPause;

  /// No description provided for @logsResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get logsResume;

  /// No description provided for @logsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy visible logs'**
  String get logsCopy;

  /// No description provided for @logsSearch.
  ///
  /// In en, this message translates to:
  /// **'Filter messages…'**
  String get logsSearch;

  /// No description provided for @logsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching logs yet'**
  String get logsEmpty;

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get homeLabel;

  /// No description provided for @settingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabel;

  /// No description provided for @darkModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeTitle;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark theme'**
  String get darkModeSubtitle;

  /// No description provided for @darkModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Dark mode enabled'**
  String get darkModeEnabled;

  /// No description provided for @lightModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Light mode enabled'**
  String get lightModeEnabled;

  /// No description provided for @animationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get animationsTitle;

  /// No description provided for @animationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable UI animations'**
  String get animationsSubtitle;

  /// No description provided for @animationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Animations enabled'**
  String get animationsEnabled;

  /// No description provided for @animationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Animations disabled'**
  String get animationsDisabled;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @versionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionTitle;

  /// No description provided for @exitAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit App?'**
  String get exitAppTitle;

  /// No description provided for @exitAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit?'**
  String get exitAppMessage;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @exitButton.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitButton;

  /// No description provided for @pressBackAgain.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressBackAgain;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get languageSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get languageIndonesian;

  /// No description provided for @connectionOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get connectionOfflineTitle;

  /// No description provided for @connectionOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'You are currently offline. Some features are disabled.'**
  String get connectionOfflineMessage;

  /// No description provided for @connectionReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting...'**
  String get connectionReconnecting;

  /// No description provided for @connectionRestored.
  ///
  /// In en, this message translates to:
  /// **'Connection restored'**
  String get connectionRestored;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Teapot'**
  String get appTitle;

  /// No description provided for @statusStopped.
  ///
  /// In en, this message translates to:
  /// **'Teapot is off'**
  String get statusStopped;

  /// No description provided for @statusStoppedHint.
  ///
  /// In en, this message translates to:
  /// **'Start it to put this phone in your mesh as an exit node: other devices can leave the internet through this phone\'s SIM.'**
  String get statusStoppedHint;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// No description provided for @stopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopButton;

  /// No description provided for @phaseStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting…'**
  String get phaseStarting;

  /// No description provided for @phasePending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get phasePending;

  /// No description provided for @phaseApproved.
  ///
  /// In en, this message translates to:
  /// **'In your mesh'**
  String get phaseApproved;

  /// No description provided for @phaseError.
  ///
  /// In en, this message translates to:
  /// **'Problem'**
  String get phaseError;

  /// No description provided for @approveHint.
  ///
  /// In en, this message translates to:
  /// **'Open the approval page, sign in if asked, and tap “Add device”. Check that the page shows the same code.'**
  String get approveHint;

  /// No description provided for @approveOpen.
  ///
  /// In en, this message translates to:
  /// **'Open approval page'**
  String get approveOpen;

  /// No description provided for @approveCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get approveCopy;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @deviceCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get deviceCode;

  /// No description provided for @presenceOnline.
  ///
  /// In en, this message translates to:
  /// **'Connected to control'**
  String get presenceOnline;

  /// No description provided for @presenceOffline.
  ///
  /// In en, this message translates to:
  /// **'Connecting to control…'**
  String get presenceOffline;

  /// No description provided for @exitOn.
  ///
  /// In en, this message translates to:
  /// **'Exit on: approved devices can leave through this phone'**
  String get exitOn;

  /// No description provided for @exitOffDashboard.
  ///
  /// In en, this message translates to:
  /// **'Exit is off for this phone. Turn it on in the dashboard.'**
  String get exitOffDashboard;

  /// No description provided for @publicIpTitle.
  ///
  /// In en, this message translates to:
  /// **'Public IP'**
  String get publicIpTitle;

  /// No description provided for @clientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clientsTitle;

  /// No description provided for @clientsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No device is using this exit yet'**
  String get clientsEmpty;

  /// No description provided for @allowedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No device allowed yet} =1{1 device allowed} other{{count} devices allowed}}'**
  String allowedCount(int count);

  /// No description provided for @logTitle.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get logTitle;

  /// No description provided for @teapotSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Teapot'**
  String get teapotSettingsTitle;

  /// No description provided for @controlUrlTitle.
  ///
  /// In en, this message translates to:
  /// **'Control URL'**
  String get controlUrlTitle;

  /// No description provided for @deviceNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get deviceNameTitle;

  /// No description provided for @deviceNameHint.
  ///
  /// In en, this message translates to:
  /// **'Empty: android-<code>'**
  String get deviceNameHint;

  /// No description provided for @allowLanTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow LAN'**
  String get allowLanTitle;

  /// No description provided for @allowLanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let clients reach this phone\'s local network. Off by default.'**
  String get allowLanSubtitle;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. Teapot restarts with the new settings.'**
  String get settingsSaved;

  /// No description provided for @batteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery optimisation'**
  String get batteryTitle;

  /// No description provided for @batterySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Exempt Teapot so Android does not stop it in the background'**
  String get batterySubtitle;

  /// No description provided for @meshLabel.
  ///
  /// In en, this message translates to:
  /// **'Mesh'**
  String get meshLabel;

  /// No description provided for @meshTitle.
  ///
  /// In en, this message translates to:
  /// **'Devices in your mesh'**
  String get meshTitle;

  /// No description provided for @meshEmpty.
  ///
  /// In en, this message translates to:
  /// **'No other approved devices yet'**
  String get meshEmpty;

  /// No description provided for @peerOnline.
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get peerOnline;

  /// No description provided for @peerOffline.
  ///
  /// In en, this message translates to:
  /// **'offline'**
  String get peerOffline;

  /// No description provided for @peerExit.
  ///
  /// In en, this message translates to:
  /// **'exit'**
  String get peerExit;

  /// No description provided for @peerUsingMe.
  ///
  /// In en, this message translates to:
  /// **'using this phone'**
  String get peerUsingMe;

  /// No description provided for @recentTargets.
  ///
  /// In en, this message translates to:
  /// **'Recent destinations'**
  String get recentTargets;

  /// No description provided for @targetRefused.
  ///
  /// In en, this message translates to:
  /// **'refused'**
  String get targetRefused;

  /// No description provided for @presenceSince.
  ///
  /// In en, this message translates to:
  /// **'Connected to control since {time}'**
  String presenceSince(String time);
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
