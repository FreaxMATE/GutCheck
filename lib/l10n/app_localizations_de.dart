// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get navHome => 'Startseite';

  @override
  String get navPantry => 'Vorratskammer';

  @override
  String get navMealLog => 'Mahlzeitenlog';

  @override
  String get navWellness => 'Wohlbefinden';

  @override
  String get navInsights => 'Auswertung';

  @override
  String get homeLastWellnessTitle => 'Letzter Wohlbefindens-Check';

  @override
  String get homeLastMealTitle => 'Letzte Mahlzeit';

  @override
  String get homeWeeklyAvgTitle => '7-Tage-Durchschnitt';

  @override
  String get homeTopInsightTitle => 'Wichtigste Erkenntnis';

  @override
  String get homeNoWellnessYet => 'Noch keine Wohlbefindensdaten';

  @override
  String get homeNoMealsYet => 'Noch keine Mahlzeiten eingetragen';

  @override
  String get homeNoInsightYet =>
      'Trage mehr Mahlzeiten & Wohlbefindensdaten ein, um Lebensmittelerkenntnisse zu sehen.';

  @override
  String get homeViewHistory => 'Verlauf anzeigen';

  @override
  String get homeViewLog => 'Log anzeigen';

  @override
  String get homeViewInsights => 'Auswertung anzeigen';

  @override
  String get homeLogWellness => 'Wohlbefinden eintragen';

  @override
  String get homeLogMeal => 'Mahlzeit eintragen';

  @override
  String get homePossibleTrigger => 'Möglicher Auslöser';

  @override
  String get homeLikelyBeneficial => 'Scheinbar förderlich';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionData => 'Daten';

  @override
  String get settingsExportTitle => 'Alle Daten exportieren';

  @override
  String get settingsExportSubtitle => 'JSON-Backup aller Einträge teilen';

  @override
  String get settingsExportSuccess => 'Export bereit!';

  @override
  String settingsExportError(Object error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get settingsImportTitle => 'Daten importieren';

  @override
  String get settingsImportSubtitle =>
      'Ein vorheriges JSON-Backup wiederherstellen';

  @override
  String get settingsImportModeTitle =>
      'Wie sollen wir dieses Backup importieren?';

  @override
  String get settingsImportModeContent =>
      'Alles ersetzen löscht deine aktuellen Daten und stellt das Backup vollständig wieder her. Zusammenführen behält deine vorhandenen Daten und fügt neue Einträge aus dem Backup hinzu.';

  @override
  String get settingsImportModeMerge => 'Zusammenführen';

  @override
  String get settingsImportModeReplace => 'Alles ersetzen';

  @override
  String get settingsImportPickDialogTitle =>
      'JSON-Backup zum Importieren auswählen';

  @override
  String get settingsImportCancelled => 'Import abgebrochen';

  @override
  String settingsImportError(Object error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get settingsExportPantryTitle => 'Vorrat exportieren';

  @override
  String get settingsExportPantrySubtitle =>
      'Sicherungskopie eigener Lebensmittel teilen';

  @override
  String get settingsImportPantryTitle => 'Vorrat importieren';

  @override
  String get settingsImportPantrySubtitle =>
      'Eigene Lebensmittel aus Backup-Datei laden';

  @override
  String get settingsClearTitle => 'Alle Daten löschen';

  @override
  String get settingsClearSubtitle =>
      'Alle Mahlzeiten und Wohlbefindens­einträge dauerhaft löschen';

  @override
  String get settingsSectionAppearance => 'Erscheinungsbild';

  @override
  String get settingsThemeTitle => 'Design';

  @override
  String get settingsThemeSystem => 'Systemstandard';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsThemeDialogTitle => 'Design wählen';

  @override
  String get settingsSectionLanguage => 'Sprache';

  @override
  String get settingsLanguageAuto => 'Systemstandard';

  @override
  String get settingsLanguageDialogTitle => 'Sprache wählen';

  @override
  String get settingsSampleDataTitle => 'Beispieldaten';

  @override
  String get settingsSampleDataSubtitle =>
      'Demodaten laden, um die Auswertungsfunktionen zu erkunden';

  @override
  String get settingsSampleDataAdded => 'Beispieldaten geladen!';

  @override
  String get settingsSampleDataRemoved => 'Beispieldaten entfernt.';

  @override
  String get fodmapLow => 'Niedriger FODMAP';

  @override
  String get fodmapModerate => 'Mittlerer FODMAP';

  @override
  String get fodmapHigh => 'Hoher FODMAP';

  @override
  String get logMealBrowseByCategory => 'Nach Kategorie durchsuchen';

  @override
  String get settingsSectionAbout => 'Über';

  @override
  String get settingsAppVersion => 'v1.0.0 — Lokal, Open Source';

  @override
  String get settingsPrivacyTitle => 'Datenschutz';

  @override
  String get settingsPrivacySubtitle =>
      'Alle Daten werden nur auf diesem Gerät gespeichert. Es wird nichts an Server gesendet.';

  @override
  String get settingsClearDialogTitle => 'Alle Daten löschen?';

  @override
  String get settingsClearDialogContent =>
      'Dadurch werden alle Mahlzeiteneinträge, Wohlbefindensdaten und eigene Lebensmittel dauerhaft gelöscht. Dies kann nicht rükgängig gemacht werden.';

  @override
  String get settingsClearSuccess => 'Alle Daten gelöscht.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get deleteAll => 'Alles löschen';

  @override
  String get save => 'Speichern';

  @override
  String databaseError(Object error) {
    return 'Datenbankfehler: $error';
  }

  @override
  String genericError(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get pantryTitle => 'Vorratskammer';

  @override
  String get pantrySearchHint => 'Zutaten suchen…';

  @override
  String pantryNoResults(String query) {
    return 'Keine Ergebnisse für „$query“';
  }

  @override
  String get pantryEmpty => 'Keine Zutaten gefunden';

  @override
  String get pantryAddFood => 'Lebensmittel hinzufügen';

  @override
  String get pantryFodmapLevel => 'FODMAP-Stufe';

  @override
  String get pantryAlsoClassifiedAs => 'Auch klassifiziert als';

  @override
  String get pantryNotes => 'Notizen';

  @override
  String get pantryCustomFood => 'Eigenes Lebensmittel';

  @override
  String get pantryMyFoods => 'Meine Lebensmittel';

  @override
  String get addFoodTitle => 'Eigenes Lebensmittel hinzufügen';

  @override
  String get addFoodNameLabel => 'Lebensmittelname';

  @override
  String get addFoodNameHint => 'z. B. Drachenfrucht';

  @override
  String get addFoodNameRequired => 'Name ist erforderlich';

  @override
  String get addFoodCategoryLabel => 'Kategorie';

  @override
  String get addFoodFodmapLabel => 'FODMAP-Stufe';

  @override
  String get addFoodFodmapLow => 'Niedriger FODMAP';

  @override
  String get addFoodFodmapModerate => 'Mittlerer FODMAP';

  @override
  String get addFoodFodmapHigh => 'Hoher FODMAP';

  @override
  String get addFoodNotesHint => 'Persönliche Beobachtungen…';

  @override
  String get addFoodSave => 'Lebensmittel speichern';

  @override
  String addFoodAdded(String name) {
    return '$name hinzugefügt!';
  }

  @override
  String get mealEditTitle => 'Mahlzeit bearbeiten';

  @override
  String get mealLogTitle => 'Mahlzeitenlog';

  @override
  String get mealLogEmpty => 'Heute nichts eingetragen';

  @override
  String get mealLogEmptyHint => 'Tippe +, um deine erste Mahlzeit einzutragen';

  @override
  String get mealLogButton => 'Mahlzeit eintragen';

  @override
  String get mealDeleteTitle => 'Mahlzeit löschen?';

  @override
  String get mealDeleteContent => 'Dieser Eintrag wird entfernt.';

  @override
  String get mealFallbackLabel => 'Mahlzeit';

  @override
  String get mealBreakfast => 'Frühstück';

  @override
  String get mealLunch => 'Mittagessen';

  @override
  String get mealDinner => 'Abendessen';

  @override
  String get mealSnack => 'Snack';

  @override
  String get logMealTitle => 'Mahlzeit eintragen';

  @override
  String get logMealTapToChangeTime => 'Tippe zum Ändern der Zeit';

  @override
  String get logMealSearchHint => 'Zutaten suchen…';

  @override
  String logMealQuantityHint(String name) {
    return 'Menge für $name (optional)';
  }

  @override
  String get logMealAdd => 'Hinzufügen';

  @override
  String get logMealAdded => 'Hinzugefügt';

  @override
  String get logMealNotesHint => 'Notizen (optional)…';

  @override
  String get logMealValidation =>
      'Füge mindestens eine Zutat hinzu, um eine Mahlzeit einzutragen.';

  @override
  String get wellnessTitle => 'Wohlbefindens-Check';

  @override
  String get wellnessGutPeace => 'Darmruhe';

  @override
  String get wellnessGutPeaceMin => 'Unwohl';

  @override
  String get wellnessGutPeaceMax => 'Perfekt';

  @override
  String get wellnessHeartburn => 'Sodbrennen';

  @override
  String get wellnessHeartburnMin => 'Keins';

  @override
  String get wellnessHeartburnMax => 'Stark';

  @override
  String get insightsMetricGutPeace => 'Wohlbefinden';

  @override
  String get insightsMetricHeartburn => 'Sodbrennen';

  @override
  String get insightsMetricDiarrhea => 'Durchfall';

  @override
  String get insightsMetricCombined => 'Kombiniert';

  @override
  String get wellnessLinkMealsTitle => 'Mahlzeiten verknüpfen';

  @override
  String get wellnessLinkMealsHint =>
      'Wähle Mahlzeiten, die mit diesen Symptomen zusammenhängen könnten.';

  @override
  String get wellnessNotesLabel => 'Notizen (optional)';

  @override
  String get wellnessNotesHint => 'Weitere Beobachtungen…';

  @override
  String get wellnessSaveButton => 'Wohlbefinden speichern';

  @override
  String get wellnessScoreGreat => 'Fühle mich super!';

  @override
  String get wellnessScoreOkay => 'Geht so';

  @override
  String get wellnessSomeDiscomfort => 'Etwas unwohl';

  @override
  String get wellnessSignificantSymptoms => 'Deutliche Symptome';

  @override
  String get wellnessSevereDiscomfort => 'Starkes Unwohlsein';

  @override
  String get wellnessDiarrhea => 'Durchfall';

  @override
  String get wellnessSaved => 'Wohlbefinden gespeichert!';

  @override
  String get wellnessHistoryTitle => 'Wohlbefinden-Verlauf';

  @override
  String get wellnessHistoryEmpty => 'Noch keine Einträge';

  @override
  String get wellnessEditTitle => 'Eintrag bearbeiten';

  @override
  String get wellnessDeleteTitle => 'Eintrag löschen?';

  @override
  String get wellnessDeleteContent =>
      'Dieser Wohlbefindenseintrag wird entfernt.';

  @override
  String get linkedMealNoRecent => 'Keine aktuellen Mahlzeiten zum Verknüpfen';

  @override
  String get insightsTitle => 'Auswertung';

  @override
  String get insightsTabCalendar => 'Kalender';

  @override
  String get insightsTabHeatmap => 'Heatmap';

  @override
  String get insightsTabImpact => 'Auswirkung';

  @override
  String get insightsTabScatter => 'Streuung';

  @override
  String get insightsCalendarEmpty =>
      'Trage Wohlbefinden ein, um deinen Kalender zu sehen';

  @override
  String get insightsHeatmapEmpty =>
      'Trage mindestens 3 Mahlzeiten und Wohlbefindensdaten ein, um Lebensmittelkorrelationen zu sehen';

  @override
  String get insightsImpactEmpty =>
      'Trage mindestens 3 Mahlzeiten mit derselben Zutat und Wohlbefindensdaten ein, um Korrelationen zu sehen.';

  @override
  String get insightsScatterEmpty =>
      'Tippe auf ein Lebensmittel im Auswirkungs-Tab, um das Streudiagramm anzuzeigen.';

  @override
  String get insightsScatterPrompt =>
      'Tippe auf ein Lebensmittel, um das Streudiagramm anzuzeigen';

  @override
  String impactDataPoints(int count) {
    return '$count Datenpunkte — mehr Einträge verbessern die Genauigkeit';
  }

  @override
  String get timeFilterDay => 'Tag';

  @override
  String get timeFilterWeek => 'Woche';

  @override
  String get timeFilterMonth => 'Monat';

  @override
  String get timeFilterYear => 'Jahr';

  @override
  String get categoryAll => 'Alle';

  @override
  String get categoryVegetable => 'Gemüse';

  @override
  String get categoryFruit => 'Obst';

  @override
  String get categoryGrain => 'Getreide';

  @override
  String get categoryProtein => 'Protein';

  @override
  String get categoryDairy => 'Milchprodukte';

  @override
  String get categoryLegume => 'Hülsenfrüchte';

  @override
  String get categoryFat => 'Fett/Öl';

  @override
  String get categoryHerb => 'Kräuter';

  @override
  String get categorySpice => 'Gewürze';

  @override
  String get categoryBeverage => 'Getränke';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get timeJustNow => 'gerade eben';

  @override
  String timeMinutesAgo(int minutes) {
    return 'vor $minutes Min.';
  }

  @override
  String timeHoursAgo(int hours) {
    return 'vor $hours Std.';
  }

  @override
  String timeDaysAgo(int days) {
    return 'vor $days Tag(en)';
  }

  @override
  String get impactNotEnoughData => 'Noch nicht genug Daten';

  @override
  String get impactDrop => 'Verschlechterung';

  @override
  String get impactImprovement => 'Verbesserung';

  @override
  String get impactOneHour => '1 Stunde';

  @override
  String impactHours(int hours) {
    return '$hours Stunden';
  }

  @override
  String impactSummary(int percent, String direction, String lag) {
    return '$percent % Korrelation mit Wohlbefindens-$direction ~$lag nach dem Essen';
  }
}
