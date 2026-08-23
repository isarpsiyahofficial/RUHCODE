/// Canonical action IDs used by the currently implemented runtime UI.
///
/// These values must exist as ACTIVE rows in the base action registry or its
/// explicit runtime extension registry. Keeping runtime widgets tied to these
/// IDs lets structural and widget tests detect dead controls and information-
/// architecture drift.
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

  /// These controls live on SCR-PDF-BUILDER-001. Historical PREVIEW action
  /// IDs must never be used by the professional builder runtime.
  static const pdfPreflight = 'ACTION-PDF-BUILDER-PREVIEW';
  static const pdfCreate = 'ACTION-PDF-BUILDER-CREATE';
  static const pdfShare = 'ACTION-PDF-BUILDER-SHARE';

  static const backupExport = 'ACTION-BACKUP-EXPORT';
  static const backupShare = 'ACTION-BACKUP-SHARE';
  static const backupImport = 'ACTION-BACKUP-IMPORT';
  static const backupRestoreMerge = 'ACTION-BACKUP-RESTORE-MERGE';
  static const backupRestoreReplace = 'ACTION-BACKUP-RESTORE-REPLACE';

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
    pdfPreflight,
    pdfCreate,
    pdfShare,
    backupExport,
    backupShare,
    backupImport,
    backupRestoreMerge,
    backupRestoreReplace,
  };
}