// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navPantry => 'Pantry';

  @override
  String get navMealLog => 'Meal Log';

  @override
  String get navWellness => 'Wellness';

  @override
  String get navInsights => 'Insights';

  @override
  String get homeLastWellnessTitle => 'Last Wellness Check';

  @override
  String get homeLastMealTitle => 'Last Meal';

  @override
  String get homeWeeklyAvgTitle => '7-Day Average';

  @override
  String get homeTopInsightTitle => 'Top Insight';

  @override
  String get homeNoWellnessYet => 'No wellness entries yet';

  @override
  String get homeNoMealsYet => 'No meals logged yet';

  @override
  String get homeNoInsightYet =>
      'Log more meals & wellness entries to see food insights.';

  @override
  String get homeViewHistory => 'View history';

  @override
  String get homeViewLog => 'View log';

  @override
  String get homeViewInsights => 'View insights';

  @override
  String get homeLogWellness => 'Log Wellness';

  @override
  String get homeLogMeal => 'Log Meal';

  @override
  String get homePossibleTrigger => 'Possible trigger';

  @override
  String get homeLikelyBeneficial => 'Likely beneficial';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionData => 'Data';

  @override
  String get settingsExportTitle => 'Export All Data';

  @override
  String get settingsExportSubtitle =>
      'Share a JSON backup of all your records';

  @override
  String get settingsExportSuccess => 'Export ready!';

  @override
  String settingsExportError(Object error) {
    return 'Export failed: $error';
  }

  @override
  String get settingsImportTitle => 'Import Data';

  @override
  String get settingsImportSubtitle => 'Restore a previous JSON backup';

  @override
  String get settingsImportModeTitle => 'How should we import this backup?';

  @override
  String get settingsImportModeContent =>
      'Replace All will clear your current data and restore the backup completely. Merge will keep your existing data and add new entries from the backup.';

  @override
  String get settingsImportModeMerge => 'Merge';

  @override
  String get settingsImportModeReplace => 'Replace All';

  @override
  String get settingsImportPickDialogTitle => 'Select JSON backup to import';

  @override
  String get settingsImportCancelled => 'Import cancelled';

  @override
  String settingsImportError(Object error) {
    return 'Import failed: $error';
  }

  @override
  String get settingsExportPantryTitle => 'Export Pantry';

  @override
  String get settingsExportPantrySubtitle =>
      'Share a backup of your custom foods';

  @override
  String get settingsImportPantryTitle => 'Import Pantry';

  @override
  String get settingsImportPantrySubtitle =>
      'Add custom foods from a backup file';

  @override
  String get settingsClearTitle => 'Clear All Data';

  @override
  String get settingsClearSubtitle =>
      'Permanently delete all meals and wellness entries';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeDialogTitle => 'Choose Theme';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsLanguageAuto => 'System default';

  @override
  String get settingsLanguageDialogTitle => 'Choose Language';

  @override
  String get settingsSampleDataTitle => 'Sample Data';

  @override
  String get settingsSampleDataSubtitle =>
      'Load demo meals & wellness logs to explore the analysis features';

  @override
  String get settingsSampleDataAdded => 'Sample data loaded!';

  @override
  String get settingsSampleDataRemoved => 'Sample data removed.';

  @override
  String get fodmapLow => 'Low FODMAP';

  @override
  String get fodmapModerate => 'Moderate FODMAP';

  @override
  String get fodmapHigh => 'High FODMAP';

  @override
  String get logMealBrowseByCategory => 'Browse by category';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsAppVersion => 'v1.0.0 — Local-first, open source';

  @override
  String get settingsPrivacyTitle => 'Privacy';

  @override
  String get settingsPrivacySubtitle =>
      'All data is stored on this device only. Nothing is sent to any server.';

  @override
  String get settingsClearDialogTitle => 'Clear All Data?';

  @override
  String get settingsClearDialogContent =>
      'This will permanently delete all meal logs, wellness entries, and custom foods. This cannot be undone.';

  @override
  String get settingsClearSuccess => 'All data deleted.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get save => 'Save';

  @override
  String databaseError(Object error) {
    return 'Database error: $error';
  }

  @override
  String genericError(Object error) {
    return 'Error: $error';
  }

  @override
  String get pantryTitle => 'Smart Pantry';

  @override
  String get pantrySearchHint => 'Search ingredients…';

  @override
  String pantryNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get pantryEmpty => 'No ingredients found';

  @override
  String get pantryAddFood => 'Add Food';

  @override
  String get pantryFodmapLevel => 'FODMAP Level';

  @override
  String get pantryAlsoClassifiedAs => 'Also classified as';

  @override
  String get pantryNotes => 'Notes';

  @override
  String get pantryCustomFood => 'Custom food';

  @override
  String get pantryMyFoods => 'My Foods';

  @override
  String get addFoodTitle => 'Add Custom Food';

  @override
  String get addFoodNameLabel => 'Food Name';

  @override
  String get addFoodNameHint => 'e.g. Dragon Fruit';

  @override
  String get addFoodNameRequired => 'Name is required';

  @override
  String get addFoodCategoryLabel => 'Category';

  @override
  String get addFoodFodmapLabel => 'FODMAP Level';

  @override
  String get addFoodFodmapLow => 'Low FODMAP';

  @override
  String get addFoodFodmapModerate => 'Moderate FODMAP';

  @override
  String get addFoodFodmapHigh => 'High FODMAP';

  @override
  String get addFoodNotesHint => 'Any personal observations…';

  @override
  String get addFoodSave => 'Save Food';

  @override
  String addFoodAdded(String name) {
    return '$name added!';
  }

  @override
  String get mealEditTitle => 'Edit Meal';

  @override
  String get mealLogTitle => 'Meal Log';

  @override
  String get mealLogEmpty => 'Nothing logged today';

  @override
  String get mealLogEmptyHint => 'Tap + to log your first meal';

  @override
  String get mealLogButton => 'Log Meal';

  @override
  String get mealDeleteTitle => 'Delete Meal?';

  @override
  String get mealDeleteContent => 'This meal entry will be removed.';

  @override
  String get mealFallbackLabel => 'Meal';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnack => 'Snack';

  @override
  String get logMealTitle => 'Log Meal';

  @override
  String get logMealTapToChangeTime => 'Tap to change time';

  @override
  String get logMealSearchHint => 'Search ingredients to add…';

  @override
  String logMealQuantityHint(String name) {
    return 'Quantity for $name (optional)';
  }

  @override
  String get logMealAdd => 'Add';

  @override
  String get logMealAdded => 'Added';

  @override
  String get logMealNotesHint => 'Notes (optional)…';

  @override
  String get logMealValidation => 'Add at least one ingredient to log a meal.';

  @override
  String get wellnessTitle => 'Wellness Check';

  @override
  String get wellnessGutPeace => 'Gut Peace';

  @override
  String get wellnessGutPeaceMin => 'Uncomfortable';

  @override
  String get wellnessGutPeaceMax => 'Perfect';

  @override
  String get wellnessHeartburn => 'Heartburn';

  @override
  String get wellnessHeartburnMin => 'None';

  @override
  String get wellnessHeartburnMax => 'Severe';

  @override
  String get insightsMetricGutPeace => 'Comfort';

  @override
  String get insightsMetricHeartburn => 'Heartburn';

  @override
  String get insightsMetricDiarrhea => 'Diarrhea';

  @override
  String get insightsMetricCombined => 'Combined';

  @override
  String get wellnessLinkMealsTitle => 'Link to Recent Meals';

  @override
  String get wellnessLinkMealsHint =>
      'Select meals that may be related to these symptoms.';

  @override
  String get wellnessNotesLabel => 'Notes (optional)';

  @override
  String get wellnessNotesHint => 'Any additional observations…';

  @override
  String get wellnessSaveButton => 'Save Wellness Entry';

  @override
  String get wellnessScoreGreat => 'Feeling great!';

  @override
  String get wellnessScoreOkay => 'Doing okay';

  @override
  String get wellnessSomeDiscomfort => 'Some discomfort';

  @override
  String get wellnessSignificantSymptoms => 'Significant symptoms';

  @override
  String get wellnessSevereDiscomfort => 'Severe discomfort';

  @override
  String get wellnessDiarrhea => 'Diarrhea';

  @override
  String get wellnessSaved => 'Wellness entry saved!';

  @override
  String get wellnessHistoryTitle => 'Wellness History';

  @override
  String get wellnessHistoryEmpty => 'No wellness entries yet';

  @override
  String get wellnessEditTitle => 'Edit Wellness Entry';

  @override
  String get wellnessDeleteTitle => 'Delete Entry?';

  @override
  String get wellnessDeleteContent => 'This wellness entry will be removed.';

  @override
  String get linkedMealNoRecent => 'No recent meals to link';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsTabCalendar => 'Calendar';

  @override
  String get insightsTabHeatmap => 'Heatmap';

  @override
  String get insightsTabImpact => 'Impact';

  @override
  String get insightsTabScatter => 'Scatter';

  @override
  String get insightsCalendarEmpty =>
      'Log wellness entries to see your calendar';

  @override
  String get insightsHeatmapEmpty =>
      'Log at least 3 meals and wellness entries to see food correlations';

  @override
  String get insightsImpactEmpty =>
      'Log at least 3 meals with the same ingredient and some wellness entries to see correlations.';

  @override
  String get insightsScatterEmpty =>
      'Tap a food in the Impact tab to view its scatter plot.';

  @override
  String get insightsScatterPrompt => 'Tap a food to view its scatter plot';

  @override
  String impactDataPoints(int count) {
    return '$count data points — more logging will improve accuracy';
  }

  @override
  String get timeFilterDay => 'Day';

  @override
  String get timeFilterWeek => 'Week';

  @override
  String get timeFilterMonth => 'Month';

  @override
  String get timeFilterYear => 'Year';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryVegetable => 'Vegetable';

  @override
  String get categoryFruit => 'Fruit';

  @override
  String get categoryGrain => 'Grain';

  @override
  String get categoryProtein => 'Protein';

  @override
  String get categoryDairy => 'Dairy';

  @override
  String get categoryLegume => 'Legume';

  @override
  String get categoryFat => 'Fat/Oil';

  @override
  String get categoryHerb => 'Herb';

  @override
  String get categorySpice => 'Spice';

  @override
  String get categoryBeverage => 'Beverage';

  @override
  String get categoryOther => 'Other';

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String timeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String timeDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get impactNotEnoughData => 'Not enough data yet';

  @override
  String get impactDrop => 'drop';

  @override
  String get impactImprovement => 'improvement';

  @override
  String get impactOneHour => '1 hour';

  @override
  String impactHours(int hours) {
    return '$hours hours';
  }

  @override
  String impactSummary(int percent, String direction, String lag) {
    return '$percent% correlation with wellness $direction ~$lag after eating';
  }
}
