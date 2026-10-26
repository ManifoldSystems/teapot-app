// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get logsTitle => 'Log mesh';

  @override
  String get logsLocal => 'Riwayat lokal';

  @override
  String get logsAll => 'Semua device';

  @override
  String get logsThisDevice => 'Device ini (control)';

  @override
  String get logsLive => 'Live';

  @override
  String get logsPaused => 'Dijeda';

  @override
  String get logsReconnecting =>
      'Menghubungkan ulang · cek koneksi dan approval device';

  @override
  String get logsConnecting => 'Menghubungkan…';

  @override
  String get logsError => 'Log tidak bisa dimuat';

  @override
  String get logsPause => 'Jeda';

  @override
  String get logsResume => 'Lanjutkan';

  @override
  String get logsCopy => 'Salin log yang tampil';

  @override
  String get logsSearch => 'Cari pesan…';

  @override
  String get logsEmpty => 'Belum ada log yang cocok';

  @override
  String get homeLabel => 'Status';

  @override
  String get settingsLabel => 'Pengaturan';

  @override
  String get darkModeTitle => 'Mode Gelap';

  @override
  String get darkModeSubtitle => 'Ganti antara tema terang dan gelap';

  @override
  String get darkModeEnabled => 'Mode gelap diaktifkan';

  @override
  String get lightModeEnabled => 'Mode terang diaktifkan';

  @override
  String get animationsTitle => 'Animasi';

  @override
  String get animationsSubtitle => 'Aktifkan atau nonaktifkan animasi UI';

  @override
  String get animationsEnabled => 'Animasi diaktifkan';

  @override
  String get animationsDisabled => 'Animasi dinonaktifkan';

  @override
  String get aboutTitle => 'Tentang';

  @override
  String get versionTitle => 'Versi';

  @override
  String get exitAppTitle => 'Keluar Aplikasi?';

  @override
  String get exitAppMessage => 'Apakah Anda yakin ingin keluar?';

  @override
  String get cancelButton => 'Batal';

  @override
  String get exitButton => 'Keluar';

  @override
  String get pressBackAgain => 'Tekan kembali lagi untuk keluar';

  @override
  String get languageTitle => 'Bahasa';

  @override
  String get languageSubtitle => 'Pilih bahasa pilihan Anda';

  @override
  String get languageEnglish => 'Inggris';

  @override
  String get languageIndonesian => 'Indonesia';

  @override
  String get connectionOfflineTitle => 'Tidak Ada Koneksi Internet';

  @override
  String get connectionOfflineMessage =>
      'Anda sedang offline. Beberapa fitur dinonaktifkan.';

  @override
  String get connectionReconnecting => 'Menghubungkan kembali...';

  @override
  String get connectionRestored => 'Koneksi dipulihkan';

  @override
  String get appTitle => 'Teapot';

  @override
  String get statusStopped => 'Teapot mati';

  @override
  String get statusStoppedHint =>
      'Nyalakan supaya HP ini masuk mesh sebagai exit node: device lain bisa keluar ke internet lewat SIM HP ini.';

  @override
  String get startButton => 'Nyalakan';

  @override
  String get stopButton => 'Matikan';

  @override
  String get phaseStarting => 'Menyalakan…';

  @override
  String get phasePending => 'Menunggu persetujuan';

  @override
  String get phaseApproved => 'Sudah di mesh';

  @override
  String get phaseError => 'Ada masalah';

  @override
  String get approveHint =>
      'Buka halaman persetujuan, login kalau diminta, lalu ketuk “Add device”. Pastikan kodenya sama.';

  @override
  String get approveOpen => 'Buka halaman persetujuan';

  @override
  String get approveCopy => 'Salin link';

  @override
  String get linkCopied => 'Link disalin';

  @override
  String get deviceCode => 'Kode';

  @override
  String get presenceOnline => 'Terhubung ke control';

  @override
  String get presenceOffline => 'Menghubungkan ke control…';

  @override
  String get exitOn =>
      'Exit aktif: device yang disetujui bisa keluar lewat HP ini';

  @override
  String get exitOffDashboard => 'Exit HP ini mati. Nyalakan di dashboard.';

  @override
  String get publicIpTitle => 'IP publik';

  @override
  String get clientsTitle => 'Klien';

  @override
  String get clientsEmpty => 'Belum ada device yang memakai exit ini';

  @override
  String allowedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count device diizinkan',
      zero: 'Belum ada device yang diizinkan',
    );
    return '$_temp0';
  }

  @override
  String get logTitle => 'Log';

  @override
  String get teapotSettingsTitle => 'Teapot';

  @override
  String get controlUrlTitle => 'URL control';

  @override
  String get deviceNameTitle => 'Nama device';

  @override
  String get deviceNameHint => 'Kosong: android-<kode>';

  @override
  String get allowLanTitle => 'Izinkan LAN';

  @override
  String get allowLanSubtitle =>
      'Klien bisa mengakses jaringan lokal HP ini. Mati secara bawaan.';

  @override
  String get saveButton => 'Simpan';

  @override
  String get settingsSaved =>
      'Tersimpan. Teapot menyala ulang dengan pengaturan baru.';

  @override
  String get batteryTitle => 'Optimasi baterai';

  @override
  String get batterySubtitle =>
      'Kecualikan Teapot supaya Android tidak menghentikannya di latar belakang';

  @override
  String get meshLabel => 'Mesh';

  @override
  String get meshTitle => 'Device di mesh kamu';

  @override
  String get meshEmpty => 'Belum ada device lain yang disetujui';

  @override
  String get peerOnline => 'online';

  @override
  String get peerOffline => 'offline';

  @override
  String get peerExit => 'exit';

  @override
  String get peerUsingMe => 'memakai HP ini';

  @override
  String get recentTargets => 'Tujuan terakhir';

  @override
  String get targetRefused => 'ditolak';

  @override
  String presenceSince(String time) {
    return 'Terhubung ke control sejak $time';
  }
}
