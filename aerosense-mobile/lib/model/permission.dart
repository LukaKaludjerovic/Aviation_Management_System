class Permission {
  static const String appLogin = 'AppLogin';
  static const String settingsUsers = 'SettingsUsers';
  static const String settingsModifyUsers = 'SettingsModifyUsers';
  static const String settingsRoles = 'SettingsRoles';
  static const String settingsModifyRoles = 'SettingsModifyRoles';
  static const String aircraft = 'Aircraft';
  static const String routes = 'Routes';
  static const String maintenance = 'Maintenance';

  static const List<String> all = <String>[
    appLogin,
    settingsUsers,
    settingsModifyUsers,
    settingsRoles,
    settingsModifyRoles,
    aircraft,
    routes,
    maintenance
  ];
}
