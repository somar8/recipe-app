import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('nl'),
  ];

  /// The app's name
  ///
  /// In en, this message translates to:
  /// **'Recipe App'**
  String get appName;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get languageAutomatic;

  /// No description provided for @languageAutomaticHint.
  ///
  /// In en, this message translates to:
  /// **'Follows your phone ({language})'**
  String languageAutomaticHint(String language);

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get chooseLanguage;

  /// No description provided for @signOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutQuestion;

  /// No description provided for @signOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Your recipes stay saved in your account.'**
  String get signOutMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit your details'**
  String get editYourDetails;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @friendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add friends and answer requests'**
  String get friendsSubtitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeAuto;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeAutoHint.
  ///
  /// In en, this message translates to:
  /// **'Auto follows your device\'s setting.'**
  String get themeAutoHint;

  /// No description provided for @removeFriendQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeFriendQuestion(String name);

  /// No description provided for @removeFriendMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll stop seeing each other\'s shared recipes and collections. You can send a new request later.'**
  String get removeFriendMessage;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removedName.
  ///
  /// In en, this message translates to:
  /// **'Removed {name}'**
  String removedName(String name);

  /// No description provided for @someListsFailed.
  ///
  /// In en, this message translates to:
  /// **'Some lists didn\'t load. {details}'**
  String someListsFailed(String details);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @waitingForYou.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you'**
  String get waitingForYou;

  /// No description provided for @wantsToBeFriendsShort.
  ///
  /// In en, this message translates to:
  /// **'wants to be friends'**
  String get wantsToBeFriendsShort;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @nowFriends.
  ///
  /// In en, this message translates to:
  /// **'You and {name} are now friends'**
  String nowFriends(String name);

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @yourFriends.
  ///
  /// In en, this message translates to:
  /// **'Your friends'**
  String get yourFriends;

  /// No description provided for @noFriendsYet.
  ///
  /// In en, this message translates to:
  /// **'No friends yet. Send a request above, then share recipes from any recipe\'s Share button.'**
  String get noFriendsYet;

  /// No description provided for @moreFor.
  ///
  /// In en, this message translates to:
  /// **'More for {name}'**
  String moreFor(String name);

  /// No description provided for @removeFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove friend'**
  String get removeFriend;

  /// No description provided for @requestsYouSent.
  ///
  /// In en, this message translates to:
  /// **'Requests you sent'**
  String get requestsYouSent;

  /// No description provided for @sentWaiting.
  ///
  /// In en, this message translates to:
  /// **'{label} · waiting for an answer'**
  String sentWaiting(String label);

  /// No description provided for @waitingForAnswer.
  ///
  /// In en, this message translates to:
  /// **'Waiting for an answer'**
  String get waitingForAnswer;

  /// No description provided for @requestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled'**
  String get requestCancelled;

  /// No description provided for @requestSentTo.
  ///
  /// In en, this message translates to:
  /// **'Request sent to {name}'**
  String requestSentTo(String name);

  /// No description provided for @requestSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'Request sent to {email}. If they use Recipe App, they\'ll see it.'**
  String requestSentToEmail(String email);

  /// No description provided for @addAFriend.
  ///
  /// In en, this message translates to:
  /// **'Add a friend'**
  String get addAFriend;

  /// No description provided for @addFriendHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email. Pick someone to send a request.'**
  String get addFriendHint;

  /// No description provided for @nameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Name or email'**
  String get nameOrEmail;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @typeAtLeast3.
  ///
  /// In en, this message translates to:
  /// **'Type at least 3 letters'**
  String get typeAtLeast3;

  /// No description provided for @noOneFound.
  ///
  /// In en, this message translates to:
  /// **'No one found. Try their full email address.'**
  String get noOneFound;

  /// No description provided for @sendRequestTo.
  ///
  /// In en, this message translates to:
  /// **'Send a request to {email}'**
  String sendRequestTo(String email);

  /// No description provided for @theyWillSeeIt.
  ///
  /// In en, this message translates to:
  /// **'They\'ll see it when they use Recipe App'**
  String get theyWillSeeIt;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @wantsToBeFriends.
  ///
  /// In en, this message translates to:
  /// **'Wants to be friends'**
  String get wantsToBeFriends;

  /// No description provided for @yourFriend.
  ///
  /// In en, this message translates to:
  /// **'your friend'**
  String get yourFriend;

  /// No description provided for @stepDone.
  ///
  /// In en, this message translates to:
  /// **'Step {number}, done: {text}'**
  String stepDone(int number, String text);

  /// No description provided for @stepUpNext.
  ///
  /// In en, this message translates to:
  /// **'Step {number}, up next: {text}'**
  String stepUpNext(int number, String text);

  /// No description provided for @shareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share \"{title}\"'**
  String shareTitle(String title);

  /// No description provided for @shareRecipeExplanation.
  ///
  /// In en, this message translates to:
  /// **'Friends you pick can see this recipe and save their own copy. Only you can change it.'**
  String get shareRecipeExplanation;

  /// No description provided for @savedToYourRecipes.
  ///
  /// In en, this message translates to:
  /// **'Saved to your recipes'**
  String get savedToYourRecipes;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @alsoInSharedCollection.
  ///
  /// In en, this message translates to:
  /// **'It\'s also in a collection {name} shared with you, so it stays there.'**
  String alsoInSharedCollection(String name);

  /// No description provided for @removedFromYourList.
  ///
  /// In en, this message translates to:
  /// **'Removed \"{title}\" from your list'**
  String removedFromYourList(String title);

  /// No description provided for @deleteRecipeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this recipe?'**
  String get deleteRecipeQuestion;

  /// No description provided for @deleteRecipeMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed from your recipes and collections. This can\'t be undone.'**
  String deleteRecipeMessage(String title);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{title}\"'**
  String deletedTitle(String title);

  /// No description provided for @recipeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Recipe not found.'**
  String get recipeNotFound;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @shareWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Share with friends'**
  String get shareWithFriends;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @deleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe'**
  String get deleteRecipe;

  /// No description provided for @removeFromMyList.
  ///
  /// In en, this message translates to:
  /// **'Remove from my list'**
  String get removeFromMyList;

  /// No description provided for @aFriend.
  ///
  /// In en, this message translates to:
  /// **'A friend'**
  String get aFriend;

  /// No description provided for @sharedRecipeBanner.
  ///
  /// In en, this message translates to:
  /// **'You see their latest version. Save a copy to change it your way.'**
  String get sharedRecipeBanner;

  /// No description provided for @saveACopy.
  ///
  /// In en, this message translates to:
  /// **'Save a copy'**
  String get saveACopy;

  /// No description provided for @prep.
  ///
  /// In en, this message translates to:
  /// **'Prep'**
  String get prep;

  /// No description provided for @cook.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get cook;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @serves.
  ///
  /// In en, this message translates to:
  /// **'Serves'**
  String get serves;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @clearTicks.
  ///
  /// In en, this message translates to:
  /// **'Clear ticks'**
  String get clearTicks;

  /// No description provided for @noIngredientsYet.
  ///
  /// In en, this message translates to:
  /// **'No ingredients added yet.'**
  String get noIngredientsYet;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @startOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get startOver;

  /// No description provided for @noStepsYet.
  ///
  /// In en, this message translates to:
  /// **'No steps added yet.'**
  String get noStepsYet;

  /// No description provided for @stepPlain.
  ///
  /// In en, this message translates to:
  /// **'Step {number}: {text}'**
  String stepPlain(int number, String text);

  /// No description provided for @addedIngredients.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Added 1 ingredient} other{Added {count} ingredients}}'**
  String addedIngredients(int count);

  /// No description provided for @discardChangesQuestion.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesQuestion;

  /// No description provided for @discardRecipeMessage.
  ///
  /// In en, this message translates to:
  /// **'What you typed in this recipe won\'t be saved.'**
  String get discardRecipeMessage;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @aboveZero.
  ///
  /// In en, this message translates to:
  /// **'Above 0'**
  String get aboveZero;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @editRecipe.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get editRecipe;

  /// No description provided for @newRecipe.
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get newRecipe;

  /// No description provided for @couldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load this.'**
  String get couldNotLoad;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saveRecipe.
  ///
  /// In en, this message translates to:
  /// **'Save recipe'**
  String get saveRecipe;

  /// No description provided for @giveRecipeName.
  ///
  /// In en, this message translates to:
  /// **'Give your recipe a name'**
  String get giveRecipeName;

  /// No description provided for @recipeName.
  ///
  /// In en, this message translates to:
  /// **'Recipe name'**
  String get recipeName;

  /// No description provided for @recipeNameExample.
  ///
  /// In en, this message translates to:
  /// **'Fluffy pancakes'**
  String get recipeNameExample;

  /// No description provided for @shortDescription.
  ///
  /// In en, this message translates to:
  /// **'Short description'**
  String get shortDescription;

  /// No description provided for @shortDescriptionExample.
  ///
  /// In en, this message translates to:
  /// **'Sunday breakfast classic'**
  String get shortDescriptionExample;

  /// No description provided for @timeAndServings.
  ///
  /// In en, this message translates to:
  /// **'Time and servings'**
  String get timeAndServings;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// No description provided for @dragToReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the handle to change the order.'**
  String get dragToReorderHint;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get addIngredient;

  /// No description provided for @pasteAList.
  ///
  /// In en, this message translates to:
  /// **'Paste a list'**
  String get pasteAList;

  /// No description provided for @stepsExample.
  ///
  /// In en, this message translates to:
  /// **'Whisk the flour, milk and eggs until smooth.\nRest the batter for 10 minutes.'**
  String get stepsExample;

  /// No description provided for @stepsHelper.
  ///
  /// In en, this message translates to:
  /// **'One step per line. They\'re numbered for you.'**
  String get stepsHelper;

  /// No description provided for @ingredient.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get ingredient;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get dragToReorder;

  /// No description provided for @removeIngredient.
  ///
  /// In en, this message translates to:
  /// **'Remove ingredient'**
  String get removeIngredient;

  /// No description provided for @shareCollectionExplanation.
  ///
  /// In en, this message translates to:
  /// **'Friends you pick can see this collection and every recipe in it, including ones you add later. Only you can change it.'**
  String get shareCollectionExplanation;

  /// No description provided for @deleteCollectionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this collection?'**
  String get deleteCollectionQuestion;

  /// No description provided for @deleteCollectionMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be deleted. The recipes in it are kept.'**
  String deleteCollectionMessage(String name);

  /// No description provided for @removedFromCollection.
  ///
  /// In en, this message translates to:
  /// **'Removed \"{title}\" from this collection'**
  String removedFromCollection(String title);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @addedRecipes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Added 1 recipe} other{Added {count} recipes}}'**
  String addedRecipes(int count);

  /// No description provided for @addSomeRecipesFirst.
  ///
  /// In en, this message translates to:
  /// **'Add some recipes first.'**
  String get addSomeRecipesFirst;

  /// No description provided for @allRecipesAlreadyIn.
  ///
  /// In en, this message translates to:
  /// **'All your recipes are already in this collection.'**
  String get allRecipesAlreadyIn;

  /// No description provided for @deleteCollection.
  ///
  /// In en, this message translates to:
  /// **'Delete collection'**
  String get deleteCollection;

  /// No description provided for @collectionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Collection not found.'**
  String get collectionNotFound;

  /// No description provided for @sharedCollectionBanner.
  ///
  /// In en, this message translates to:
  /// **'Recipes they add later show up here too. Open one to save a copy.'**
  String get sharedCollectionBanner;

  /// No description provided for @recipeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recipe} other{{count} recipes}}'**
  String recipeCount(int count);

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHereYet;

  /// No description provided for @pickRecipesToAdd.
  ///
  /// In en, this message translates to:
  /// **'Pick recipes to add to this collection.'**
  String get pickRecipesToAdd;

  /// No description provided for @friendAddsShowUp.
  ///
  /// In en, this message translates to:
  /// **'Recipes {name} adds will show up here.'**
  String friendAddsShowUp(String name);

  /// No description provided for @addRecipes.
  ///
  /// In en, this message translates to:
  /// **'Add recipes'**
  String get addRecipes;

  /// No description provided for @removeFromCollection.
  ///
  /// In en, this message translates to:
  /// **'Remove from collection'**
  String get removeFromCollection;

  /// No description provided for @searchRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search recipes'**
  String get searchRecipes;

  /// No description provided for @selectRecipes.
  ///
  /// In en, this message translates to:
  /// **'Select recipes'**
  String get selectRecipes;

  /// No description provided for @addNRecipes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 recipe} other{Add {count} recipes}}'**
  String addNRecipes(int count);

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @fromName.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String fromName(String name);

  /// No description provided for @collectionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 collection} other{{count} collections}}'**
  String collectionCount(int count);

  /// No description provided for @aFriendLower.
  ///
  /// In en, this message translates to:
  /// **'a friend'**
  String get aFriendLower;

  /// No description provided for @greetingWithName.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}'**
  String greetingWithName(String greeting, String name);

  /// No description provided for @addFirstRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add your first recipe'**
  String get addFirstRecipe;

  /// No description provided for @addFirstRecipeMessage.
  ///
  /// In en, this message translates to:
  /// **'Save the dishes you love, with ingredients and steps, and find them in seconds.'**
  String get addFirstRecipeMessage;

  /// No description provided for @yourRecipes.
  ///
  /// In en, this message translates to:
  /// **'Your recipes'**
  String get yourRecipes;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get newestFirst;

  /// No description provided for @aToZ.
  ///
  /// In en, this message translates to:
  /// **'A to Z'**
  String get aToZ;

  /// No description provided for @quickestFirst.
  ///
  /// In en, this message translates to:
  /// **'Quickest first'**
  String get quickestFirst;

  /// No description provided for @searchNRecipes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Search 1 recipe or ingredients} other{Search {count} recipes or ingredients}}'**
  String searchNRecipes(int count);

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noMatches;

  /// No description provided for @nothingFits.
  ///
  /// In en, this message translates to:
  /// **'Nothing fits \"{filters}\". Try another filter, or show all recipes.'**
  String nothingFits(String filters);

  /// No description provided for @tryAnotherWord.
  ///
  /// In en, this message translates to:
  /// **'Try another word, or show all recipes.'**
  String get tryAnotherWord;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @deletedCollectionKept.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{name}\". Its recipes are kept.'**
  String deletedCollectionKept(String name);

  /// No description provided for @newCollection.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get newCollection;

  /// No description provided for @groupYourRecipes.
  ///
  /// In en, this message translates to:
  /// **'Group your recipes'**
  String get groupYourRecipes;

  /// No description provided for @groupYourRecipesMessage.
  ///
  /// In en, this message translates to:
  /// **'Make collections like \"Weeknight dinners\" or \"Baking\" to find recipes faster.'**
  String get groupYourRecipesMessage;

  /// No description provided for @yourCollections.
  ///
  /// In en, this message translates to:
  /// **'Your collections'**
  String get yourCollections;

  /// No description provided for @sharedWithYou.
  ///
  /// In en, this message translates to:
  /// **'Shared with you'**
  String get sharedWithYou;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @discardMessage.
  ///
  /// In en, this message translates to:
  /// **'What you typed won\'t be saved.'**
  String get discardMessage;

  /// No description provided for @editCollection.
  ///
  /// In en, this message translates to:
  /// **'Edit collection'**
  String get editCollection;

  /// No description provided for @giveCollectionName.
  ///
  /// In en, this message translates to:
  /// **'Give your collection a name'**
  String get giveCollectionName;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @collectionNameExample.
  ///
  /// In en, this message translates to:
  /// **'Weeknight dinners'**
  String get collectionNameExample;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @collectionDescriptionExample.
  ///
  /// In en, this message translates to:
  /// **'Quick meals for busy evenings'**
  String get collectionDescriptionExample;

  /// No description provided for @createCollection.
  ///
  /// In en, this message translates to:
  /// **'Create collection'**
  String get createCollection;

  /// No description provided for @signInToAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @newHereCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get newHereCreateAccount;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get enterFirstName;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @checkEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Almost done! We sent a confirmation link to {email}. Open it, then sign in.'**
  String checkEmailMessage(String email);

  /// No description provided for @goToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Go to sign in'**
  String get goToSignIn;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @nameShownHint.
  ///
  /// In en, this message translates to:
  /// **'Shown to your friends; you sign in with your email'**
  String get nameShownHint;

  /// No description provided for @atLeast6.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get atLeast6;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @detailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Your details are saved'**
  String get detailsSaved;

  /// No description provided for @yourDetails.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get yourDetails;

  /// No description provided for @lastNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Last name (optional)'**
  String get lastNameOptional;

  /// No description provided for @friendsSeeName.
  ///
  /// In en, this message translates to:
  /// **'Your friends see this name when you share recipes or send requests.'**
  String get friendsSeeName;

  /// No description provided for @emailCantChange.
  ///
  /// In en, this message translates to:
  /// **'You sign in with this address. It can\'t be changed here.'**
  String get emailCantChange;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @pageNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This link doesn\'t lead anywhere. The recipe may have been deleted.'**
  String get pageNotFoundMessage;

  /// No description provided for @goToYourRecipes.
  ///
  /// In en, this message translates to:
  /// **'Go to your recipes'**
  String get goToYourRecipes;

  /// No description provided for @hoursMinutesValue.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String hoursMinutesValue(int hours, int minutes);

  /// No description provided for @minutesValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesValue(int minutes);

  /// No description provided for @hoursValue.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String hoursValue(int hours);

  /// No description provided for @servesN.
  ///
  /// In en, this message translates to:
  /// **'Serves {count}'**
  String servesN(int count);

  /// No description provided for @ingredientCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 ingredient} other{{count} ingredients}}'**
  String ingredientCount(int count);

  /// No description provided for @sharedBy.
  ///
  /// In en, this message translates to:
  /// **'Shared by {name}'**
  String sharedBy(String name);

  /// No description provided for @pasteIngredients.
  ///
  /// In en, this message translates to:
  /// **'Paste ingredients'**
  String get pasteIngredients;

  /// No description provided for @pasteIngredientsHint.
  ///
  /// In en, this message translates to:
  /// **'One per line, like \"200 g flour\" or \"2 eggs\". Bullets, numbers and headings are ignored.'**
  String get pasteIngredientsHint;

  /// No description provided for @pasteIngredientsExample.
  ///
  /// In en, this message translates to:
  /// **'200 g flour\n300 ml milk\n2 eggs\nPinch of salt'**
  String get pasteIngredientsExample;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get pasteFromClipboard;

  /// No description provided for @weFoundIngredients.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{We found 1 ingredient} other{We found {count} ingredients}}'**
  String weFoundIngredients(int count);

  /// No description provided for @addN.
  ///
  /// In en, this message translates to:
  /// **'Add {count}'**
  String addN(int count);

  /// No description provided for @noLongerShared.
  ///
  /// In en, this message translates to:
  /// **'No longer shared'**
  String get noLongerShared;

  /// No description provided for @sharedWithN.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Shared with 1 friend} other{Shared with {count} friends}}'**
  String sharedWithN(int count);

  /// No description provided for @noFriendsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any friends yet.'**
  String get noFriendsAddedYet;

  /// No description provided for @addFriends.
  ///
  /// In en, this message translates to:
  /// **'Add friends'**
  String get addFriends;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @anyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get anyTime;

  /// No description provided for @under30Min.
  ///
  /// In en, this message translates to:
  /// **'Under 30 min'**
  String get under30Min;

  /// No description provided for @under1Hour.
  ///
  /// In en, this message translates to:
  /// **'Under 1 hour'**
  String get under1Hour;

  /// No description provided for @oneHourOrMore.
  ///
  /// In en, this message translates to:
  /// **'1 hour or more'**
  String get oneHourOrMore;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @mine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get mine;

  /// No description provided for @sharedWithMe.
  ///
  /// In en, this message translates to:
  /// **'Shared with me'**
  String get sharedWithMe;

  /// No description provided for @recipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipes;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @friendRequestsWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 friend request waiting} other{{count} friend requests waiting}}'**
  String friendRequestsWaiting(int count);

  /// No description provided for @errorOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get errorOffline;

  /// No description provided for @errorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get errorWrongPassword;

  /// No description provided for @errorConfirmEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email first: open the link we sent you.'**
  String get errorConfirmEmailFirst;

  /// No description provided for @errorAccountExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Sign in instead.'**
  String get errorAccountExists;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Your password needs at least 6 characters.'**
  String get errorPasswordTooShort;

  /// No description provided for @errorTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a few minutes and try again.'**
  String get errorTooManyAttempts;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorOwnEmail.
  ///
  /// In en, this message translates to:
  /// **'That\'s your own email address.'**
  String get errorOwnEmail;

  /// No description provided for @errorNotAnEmail.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like an email address.'**
  String get errorNotAnEmail;

  /// No description provided for @errorTooManyOpenRequests.
  ///
  /// In en, this message translates to:
  /// **'You have 50 open requests. Wait for some answers first.'**
  String get errorTooManyOpenRequests;

  /// No description provided for @errorRecipeLimit.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached 2,000 recipes, the most one account can keep.'**
  String get errorRecipeLimit;

  /// No description provided for @errorCollectionLimit.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached 300 collections, the most one account can keep.'**
  String get errorCollectionLimit;

  /// No description provided for @errorIngredientLimit.
  ///
  /// In en, this message translates to:
  /// **'A recipe can have at most 200 ingredients.'**
  String get errorIngredientLimit;

  /// No description provided for @errorSlowDown.
  ///
  /// In en, this message translates to:
  /// **'Slow down a little and try again later.'**
  String get errorSlowDown;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found. It may have been deleted.'**
  String get errorNotFound;

  /// No description provided for @errorCheckValues.
  ///
  /// In en, this message translates to:
  /// **'Please check the values: times and servings must be above 0, and a title is required.'**
  String get errorCheckValues;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do that.'**
  String get errorForbidden;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorSessionExpired;

  /// No description provided for @confirmLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'That confirmation link didn\'t work here (it may have expired or been opened in another browser). Your email may still be confirmed: try signing in.'**
  String get confirmLinkFailed;

  /// No description provided for @signInProblem.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong with signing in. Please try again.'**
  String get signInProblem;

  /// No description provided for @couldNotSignIn.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Please try again.'**
  String get couldNotSignIn;

  /// No description provided for @couldNotCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not create the account. Please try again.'**
  String get couldNotCreateAccount;

  /// No description provided for @couldNotSaveName.
  ///
  /// In en, this message translates to:
  /// **'Could not save your name. Please try again.'**
  String get couldNotSaveName;

  /// No description provided for @failedLoadRecipes.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recipes.'**
  String get failedLoadRecipes;

  /// No description provided for @failedLoadRecipe.
  ///
  /// In en, this message translates to:
  /// **'Failed to load the recipe.'**
  String get failedLoadRecipe;

  /// No description provided for @failedSaveRecipe.
  ///
  /// In en, this message translates to:
  /// **'Failed to save recipe.'**
  String get failedSaveRecipe;

  /// No description provided for @onlyOwnerCanChange.
  ///
  /// In en, this message translates to:
  /// **'Only the owner can change this recipe.'**
  String get onlyOwnerCanChange;

  /// No description provided for @couldNotSaveCopy.
  ///
  /// In en, this message translates to:
  /// **'Could not save a copy.'**
  String get couldNotSaveCopy;

  /// No description provided for @failedDeleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete recipe.'**
  String get failedDeleteRecipe;

  /// No description provided for @failedLoadCollections.
  ///
  /// In en, this message translates to:
  /// **'Failed to load collections.'**
  String get failedLoadCollections;

  /// No description provided for @failedLoadCollection.
  ///
  /// In en, this message translates to:
  /// **'Failed to load the collection.'**
  String get failedLoadCollection;

  /// No description provided for @failedSaveCollection.
  ///
  /// In en, this message translates to:
  /// **'Failed to save the collection.'**
  String get failedSaveCollection;

  /// No description provided for @failedDeleteCollection.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete the collection.'**
  String get failedDeleteCollection;

  /// No description provided for @failedAddRecipes.
  ///
  /// In en, this message translates to:
  /// **'Failed to add recipes.'**
  String get failedAddRecipes;

  /// No description provided for @failedRemoveRecipe.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove the recipe.'**
  String get failedRemoveRecipe;

  /// No description provided for @failedLoadFriends.
  ///
  /// In en, this message translates to:
  /// **'Failed to load your friends.'**
  String get failedLoadFriends;

  /// No description provided for @failedLoadRequests.
  ///
  /// In en, this message translates to:
  /// **'Failed to load friend requests.'**
  String get failedLoadRequests;

  /// No description provided for @failedLoadSent.
  ///
  /// In en, this message translates to:
  /// **'Failed to load your sent requests.'**
  String get failedLoadSent;

  /// No description provided for @searchNotWorking.
  ///
  /// In en, this message translates to:
  /// **'Search isn\'t working right now.'**
  String get searchNotWorking;

  /// No description provided for @couldNotSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Could not send the request. Please try again.'**
  String get couldNotSendRequest;

  /// No description provided for @couldNotAccept.
  ///
  /// In en, this message translates to:
  /// **'Could not accept the request.'**
  String get couldNotAccept;

  /// No description provided for @couldNotRemoveRequest.
  ///
  /// In en, this message translates to:
  /// **'Could not remove the request.'**
  String get couldNotRemoveRequest;

  /// No description provided for @couldNotRemoveFriend.
  ///
  /// In en, this message translates to:
  /// **'Could not remove this friend.'**
  String get couldNotRemoveFriend;

  /// No description provided for @failedLoadShares.
  ///
  /// In en, this message translates to:
  /// **'Failed to load who this is shared with.'**
  String get failedLoadShares;

  /// No description provided for @couldNotUpdateSharing.
  ///
  /// In en, this message translates to:
  /// **'Could not update sharing. Please try again.'**
  String get couldNotUpdateSharing;

  /// No description provided for @shareOnlyOwn.
  ///
  /// In en, this message translates to:
  /// **'You can only share your own recipes and collections, and only with friends.'**
  String get shareOnlyOwn;

  /// No description provided for @couldNotRemoveIt.
  ///
  /// In en, this message translates to:
  /// **'Could not remove it. Please try again.'**
  String get couldNotRemoveIt;

  /// No description provided for @cookTab.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get cookTab;

  /// No description provided for @whatCanICook.
  ///
  /// In en, this message translates to:
  /// **'What can I cook?'**
  String get whatCanICook;

  /// No description provided for @whatCanICookHint.
  ///
  /// In en, this message translates to:
  /// **'Add what you have at home and get three meal ideas. Salt, oil, flour and spices are counted as there.'**
  String get whatCanICookHint;

  /// No description provided for @addWhatYouHave.
  ///
  /// In en, this message translates to:
  /// **'Add what you have'**
  String get addWhatYouHave;

  /// No description provided for @addWhatYouHaveExample.
  ///
  /// In en, this message translates to:
  /// **'eggs, tomatoes, rice'**
  String get addWhatYouHaveExample;

  /// No description provided for @nothingAddedYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing added yet. Type one item, or several separated by commas.'**
  String get nothingAddedYet;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove {item}'**
  String removeItem(String item);

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @suggestMeals.
  ///
  /// In en, this message translates to:
  /// **'Suggest meals'**
  String get suggestMeals;

  /// No description provided for @suggestOtherMeals.
  ///
  /// In en, this message translates to:
  /// **'Suggest other meals'**
  String get suggestOtherMeals;

  /// No description provided for @thinkingUpMeals.
  ///
  /// In en, this message translates to:
  /// **'Thinking up meals…'**
  String get thinkingUpMeals;

  /// No description provided for @pickAMeal.
  ///
  /// In en, this message translates to:
  /// **'Pick a meal'**
  String get pickAMeal;

  /// No description provided for @youHaveEverything.
  ///
  /// In en, this message translates to:
  /// **'You have everything'**
  String get youHaveEverything;

  /// No description provided for @youdNeed.
  ///
  /// In en, this message translates to:
  /// **'You\'d need: {items}'**
  String youdNeed(String items);

  /// No description provided for @youHaveThis.
  ///
  /// In en, this message translates to:
  /// **'You have this'**
  String get youHaveThis;

  /// No description provided for @toBuy.
  ///
  /// In en, this message translates to:
  /// **'To buy'**
  String get toBuy;

  /// No description provided for @saveToMyRecipes.
  ///
  /// In en, this message translates to:
  /// **'Save to my recipes'**
  String get saveToMyRecipes;

  /// No description provided for @aiCheckNote.
  ///
  /// In en, this message translates to:
  /// **'Written by AI: check amounts, times and allergens before you cook.'**
  String get aiCheckNote;

  /// No description provided for @writeStepsWithAi.
  ///
  /// In en, this message translates to:
  /// **'Write the steps with AI'**
  String get writeStepsWithAi;

  /// No description provided for @writingSteps.
  ///
  /// In en, this message translates to:
  /// **'Writing steps…'**
  String get writingSteps;

  /// No description provided for @stepsWritten.
  ///
  /// In en, this message translates to:
  /// **'Steps written. Read them through and change anything before saving.'**
  String get stepsWritten;

  /// No description provided for @aiNeedsNameAndIngredients.
  ///
  /// In en, this message translates to:
  /// **'Add a recipe name and at least one ingredient first.'**
  String get aiNeedsNameAndIngredients;

  /// No description provided for @replaceStepsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Replace your steps?'**
  String get replaceStepsQuestion;

  /// No description provided for @replaceStepsMessage.
  ///
  /// In en, this message translates to:
  /// **'The AI writes new steps in place of the ones you have.'**
  String get replaceStepsMessage;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @aiLeftToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No AI requests left today} =1{1 AI request left today} other{{count} AI requests left today}}'**
  String aiLeftToday(int count);

  /// No description provided for @aiDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used today\'s 20 AI requests. Try again tomorrow.'**
  String get aiDailyLimit;

  /// No description provided for @aiBusy.
  ///
  /// In en, this message translates to:
  /// **'The free AI is busy right now. Try again in a minute; this one didn\'t count.'**
  String get aiBusy;

  /// No description provided for @aiNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'The AI helper isn\'t set up yet.'**
  String get aiNotSetUp;

  /// No description provided for @aiFailed.
  ///
  /// In en, this message translates to:
  /// **'The AI couldn\'t answer this time. Try again; this one didn\'t count.'**
  String get aiFailed;
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
      <String>['ar', 'de', 'en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
