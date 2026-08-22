/// Canonical action IDs used by the currently implemented runtime UI.
///
/// These values must exist as ACTIVE rows in `ui/action_registry.csv`.
/// Keeping runtime widgets tied to these IDs lets structural and widget tests
/// detect dead controls and information-architecture drift.
abstract final class RuhActionIds {
  static const navigationToday = 'ACTION-NAV-TODAY';
  static const navigationTools = 'ACTION-NAV-TOOLS';
  static const navigationRecords = 'ACTION-NAV-RECORDS';
  static const navigationProfile = 'ACTION-NAV-PROFILE';

  static const toolsAstrology = 'ACTION-TOOLS-ASTROLOGY';
  static const toolsNumerology = 'ACTION-TOOLS-NUMEROLOGY';
  static const toolsSpiritual = 'ACTION-TOOLS-SPIRITUAL';
  static const toolsGrowth = 'ACTION-TOOLS-GROWTH';

  static const astrologyWestern = 'ACTION-ASTROLOGY-WESTERN';
  static const astrologyVedic = 'ACTION-ASTROLOGY-VEDIC';
  static const astrologyChinese = 'ACTION-ASTROLOGY-CHINESE';
  static const astrologyBazi = 'ACTION-ASTROLOGY-BAZI';
  static const astrologyPlanetaryHours = 'ACTION-ASTROLOGY-PLANETARY-HOURS';

  static const recordsProfiles = 'ACTION-RECORDS-PROFILES';
  static const recordsClients = 'ACTION-RECORDS-CLIENTS';
  static const profileSettings = 'ACTION-PROFILE-SETTINGS';
  static const settingsPdf = 'ACTION-SETTINGS-PDF';
  static const settingsBackup = 'ACTION-SETTINGS-BACKUP';
  static const pdfPreview = 'ACTION-PDF-PREVIEW';
  static const pdfBuild = 'ACTION-PDF-BUILD';
  static const pdfCreate = 'ACTION-PDF-PREVIEW-CREATE';
  static const pdfSave = 'ACTION-PDF-BUILDER-SAVE';
  static const pdfShare = 'ACTION-PDF-BUILDER-SHARE';
  static const backupExport = 'ACTION-BACKUP-EXPORT';
  static const backupImport = 'ACTION-BACKUP-IMPORT';

  static const allRuntimeBindings = <String>{
    navigationToday,
    navigationTools,
    navigationRecords,
    navigationProfile,
    toolsAstrology,
    toolsNumerology,
    toolsSpiritual,
    toolsGrowth,
    astrologyWestern,
    astrologyVedic,
    astrologyChinese,
    astrologyBazi,
    astrologyPlanetaryHours,
    recordsProfiles,
    recordsClients,
    profileSettings,
    settingsPdf,
    settingsBackup,
    pdfPreview,
    pdfBuild,
    pdfCreate,
    pdfSave,
    pdfShare,
    backupExport,
    backupImport,
  };
}
