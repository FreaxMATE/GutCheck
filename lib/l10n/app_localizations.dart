import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get navPantry;

  /// No description provided for @navMealLog.
  ///
  /// In en, this message translates to:
  /// **'Meal Log'**
  String get navMealLog;

  /// No description provided for @navWellness.
  ///
  /// In en, this message translates to:
  /// **'Wellness'**
  String get navWellness;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @homeLastWellnessTitle.
  ///
  /// In en, this message translates to:
  /// **'Last Wellness Check'**
  String get homeLastWellnessTitle;

  /// No description provided for @homeLastMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Last Meal'**
  String get homeLastMealTitle;

  /// No description provided for @homeWeeklyAvgTitle.
  ///
  /// In en, this message translates to:
  /// **'7-Day Average'**
  String get homeWeeklyAvgTitle;

  /// No description provided for @homeTopInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Insight'**
  String get homeTopInsightTitle;

  /// No description provided for @homeNoWellnessYet.
  ///
  /// In en, this message translates to:
  /// **'No wellness entries yet'**
  String get homeNoWellnessYet;

  /// No description provided for @homeNoMealsYet.
  ///
  /// In en, this message translates to:
  /// **'No meals logged yet'**
  String get homeNoMealsYet;

  /// No description provided for @homeNoInsightYet.
  ///
  /// In en, this message translates to:
  /// **'Log more meals & wellness entries to see food insights.'**
  String get homeNoInsightYet;

  /// No description provided for @homeViewHistory.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get homeViewHistory;

  /// No description provided for @homeViewLog.
  ///
  /// In en, this message translates to:
  /// **'View log'**
  String get homeViewLog;

  /// No description provided for @homeViewInsights.
  ///
  /// In en, this message translates to:
  /// **'View insights'**
  String get homeViewInsights;

  /// No description provided for @homeLogWellness.
  ///
  /// In en, this message translates to:
  /// **'Log Wellness'**
  String get homeLogWellness;

  /// No description provided for @homeLogMeal.
  ///
  /// In en, this message translates to:
  /// **'Log Meal'**
  String get homeLogMeal;

  /// No description provided for @homePossibleTrigger.
  ///
  /// In en, this message translates to:
  /// **'Possible trigger'**
  String get homePossibleTrigger;

  /// No description provided for @homeLikelyBeneficial.
  ///
  /// In en, this message translates to:
  /// **'Likely beneficial'**
  String get homeLikelyBeneficial;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsSectionData;

  /// No description provided for @settingsExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export All Data'**
  String get settingsExportTitle;

  /// No description provided for @settingsExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share a JSON backup of all your records'**
  String get settingsExportSubtitle;

  /// No description provided for @settingsExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export ready!'**
  String get settingsExportSuccess;

  /// No description provided for @settingsExportError.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String settingsExportError(Object error);

  /// No description provided for @settingsImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get settingsImportTitle;

  /// No description provided for @settingsImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore a previous JSON backup'**
  String get settingsImportSubtitle;

  /// No description provided for @settingsImportModeTitle.
  ///
  /// In en, this message translates to:
  /// **'How should we import this backup?'**
  String get settingsImportModeTitle;

  /// No description provided for @settingsImportModeContent.
  ///
  /// In en, this message translates to:
  /// **'Replace All will clear your current data and restore the backup completely. Merge will keep your existing data and add new entries from the backup.'**
  String get settingsImportModeContent;

  /// No description provided for @settingsImportModeMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get settingsImportModeMerge;

  /// No description provided for @settingsImportModeReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace All'**
  String get settingsImportModeReplace;

  /// No description provided for @settingsImportPickDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select JSON backup to import'**
  String get settingsImportPickDialogTitle;

  /// No description provided for @settingsImportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Import cancelled'**
  String get settingsImportCancelled;

  /// No description provided for @settingsImportError.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String settingsImportError(Object error);

  /// No description provided for @settingsExportPantryTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Pantry'**
  String get settingsExportPantryTitle;

  /// No description provided for @settingsExportPantrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share a backup of your custom foods'**
  String get settingsExportPantrySubtitle;

  /// No description provided for @settingsImportPantryTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Pantry'**
  String get settingsImportPantryTitle;

  /// No description provided for @settingsImportPantrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add custom foods from a backup file'**
  String get settingsImportPantrySubtitle;

  /// No description provided for @settingsClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get settingsClearTitle;

  /// No description provided for @settingsClearSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all meals and wellness entries'**
  String get settingsClearSubtitle;

  /// No description provided for @settingsResetDbTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Database'**
  String get settingsResetDbTitle;

  /// No description provided for @settingsResetDbSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Completely remove the database file. Fixes schema errors. Irreversible.'**
  String get settingsResetDbSubtitle;

  /// No description provided for @settingsResetDbDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Database?'**
  String get settingsResetDbDialogTitle;

  /// No description provided for @settingsResetDbDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the entire database file (all meals, wellness entries, custom foods, and settings) and close the app. You must restart it manually.'**
  String get settingsResetDbDialogContent;

  /// No description provided for @settingsResetDbDone.
  ///
  /// In en, this message translates to:
  /// **'Database deleted. Please restart the app.'**
  String get settingsResetDbDone;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeTitle;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get settingsThemeDialogTitle;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsLanguageAuto.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageAuto;

  /// No description provided for @settingsLanguageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get settingsLanguageDialogTitle;

  /// No description provided for @settingsSampleDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Sample Data'**
  String get settingsSampleDataTitle;

  /// No description provided for @settingsSampleDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Load demo meals & wellness logs to explore the analysis features'**
  String get settingsSampleDataSubtitle;

  /// No description provided for @settingsSampleDataAdded.
  ///
  /// In en, this message translates to:
  /// **'Sample data loaded!'**
  String get settingsSampleDataAdded;

  /// No description provided for @settingsSampleDataRemoved.
  ///
  /// In en, this message translates to:
  /// **'Sample data removed.'**
  String get settingsSampleDataRemoved;

  /// No description provided for @settingsAnimationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get settingsAnimationsTitle;

  /// No description provided for @settingsAnimationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Page transitions, entrance effects, and subtle motion'**
  String get settingsAnimationsSubtitle;

  /// No description provided for @fodmapLow.
  ///
  /// In en, this message translates to:
  /// **'Low FODMAP'**
  String get fodmapLow;

  /// No description provided for @fodmapModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate FODMAP'**
  String get fodmapModerate;

  /// No description provided for @fodmapHigh.
  ///
  /// In en, this message translates to:
  /// **'High FODMAP'**
  String get fodmapHigh;

  /// No description provided for @logMealBrowseByCategory.
  ///
  /// In en, this message translates to:
  /// **'Browse by category'**
  String get logMealBrowseByCategory;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'v1.0.0 — Local-first, open source'**
  String get settingsAppVersion;

  /// No description provided for @settingsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacyTitle;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'All data is stored on this device only. Nothing is sent to any server.'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsClearDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data?'**
  String get settingsClearDialogTitle;

  /// No description provided for @settingsClearDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all meal logs, wellness entries, and custom foods. This cannot be undone.'**
  String get settingsClearDialogContent;

  /// No description provided for @settingsClearSuccess.
  ///
  /// In en, this message translates to:
  /// **'All data deleted.'**
  String get settingsClearSuccess;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @databaseError.
  ///
  /// In en, this message translates to:
  /// **'Database error: {error}'**
  String databaseError(Object error);

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String genericError(Object error);

  /// No description provided for @pantryTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Pantry'**
  String get pantryTitle;

  /// No description provided for @pantrySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search ingredients…'**
  String get pantrySearchHint;

  /// No description provided for @pantryNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String pantryNoResults(String query);

  /// No description provided for @pantryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No ingredients found'**
  String get pantryEmpty;

  /// No description provided for @pantryAddFood.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get pantryAddFood;

  /// No description provided for @pantryFodmapLevel.
  ///
  /// In en, this message translates to:
  /// **'FODMAP Level'**
  String get pantryFodmapLevel;

  /// No description provided for @pantryAlsoClassifiedAs.
  ///
  /// In en, this message translates to:
  /// **'Also classified as'**
  String get pantryAlsoClassifiedAs;

  /// No description provided for @pantryNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get pantryNotes;

  /// No description provided for @pantryCustomFood.
  ///
  /// In en, this message translates to:
  /// **'Custom food'**
  String get pantryCustomFood;

  /// No description provided for @pantryMyFoods.
  ///
  /// In en, this message translates to:
  /// **'My Foods'**
  String get pantryMyFoods;

  /// No description provided for @pantryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Food?'**
  String get pantryDeleteTitle;

  /// No description provided for @pantryDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'This custom food will be permanently removed.'**
  String get pantryDeleteContent;

  /// No description provided for @pantryDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String pantryDeleted(String name);

  /// No description provided for @addFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Food'**
  String get addFoodTitle;

  /// No description provided for @addFoodNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get addFoodNameLabel;

  /// No description provided for @addFoodNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dragon Fruit'**
  String get addFoodNameHint;

  /// No description provided for @addFoodNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get addFoodNameRequired;

  /// No description provided for @addFoodCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addFoodCategoryLabel;

  /// No description provided for @addFoodFodmapLabel.
  ///
  /// In en, this message translates to:
  /// **'FODMAP Level'**
  String get addFoodFodmapLabel;

  /// No description provided for @addFoodFodmapLow.
  ///
  /// In en, this message translates to:
  /// **'Low FODMAP'**
  String get addFoodFodmapLow;

  /// No description provided for @addFoodFodmapModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate FODMAP'**
  String get addFoodFodmapModerate;

  /// No description provided for @addFoodFodmapHigh.
  ///
  /// In en, this message translates to:
  /// **'High FODMAP'**
  String get addFoodFodmapHigh;

  /// No description provided for @addFoodNameDELabel.
  ///
  /// In en, this message translates to:
  /// **'German Name'**
  String get addFoodNameDELabel;

  /// No description provided for @addFoodNameDEHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Drachenfrucht'**
  String get addFoodNameDEHint;

  /// No description provided for @addFoodNameENLabel.
  ///
  /// In en, this message translates to:
  /// **'English Name'**
  String get addFoodNameENLabel;

  /// No description provided for @addFoodNameENHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dragon Fruit'**
  String get addFoodNameENHint;

  /// No description provided for @addFoodAutoTranslated.
  ///
  /// In en, this message translates to:
  /// **'Auto-filled from dictionary'**
  String get addFoodAutoTranslated;

  /// No description provided for @addFoodNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Any personal observations…'**
  String get addFoodNotesHint;

  /// No description provided for @addFoodSave.
  ///
  /// In en, this message translates to:
  /// **'Save Food'**
  String get addFoodSave;

  /// No description provided for @addFoodAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added!'**
  String addFoodAdded(String name);

  /// No description provided for @mealEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Meal'**
  String get mealEditTitle;

  /// No description provided for @mealLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal Log'**
  String get mealLogTitle;

  /// No description provided for @mealLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged today'**
  String get mealLogEmpty;

  /// No description provided for @mealLogEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to log your first meal'**
  String get mealLogEmptyHint;

  /// No description provided for @mealLogButton.
  ///
  /// In en, this message translates to:
  /// **'Log Meal'**
  String get mealLogButton;

  /// No description provided for @mealDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Meal?'**
  String get mealDeleteTitle;

  /// No description provided for @mealDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'This meal entry will be removed.'**
  String get mealDeleteContent;

  /// No description provided for @mealFallbackLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get mealFallbackLabel;

  /// No description provided for @mealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealDinner;

  /// No description provided for @mealSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealSnack;

  /// No description provided for @logMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Meal'**
  String get logMealTitle;

  /// No description provided for @logMealTapToChangeTime.
  ///
  /// In en, this message translates to:
  /// **'Tap to change time'**
  String get logMealTapToChangeTime;

  /// No description provided for @logMealSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search ingredients to add…'**
  String get logMealSearchHint;

  /// No description provided for @logMealQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'Quantity for {name} (optional)'**
  String logMealQuantityHint(String name);

  /// No description provided for @logMealAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get logMealAdd;

  /// No description provided for @logMealAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get logMealAdded;

  /// No description provided for @logMealNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)…'**
  String get logMealNotesHint;

  /// No description provided for @logMealValidation.
  ///
  /// In en, this message translates to:
  /// **'Add at least one ingredient to log a meal.'**
  String get logMealValidation;

  /// No description provided for @wellnessTitle.
  ///
  /// In en, this message translates to:
  /// **'Wellness Check'**
  String get wellnessTitle;

  /// No description provided for @wellnessGutPeace.
  ///
  /// In en, this message translates to:
  /// **'Gut Peace'**
  String get wellnessGutPeace;

  /// No description provided for @wellnessGutPeaceMin.
  ///
  /// In en, this message translates to:
  /// **'Uncomfortable'**
  String get wellnessGutPeaceMin;

  /// No description provided for @wellnessGutPeaceMax.
  ///
  /// In en, this message translates to:
  /// **'Perfect'**
  String get wellnessGutPeaceMax;

  /// No description provided for @wellnessHeartburn.
  ///
  /// In en, this message translates to:
  /// **'Heartburn'**
  String get wellnessHeartburn;

  /// No description provided for @wellnessHeartburnMin.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get wellnessHeartburnMin;

  /// No description provided for @wellnessHeartburnMax.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get wellnessHeartburnMax;

  /// No description provided for @insightsMetricGutPeace.
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get insightsMetricGutPeace;

  /// No description provided for @insightsMetricHeartburn.
  ///
  /// In en, this message translates to:
  /// **'Heartburn'**
  String get insightsMetricHeartburn;

  /// No description provided for @insightsMetricDiarrhea.
  ///
  /// In en, this message translates to:
  /// **'Diarrhea'**
  String get insightsMetricDiarrhea;

  /// No description provided for @insightsMetricCombined.
  ///
  /// In en, this message translates to:
  /// **'Combined'**
  String get insightsMetricCombined;

  /// No description provided for @wellnessLinkMealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Link to Recent Meals'**
  String get wellnessLinkMealsTitle;

  /// No description provided for @wellnessLinkMealsHint.
  ///
  /// In en, this message translates to:
  /// **'Select meals that may be related to these symptoms.'**
  String get wellnessLinkMealsHint;

  /// No description provided for @wellnessNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get wellnessNotesLabel;

  /// No description provided for @wellnessNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Any additional observations…'**
  String get wellnessNotesHint;

  /// No description provided for @wellnessSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Wellness Entry'**
  String get wellnessSaveButton;

  /// No description provided for @wellnessScoreGreat.
  ///
  /// In en, this message translates to:
  /// **'Feeling great!'**
  String get wellnessScoreGreat;

  /// No description provided for @wellnessScoreOkay.
  ///
  /// In en, this message translates to:
  /// **'Doing okay'**
  String get wellnessScoreOkay;

  /// No description provided for @wellnessSomeDiscomfort.
  ///
  /// In en, this message translates to:
  /// **'Some discomfort'**
  String get wellnessSomeDiscomfort;

  /// No description provided for @wellnessSignificantSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Significant symptoms'**
  String get wellnessSignificantSymptoms;

  /// No description provided for @wellnessSevereDiscomfort.
  ///
  /// In en, this message translates to:
  /// **'Severe discomfort'**
  String get wellnessSevereDiscomfort;

  /// No description provided for @wellnessDiarrhea.
  ///
  /// In en, this message translates to:
  /// **'Diarrhea'**
  String get wellnessDiarrhea;

  /// No description provided for @wellnessSaved.
  ///
  /// In en, this message translates to:
  /// **'Wellness entry saved!'**
  String get wellnessSaved;

  /// No description provided for @wellnessHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Wellness History'**
  String get wellnessHistoryTitle;

  /// No description provided for @wellnessHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No wellness entries yet'**
  String get wellnessHistoryEmpty;

  /// No description provided for @wellnessEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Wellness Entry'**
  String get wellnessEditTitle;

  /// No description provided for @wellnessDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry?'**
  String get wellnessDeleteTitle;

  /// No description provided for @wellnessDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'This wellness entry will be removed.'**
  String get wellnessDeleteContent;

  /// No description provided for @linkedMealNoRecent.
  ///
  /// In en, this message translates to:
  /// **'No recent meals to link'**
  String get linkedMealNoRecent;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @insightsTabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get insightsTabCalendar;

  /// No description provided for @insightsTabHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Heatmap'**
  String get insightsTabHeatmap;

  /// No description provided for @insightsTabImpact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get insightsTabImpact;

  /// No description provided for @insightsTabScatter.
  ///
  /// In en, this message translates to:
  /// **'Scatter'**
  String get insightsTabScatter;

  /// No description provided for @insightsCalendarEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log wellness entries to see your calendar'**
  String get insightsCalendarEmpty;

  /// No description provided for @insightsHeatmapEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log at least 3 meals and wellness entries to see food correlations'**
  String get insightsHeatmapEmpty;

  /// No description provided for @insightsImpactEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log at least 3 meals with the same ingredient and some wellness entries to see correlations.'**
  String get insightsImpactEmpty;

  /// No description provided for @insightsScatterEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tap a food in the Impact tab to view its scatter plot.'**
  String get insightsScatterEmpty;

  /// No description provided for @insightsScatterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap a food to view its scatter plot'**
  String get insightsScatterPrompt;

  /// No description provided for @impactDataPoints.
  ///
  /// In en, this message translates to:
  /// **'{count} data points — more logging will improve accuracy'**
  String impactDataPoints(int count);

  /// No description provided for @timeFilterDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get timeFilterDay;

  /// No description provided for @timeFilterWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get timeFilterWeek;

  /// No description provided for @timeFilterMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get timeFilterMonth;

  /// No description provided for @timeFilterYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get timeFilterYear;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryVegetable.
  ///
  /// In en, this message translates to:
  /// **'Vegetable'**
  String get categoryVegetable;

  /// No description provided for @categoryFruit.
  ///
  /// In en, this message translates to:
  /// **'Fruit'**
  String get categoryFruit;

  /// No description provided for @categoryGrain.
  ///
  /// In en, this message translates to:
  /// **'Grain'**
  String get categoryGrain;

  /// No description provided for @categoryProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get categoryProtein;

  /// No description provided for @categoryDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get categoryDairy;

  /// No description provided for @categoryLegume.
  ///
  /// In en, this message translates to:
  /// **'Legume'**
  String get categoryLegume;

  /// No description provided for @categoryFat.
  ///
  /// In en, this message translates to:
  /// **'Fat/Oil'**
  String get categoryFat;

  /// No description provided for @categoryHerb.
  ///
  /// In en, this message translates to:
  /// **'Herb'**
  String get categoryHerb;

  /// No description provided for @categorySpice.
  ///
  /// In en, this message translates to:
  /// **'Spice'**
  String get categorySpice;

  /// No description provided for @categoryBeverage.
  ///
  /// In en, this message translates to:
  /// **'Beverage'**
  String get categoryBeverage;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String timeMinutesAgo(int minutes);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String timeHoursAgo(int hours);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String timeDaysAgo(int days);

  /// No description provided for @impactNotEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get impactNotEnoughData;

  /// No description provided for @impactDrop.
  ///
  /// In en, this message translates to:
  /// **'drop'**
  String get impactDrop;

  /// No description provided for @impactImprovement.
  ///
  /// In en, this message translates to:
  /// **'improvement'**
  String get impactImprovement;

  /// No description provided for @impactOneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get impactOneHour;

  /// No description provided for @impactHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String impactHours(int hours);

  /// No description provided for @impactSummary.
  ///
  /// In en, this message translates to:
  /// **'{percent}% correlation with wellness {direction} ~{lag} after eating'**
  String impactSummary(int percent, String direction, String lag);

  /// No description provided for @mealTemplatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal Templates'**
  String get mealTemplatesTitle;

  /// No description provided for @mealTemplatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite meals as templates for quick logging'**
  String get mealTemplatesEmpty;

  /// No description provided for @mealTemplateNew.
  ///
  /// In en, this message translates to:
  /// **'New Template'**
  String get mealTemplateNew;

  /// No description provided for @mealTemplateSaveAs.
  ///
  /// In en, this message translates to:
  /// **'Save as Template'**
  String get mealTemplateSaveAs;

  /// No description provided for @mealTemplateNameHint.
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get mealTemplateNameHint;

  /// No description provided for @mealTemplateNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give your template a name'**
  String get mealTemplateNameRequired;

  /// No description provided for @mealTemplateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved!'**
  String get mealTemplateSaved;

  /// No description provided for @mealTemplateDeleted.
  ///
  /// In en, this message translates to:
  /// **'Template deleted'**
  String get mealTemplateDeleted;

  /// No description provided for @mealTemplateDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Template?'**
  String get mealTemplateDeleteTitle;

  /// No description provided for @mealTemplateDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'This template will be permanently removed.'**
  String get mealTemplateDeleteContent;

  /// No description provided for @mealTemplateEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Template'**
  String get mealTemplateEditTitle;

  /// No description provided for @mealTemplateCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New Template'**
  String get mealTemplateCreateTitle;

  /// No description provided for @mealTemplateIngredientCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ingredients'**
  String mealTemplateIngredientCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
