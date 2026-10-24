class AppSettings {
  final String themeMode;
  final String accentColorHex;
  final String listDensity;
  final String defaultCurrency;
  final int firstDayOfWeek;
  final String dateFormat;
  final int globalReminderTime;
  final bool autoSyncEnabled;
  final DateTime? lastBackupTime;
  final bool appLockEnabled;

  AppSettings({
    this.themeMode = 'system',
    this.accentColorHex = '#2196F3',
    this.listDensity = 'comfortable',
    this.defaultCurrency = 'USD',
    this.firstDayOfWeek = 1,
    this.dateFormat = 'MM/dd/yyyy',
    this.globalReminderTime = 540,
    this.autoSyncEnabled = false,
    this.lastBackupTime,
    this.appLockEnabled = false,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        themeMode: json['themeMode'] as String? ?? 'system',
        accentColorHex: json['accentColorHex'] as String? ?? '#2196F3',
        listDensity: json['listDensity'] as String? ?? 'comfortable',
        defaultCurrency: json['defaultCurrency'] as String? ?? 'USD',
        firstDayOfWeek: json['firstDayOfWeek'] as int? ?? 1,
        dateFormat: json['dateFormat'] as String? ?? 'MM/dd/yyyy',
        globalReminderTime: json['globalReminderTime'] as int? ?? 540,
        autoSyncEnabled: json['autoSyncEnabled'] as bool? ?? false,
        lastBackupTime: json['lastBackupTime'] != null
            ? DateTime.parse(json['lastBackupTime'] as String)
            : null,
        appLockEnabled: json['appLockEnabled'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode,
        'accentColorHex': accentColorHex,
        'listDensity': listDensity,
        'defaultCurrency': defaultCurrency,
        'firstDayOfWeek': firstDayOfWeek,
        'dateFormat': dateFormat,
        'globalReminderTime': globalReminderTime,
        'autoSyncEnabled': autoSyncEnabled,
        'lastBackupTime': lastBackupTime?.toIso8601String(),
        'appLockEnabled': appLockEnabled,
      };
}
