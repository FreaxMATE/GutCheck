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
  String get greetingMorning1 =>
      'Stomach 4.2 deployed. Rollback still possible.';

  @override
  String get greetingMorning2 => 'Breakfast MVP shipped.';

  @override
  String get greetingMorning3 => 'Standup with the small intestine at nine.';

  @override
  String get greetingMorning4 => 'Health check: 200 OK.';

  @override
  String get greetingMorning5 => 'systemctl restart stomach.service';

  @override
  String get greetingMorning6 => 'Race condition between coffee and croissant.';

  @override
  String get greetingMorning7 => 'Hotfix for last night deployed.';

  @override
  String get greetingMorning8 => 'Coffee deployed as mitigation.';

  @override
  String get greetingMorning9 =>
      'alias breakfast=\'make coffee && echo bread\'';

  @override
  String get greetingMorning10 => 'New pipeline. Please test with peppermint.';

  @override
  String get greetingAfternoon1 => 'We\'re disrupting lunch.';

  @override
  String get greetingAfternoon2 => 'Digestion: 87% uptime this week.';

  @override
  String get greetingAfternoon3 => 'Stakeholder alignment on the banana.';

  @override
  String get greetingAfternoon4 => 'Stomach is currently rate-limited.';

  @override
  String get greetingAfternoon5 => 'p99 latency at lunch elevated.';

  @override
  String get greetingAfternoon6 => 'PR open: a second coffee.';

  @override
  String get greetingAfternoon7 => 'Privilege escalation in the colon.';

  @override
  String get greetingAfternoon8 => 'Throughput in the gut: nominal.';

  @override
  String get greetingAfternoon9 =>
      'Soft lockup detected in the small intestine.';

  @override
  String get greetingAfternoon10 => 'Broccoli has been moved to the backlog.';

  @override
  String get greetingEvening1 =>
      'Incident in the small intestine — severity: 2.';

  @override
  String get greetingEvening2 =>
      'CVE-2025-1147 in the digestive tract. Patch pending.';

  @override
  String get greetingEvening3 => 'LGTM on the soup.';

  @override
  String get greetingEvening4 => 'Merge conflict between salad and fries.';

  @override
  String get greetingEvening5 => 'Retro: what went well in the stomach?';

  @override
  String get greetingEvening6 => 'Reviewer requested: pancreas.';

  @override
  String get greetingEvening7 => 'Mount point /digestion is read-only.';

  @override
  String get greetingEvening8 => 'Feature freeze on cream sauces.';

  @override
  String get greetingNight1 => 'Code freeze after 10pm.';

  @override
  String get greetingNight2 => 'Kernel panic after pizza.';

  @override
  String get greetingNight3 => 'Zero-day reported in the small intestine.';

  @override
  String get greetingNight4 => 'systemd-oomd killed the snack.';

  @override
  String get greetingNight5 => 'Critical vulnerability in libgut.so.';

  @override
  String get greetingNight6 =>
      'Memory leak in the stomach — size growing hourly.';

  @override
  String get greetingNight7 => '* * * * * /usr/bin/snack';

  @override
  String get supportiveMsg1 => 'Your gut has opinions. Very loud ones.';

  @override
  String get supportiveMsg2 => 'Every tap gets closer to the onion verdict ⚖️';

  @override
  String get supportiveMsg3 =>
      'Science is pattern-spotting in a lab coat. You do it in pajamas.';

  @override
  String get supportiveMsg4 =>
      '39 trillion bacteria watching. One app recording. 🦠';

  @override
  String get supportiveMsg5 =>
      'Sherlock had a magnifying glass. You have this.';

  @override
  String get supportiveMsg6 => 'Not all heroes wear capes. Some log breakfast.';

  @override
  String get supportiveMsg7 => 'Your torso speaks fluent gas. We translate.';

  @override
  String get supportiveMsg8 => 'Tiny data → huge \"oh THAT\'s why\" moments 💡';

  @override
  String get supportiveMsg9 =>
      'Today\'s log is tomorrow\'s courtroom evidence 👨‍⚖️';

  @override
  String get supportiveMsg10 =>
      'Your intestines forget nothing. Neither will we.';

  @override
  String get supportiveMsg11 =>
      'Consistency > intensity. Log the boring days too.';

  @override
  String get supportiveMsg12 =>
      'You, a scientist: currently measuring yourself 🔬';

  @override
  String get weeklyDigestTitle => 'Your week at a glance';

  @override
  String get weeklyDigestMeals => 'meals';

  @override
  String get weeklyDigestWellness => 'check-ins';

  @override
  String get weeklyDigestVariety => 'foods tried';

  @override
  String get shakeTip => '🦠 Tip: Tap the + button to log your meal!';

  @override
  String get timingTitle => 'Meal Timing';

  @override
  String get timingSubtitle => 'How the time you eat affects how you feel';

  @override
  String timingBestWindow(String label, String hours, String score) {
    return 'Best window: $label (${hours}h) — avg $score/10';
  }

  @override
  String timingWorstWindow(String label, String hours, String score) {
    return 'Worst window: $label (${hours}h) — avg $score/10';
  }

  @override
  String timingLateEatingBad(String penalty) {
    return 'Late eating adds +$penalty avg discomfort';
  }

  @override
  String get timingLateEatingOk => 'Late eating has little effect on you';

  @override
  String timingAvgGap(String hours) {
    return 'Avg gap between meals: ${hours}h';
  }

  @override
  String get heatmapLegendPoor => 'Poor';

  @override
  String get heatmapLegendGreat => 'Great';

  @override
  String get heatmapLegendCaption => '0–10 wellness score · higher is better';

  @override
  String get heatmapHarmful => 'Harmful';

  @override
  String get heatmapBeneficial => 'Beneficial';

  @override
  String get heatmapNoData => 'No data';

  @override
  String get heatmapFoodTimeLag => 'Food × Time Lag';

  @override
  String get heatmapFoodTimeLagDesc =>
      'Rank correlation between food consumption and wellness at each lag window';

  @override
  String get scatterWellnessScore => 'Wellness Score';

  @override
  String get scatterTimeOfDay => 'Time of Day';

  @override
  String get calendarDayNoData => 'No data today';

  @override
  String get calendarDayScore => 'wellness score';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String weeklyDigestAvgScore(String score) {
    return 'Average wellness: $score';
  }

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
  String get settingsResetDbTitle => 'Reset Database';

  @override
  String get settingsResetDbSubtitle =>
      'Completely remove the database file. Fixes schema errors. Irreversible.';

  @override
  String get settingsResetDbDialogTitle => 'Reset Database?';

  @override
  String get settingsResetDbDialogContent =>
      'This will permanently delete the entire database file (all meals, wellness entries, custom foods, and settings) and close the app. You must restart it manually.';

  @override
  String get settingsResetDbDone => 'Database deleted. Please restart the app.';

  @override
  String get settingsSectionPantry => 'Pantry';

  @override
  String get settingsPantryTitle => 'Smart Pantry';

  @override
  String get settingsPantrySubtitle =>
      'Browse ingredients and add custom foods';

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
  String get settingsPaletteTitle => 'Color Palette';

  @override
  String get settingsPaletteDialogTitle => 'Choose Color Palette';

  @override
  String get paletteVerdantGreen => 'Verdant Green';

  @override
  String get paletteTwilightIndigo => 'Twilight Indigo';

  @override
  String get paletteTerracottaClay => 'Terracotta Clay';

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
  String get settingsAnimationsTitle => 'Animations';

  @override
  String get settingsAnimationsSubtitle =>
      'Page transitions, entrance effects, and subtle motion';

  @override
  String get settingsSoundsTitle => 'Sounds';

  @override
  String get settingsSoundsSubtitle =>
      'Play a subtle gurgle when adding ingredients';

  @override
  String get settingsTrophiesTitle => 'Trophies';

  @override
  String get settingsTrophiesSubtitle => 'Your unlocked achievements';

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
  String get ok => 'OK';

  @override
  String get copy => 'Copy';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

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
  String get pantryDeleteTitle => 'Delete Food?';

  @override
  String get pantryDeleteContent =>
      'This custom food will be permanently removed.';

  @override
  String pantryDeleted(String name) {
    return '$name deleted';
  }

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
  String get addFoodNameDELabel => 'German Name';

  @override
  String get addFoodNameDEHint => 'e.g. Drachenfrucht';

  @override
  String get addFoodNameENLabel => 'English Name';

  @override
  String get addFoodNameENHint => 'e.g. Dragon Fruit';

  @override
  String get addFoodAutoTranslated => 'Auto-filled from dictionary';

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
  String get wellnessGutPeace => 'Gut Discomfort';

  @override
  String get wellnessGutPeaceMin => 'None';

  @override
  String get wellnessGutPeaceMax => 'Extreme';

  @override
  String get wellnessHeartburn => 'Heartburn';

  @override
  String get wellnessHeartburnMin => 'None';

  @override
  String get wellnessHeartburnMax => 'Severe';

  @override
  String get wellnessBloating => 'Bloating';

  @override
  String get wellnessBloatingMin => 'None';

  @override
  String get wellnessBloatingMax => 'Severe';

  @override
  String get bloatingLevelNone => 'None';

  @override
  String get bloatingLevelLight => 'Light';

  @override
  String get bloatingLevelStrong => 'Strong';

  @override
  String get wellnessGroupGut => 'How\'s your gut?';

  @override
  String get wellnessGroupContext => 'Context';

  @override
  String get insightsMetricGutPeace => 'Discomfort';

  @override
  String get insightsMetricHeartburn => 'Heartburn';

  @override
  String get insightsMetricBloating => 'Bloating';

  @override
  String get insightsMetricPrefix => 'Symptom';

  @override
  String get insightsMetricTooltip =>
      'Change which symptom the analysis ranks against';

  @override
  String get insightsFingerprintOverlayTitle => 'Best vs. worst foods';

  @override
  String get insightsFingerprintOverlaySubtitle =>
      'Your 3 most and 3 least harmful foods. Darker shade = more extreme. Tap a food below to see it on its own.';

  @override
  String get insightsFingerprintWorst => 'Most harmful';

  @override
  String get insightsFingerprintBest => 'Least harmful';

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
  String get wellnessStress => 'Stress Level';

  @override
  String get wellnessStressMin => 'Zen';

  @override
  String get wellnessStressMax => 'Maxed out';

  @override
  String get insightsMetricStress => 'Stress';

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
  String get insightsTabFingerprint => 'Radar';

  @override
  String get insightsFingerprintEmpty =>
      'Log at least 3 meals with the same ingredient and some wellness entries to see food radars.';

  @override
  String get insightsScatterEmpty =>
      'Log more meals and wellness entries to see scatter plots.';

  @override
  String get insightsScatterPrompt => 'Tap a food to view its scatter plot';

  @override
  String insightsScatterShowMore(int count) {
    return 'Show $count more foods';
  }

  @override
  String get insightsScatterShowLess => 'Show less';

  @override
  String insightsScatterShowingAll(int count) {
    return 'Showing all $count foods';
  }

  @override
  String get insightsScatterSignificant => 'Confirmed';

  @override
  String get insightsCalendarDensityTitle => 'Card shows';

  @override
  String get insightsHowItWorksTitle => 'How the analysis works';

  @override
  String get insightsHowItWorksLead =>
      'A plain-language explanation of the scores and correlations GutCheck shows you.';

  @override
  String get insightsHelpCombinedTitle => 'The Combined score';

  @override
  String get insightsHelpCombinedBody =>
      'A single 0–100 number that summarizes how your body feels, weighted across four signals from your wellness check-in:\n\n  • 45% Gut discomfort\n  • 20% Bloating (None / Light / Strong)\n  • 20% Heartburn\n  • 15% Diarrhea (counts as 0 or 100)\n\nHigher = better. Stress is NOT part of the Combined score — it\'s treated as an input (see below).';

  @override
  String get insightsHelpCorrelationTitle => 'Food correlations';

  @override
  String get insightsHelpCorrelationBody =>
      'For every ingredient you log, GutCheck asks: \"on days you ate this, did your symptoms line up with it?\". For each food we try three time windows — 0–4h (immediate), 4–12h (delayed), 12–24h (overnight) — and keep the window with the strongest link.\n\nWe use Spearman rank correlation (robust to outliers, catches non-linear patterns) and compute a p-value. Because we run many tests at once, we then apply a Benjamini–Hochberg false-discovery correction: foods marked \"Confirmed\" have passed that statistical bar. Un-badged foods are interesting trends, not yet proven.';

  @override
  String get insightsHelpStressTitle => 'Stress is an input';

  @override
  String get insightsHelpStressBody =>
      'Stress isn\'t a symptom you\'re trying to minimize — it\'s a predictor, like food. The \"Stress impact\" card at the top of the Impact list shows whether your stress slider correlates with your chosen symptom. A red, down-trending card means higher stress lines up with worse symptoms on your history.';

  @override
  String get insightsHelpCaveat =>
      'Correlation is not causation. Stress and diet often co-vary — a strong food-to-symptom link may partly reflect stressful days. Use these numbers as hypotheses, not verdicts.';

  @override
  String get insightsStressCardTitle => 'Stress impact';

  @override
  String insightsStressCardHarmful(int pct) {
    return 'Higher stress lines up with worse symptoms ($pct%)';
  }

  @override
  String insightsStressCardBeneficial(int pct) {
    return 'Higher stress lines up with better wellness ($pct%)';
  }

  @override
  String get insightsCardCalendarSubtitle => 'Your daily wellness at a glance';

  @override
  String get insightsCardImpactSubtitle => 'Which foods affect how you feel';

  @override
  String get insightsCardHeatmapSubtitle => 'Food × time-lag correlations';

  @override
  String get insightsCardFingerprintSubtitle => 'Per-food symptom radar';

  @override
  String get insightsCardScatterSubtitle => 'Drill into any food\'s timing';

  @override
  String get insightsTabTrend => 'Trend';

  @override
  String get insightsCardTrendSubtitle => 'Wellness over time, smoothed';

  @override
  String get insightsTrendEmpty =>
      'Log wellness entries to see your trend over time';

  @override
  String get insightsTrendRawSeries => 'Daily score';

  @override
  String get insightsTrendEntries => 'Each entry';

  @override
  String get insightsTrend7dAvg => '7-day average';

  @override
  String get insightsTrendZoomHint =>
      'Pinch or scroll to zoom · double-tap to reset';

  @override
  String get insightsCardNoData => 'Not enough data yet';

  @override
  String insightsCardHeatmapStat(int count) {
    return '$count foods analyzed';
  }

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

  @override
  String get mealTemplatesTitle => 'Meal Templates';

  @override
  String get mealTemplatesEmpty =>
      'Save your favorite meals as templates for quick logging';

  @override
  String get mealTemplateNew => 'New Template';

  @override
  String get mealTemplateSaveAs => 'Save as Template';

  @override
  String get mealTemplateNameHint => 'Template name';

  @override
  String get mealTemplateNameRequired => 'Give your template a name';

  @override
  String get mealTemplateSaved => 'Template saved!';

  @override
  String get mealTemplateDeleted => 'Template deleted';

  @override
  String get mealTemplateDeleteTitle => 'Delete Template?';

  @override
  String get mealTemplateDeleteContent =>
      'This template will be permanently removed.';

  @override
  String get mealTemplateEditTitle => 'Edit Template';

  @override
  String get mealTemplateCreateTitle => 'New Template';

  @override
  String mealTemplateIngredientCount(int count) {
    return '$count ingredients';
  }
}
