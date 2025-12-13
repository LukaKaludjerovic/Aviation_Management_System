class Permission {
  static const String appLogin = 'AppLogin';
  static const String settingsUsers = 'SettingsUsers';
  static const String settingsModifyUsers = 'SettingsModifyUsers';
  static const String settingsRoles = 'SettingsRoles';
  static const String settingsModifyRoles = 'SettingsModifyRoles';
  static const String settingsAircraftTypes = 'SettingsAircraftTypes';
  static const String settingsModifyAircraftTypes = 'SettingsModifyAircraftTypes';
  static const String settingsAirports = 'SettingsAirports';
  static const String settingsModifyAirports = 'SettingsModifyAirports';
  static const String activeAircraft = 'ActiveAircraft';
  static const String historicAircraft = 'HistoricAircraft';
  static const String currentRoutes = 'CurrentRoutes';
  static const String historicRoutes = 'HistoricRoutes';
  static const String pendingMaintenance = 'PendingMaintenance';
  static const String historicMaintenance = 'HistoricMaintenance';

  static const List<String> all = <String>[
    appLogin,
    settingsUsers,
    settingsModifyUsers,
    settingsRoles,
    settingsModifyRoles,
    settingsAircraftTypes,
    settingsModifyAircraftTypes,
    settingsAirports,
    settingsModifyAirports,
    activeAircraft,
    historicAircraft,
    currentRoutes,
    historicRoutes,
    pendingMaintenance,
    historicMaintenance
  ];
}
