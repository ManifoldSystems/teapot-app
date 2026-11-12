// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get logsTitle => 'Mesh logs';

  @override
  String get logsLocal => 'Local history';

  @override
  String get logsAll => 'All devices';

  @override
  String get logsThisDevice => 'This device (control)';

  @override
  String get logsLive => 'Live';

  @override
  String get logsPaused => 'Paused';

  @override
  String get logsReconnecting =>
      'Reconnecting · check connection and device approval';

  @override
  String get logsConnecting => 'Connecting…';

  @override
  String get logsError => 'Could not load logs';

  @override
  String get logsPause => 'Pause';

  @override
  String get logsResume => 'Resume';

  @override
  String get logsCopy => 'Copy visible logs';

  @override
  String get logsSearch => 'Filter messages…';

  @override
  String get logsEmpty => 'No matching logs yet';

  @override
  String get homeLabel => 'Status';

  @override
  String get settingsLabel => 'Settings';

  @override
  String get darkModeTitle => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Switch between light and dark theme';

  @override
  String get darkModeEnabled => 'Dark mode enabled';

  @override
  String get lightModeEnabled => 'Light mode enabled';

  @override
  String get animationsTitle => 'Animations';

  @override
  String get animationsSubtitle => 'Enable or disable UI animations';

  @override
  String get animationsEnabled => 'Animations enabled';

  @override
  String get animationsDisabled => 'Animations disabled';

  @override
  String get aboutTitle => 'About';

  @override
  String get versionTitle => 'Version';

  @override
  String get exitAppTitle => 'Exit App?';

  @override
  String get exitAppMessage => 'Are you sure you want to exit?';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get exitButton => 'Exit';

  @override
  String get pressBackAgain => 'Press back again to exit';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Select your preferred language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Indonesian';

  @override
  String get connectionOfflineTitle => 'No Internet Connection';

  @override
  String get connectionOfflineMessage =>
      'You are currently offline. Some features are disabled.';

  @override
  String get connectionReconnecting => 'Reconnecting...';

  @override
  String get connectionRestored => 'Connection restored';

  @override
  String get appTitle => 'Teapot';

  @override
  String get statusStopped => 'Teapot is off';

  @override
  String get statusStoppedHint =>
      'Start it to put this phone in your mesh as an exit node: other devices can leave the internet through this phone\'s SIM.';

  @override
  String get startButton => 'Start';

  @override
  String get stopButton => 'Stop';

  @override
  String get phaseStarting => 'Starting…';

  @override
  String get phasePending => 'Waiting for approval';

  @override
  String get phaseApproved => 'In your mesh';

  @override
  String get phaseError => 'Problem';

  @override
  String get approveHint =>
      'Open the approval page, sign in if asked, and tap “Add device”. Check that the page shows the same code.';

  @override
  String get approveOpen => 'Open approval page';

  @override
  String get approveCopy => 'Copy link';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get deviceCode => 'Code';

  @override
  String get presenceOnline => 'Connected to control';

  @override
  String get presenceOffline => 'Connecting to control…';

  @override
  String get exitOn => 'Exit on: approved devices can leave through this phone';

  @override
  String get exitOffDashboard =>
      'Exit is off for this phone. Turn it on in the dashboard.';

  @override
  String get publicIpTitle => 'Public IP';

  @override
  String get clientsTitle => 'Clients';

  @override
  String get clientsEmpty => 'No device is using this exit yet';

  @override
  String allowedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices allowed',
      one: '1 device allowed',
      zero: 'No device allowed yet',
    );
    return '$_temp0';
  }

  @override
  String get logTitle => 'Log';

  @override
  String get teapotSettingsTitle => 'Teapot';

  @override
  String get controlUrlTitle => 'Control URL';

  @override
  String get controlUrlInvalid =>
      'Enter an http(s) URL without credentials, query or fragment.';

  @override
  String get deviceNameTitle => 'Device name';

  @override
  String get deviceNameHint => 'Empty: android-<code>';

  @override
  String get allowLanTitle => 'Allow LAN';

  @override
  String get allowLanSubtitle =>
      'Let clients reach this phone\'s local network. Off by default.';

  @override
  String get saveButton => 'Save';

  @override
  String get settingsSaved => 'Saved. Teapot restarts with the new settings.';

  @override
  String get batteryTitle => 'Battery optimisation';

  @override
  String get batterySubtitle =>
      'Exempt Teapot so Android does not stop it in the background';

  @override
  String get meshLabel => 'Mesh';

  @override
  String get meshTitle => 'Devices in your mesh';

  @override
  String get meshEmpty => 'No other approved devices yet';

  @override
  String get peerOnline => 'online';

  @override
  String get peerOffline => 'offline';

  @override
  String get peerExit => 'exit';

  @override
  String get peerUsingMe => 'using this phone';

  @override
  String get recentTargets => 'Recent destinations';

  @override
  String get targetRefused => 'refused';

  @override
  String presenceSince(String time) {
    return 'Connected to control since $time';
  }
}
