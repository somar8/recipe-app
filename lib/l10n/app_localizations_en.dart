// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Recipe App';

  @override
  String get language => 'Language';

  @override
  String get languageAutomatic => 'Automatic';

  @override
  String languageAutomaticHint(String language) {
    return 'Follows your phone ($language)';
  }

  @override
  String get chooseLanguage => 'Choose a language';

  @override
  String get signOutQuestion => 'Sign out?';

  @override
  String get signOutMessage => 'Your recipes stay saved in your account.';

  @override
  String get cancel => 'Cancel';

  @override
  String get signOut => 'Sign out';

  @override
  String get account => 'Account';

  @override
  String get editYourDetails => 'Edit your details';

  @override
  String get friends => 'Friends';

  @override
  String get friendsSubtitle => 'Add friends and answer requests';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeAutoHint => 'Auto follows your device\'s setting.';

  @override
  String removeFriendQuestion(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeFriendMessage =>
      'You\'ll stop seeing each other\'s shared recipes and collections. You can send a new request later.';

  @override
  String get remove => 'Remove';

  @override
  String removedName(String name) {
    return 'Removed $name';
  }

  @override
  String someListsFailed(String details) {
    return 'Some lists didn\'t load. $details';
  }

  @override
  String get tryAgain => 'Try again';

  @override
  String get waitingForYou => 'Waiting for you';

  @override
  String get wantsToBeFriendsShort => 'wants to be friends';

  @override
  String get declined => 'Declined';

  @override
  String get decline => 'Decline';

  @override
  String nowFriends(String name) {
    return 'You and $name are now friends';
  }

  @override
  String get accept => 'Accept';

  @override
  String get yourFriends => 'Your friends';

  @override
  String get noFriendsYet =>
      'No friends yet. Send a request above, then share recipes from any recipe\'s Share button.';

  @override
  String moreFor(String name) {
    return 'More for $name';
  }

  @override
  String get removeFriend => 'Remove friend';

  @override
  String get requestsYouSent => 'Requests you sent';

  @override
  String sentWaiting(String label) {
    return '$label · waiting for an answer';
  }

  @override
  String get waitingForAnswer => 'Waiting for an answer';

  @override
  String get requestCancelled => 'Request cancelled';

  @override
  String requestSentTo(String name) {
    return 'Request sent to $name';
  }

  @override
  String requestSentToEmail(String email) {
    return 'Request sent to $email. If they use Recipe App, they\'ll see it.';
  }

  @override
  String get addAFriend => 'Add a friend';

  @override
  String get addFriendHint =>
      'Search by name or email. Pick someone to send a request.';

  @override
  String get nameOrEmail => 'Name or email';

  @override
  String get clear => 'Clear';

  @override
  String get typeAtLeast3 => 'Type at least 3 letters';

  @override
  String get noOneFound => 'No one found. Try their full email address.';

  @override
  String sendRequestTo(String email) {
    return 'Send a request to $email';
  }

  @override
  String get theyWillSeeIt => 'They\'ll see it when they use Recipe App';

  @override
  String get send => 'Send';

  @override
  String get requested => 'Requested';

  @override
  String get add => 'Add';

  @override
  String get wantsToBeFriends => 'Wants to be friends';

  @override
  String get yourFriend => 'your friend';

  @override
  String stepDone(int number, String text) {
    return 'Step $number, done: $text';
  }

  @override
  String stepUpNext(int number, String text) {
    return 'Step $number, up next: $text';
  }

  @override
  String shareTitle(String title) {
    return 'Share \"$title\"';
  }

  @override
  String get shareRecipeExplanation =>
      'Friends you pick can see this recipe and save their own copy. Only you can change it.';

  @override
  String get savedToYourRecipes => 'Saved to your recipes';

  @override
  String get open => 'Open';

  @override
  String alsoInSharedCollection(String name) {
    return 'It\'s also in a collection $name shared with you, so it stays there.';
  }

  @override
  String removedFromYourList(String title) {
    return 'Removed \"$title\" from your list';
  }

  @override
  String get deleteRecipeQuestion => 'Delete this recipe?';

  @override
  String deleteRecipeMessage(String title) {
    return '\"$title\" will be removed from your recipes and collections. This can\'t be undone.';
  }

  @override
  String get delete => 'Delete';

  @override
  String deletedTitle(String title) {
    return 'Deleted \"$title\"';
  }

  @override
  String get recipeNotFound => 'Recipe not found.';

  @override
  String get back => 'Back';

  @override
  String get shareWithFriends => 'Share with friends';

  @override
  String get edit => 'Edit';

  @override
  String get more => 'More';

  @override
  String get deleteRecipe => 'Delete recipe';

  @override
  String get removeFromMyList => 'Remove from my list';

  @override
  String get aFriend => 'A friend';

  @override
  String get sharedRecipeBanner =>
      'You see their latest version. Save a copy to change it your way.';

  @override
  String get saveACopy => 'Save a copy';

  @override
  String get prep => 'Prep';

  @override
  String get cook => 'Cook';

  @override
  String get total => 'Total';

  @override
  String get serves => 'Serves';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get clearTicks => 'Clear ticks';

  @override
  String get noIngredientsYet => 'No ingredients added yet.';

  @override
  String get steps => 'Steps';

  @override
  String get startOver => 'Start over';

  @override
  String get noStepsYet => 'No steps added yet.';

  @override
  String stepPlain(int number, String text) {
    return 'Step $number: $text';
  }

  @override
  String addedIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count ingredients',
      one: 'Added 1 ingredient',
    );
    return '$_temp0';
  }

  @override
  String get discardChangesQuestion => 'Discard changes?';

  @override
  String get discardRecipeMessage =>
      'What you typed in this recipe won\'t be saved.';

  @override
  String get discard => 'Discard';

  @override
  String get aboveZero => 'Above 0';

  @override
  String get close => 'Close';

  @override
  String get editRecipe => 'Edit recipe';

  @override
  String get newRecipe => 'New recipe';

  @override
  String get couldNotLoad => 'Could not load this.';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get saveRecipe => 'Save recipe';

  @override
  String get giveRecipeName => 'Give your recipe a name';

  @override
  String get recipeName => 'Recipe name';

  @override
  String get recipeNameExample => 'Fluffy pancakes';

  @override
  String get shortDescription => 'Short description';

  @override
  String get shortDescriptionExample => 'Sunday breakfast classic';

  @override
  String get timeAndServings => 'Time and servings';

  @override
  String get minutesShort => 'min';

  @override
  String get dragToReorderHint => 'Drag the handle to change the order.';

  @override
  String get addIngredient => 'Add ingredient';

  @override
  String get pasteAList => 'Paste a list';

  @override
  String get stepsExample =>
      'Whisk the flour, milk and eggs until smooth.\nRest the batter for 10 minutes.';

  @override
  String get stepsHelper => 'One step per line. They\'re numbered for you.';

  @override
  String get ingredient => 'Ingredient';

  @override
  String get amount => 'Amount';

  @override
  String get unit => 'Unit';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get removeIngredient => 'Remove ingredient';

  @override
  String get shareCollectionExplanation =>
      'Friends you pick can see this collection and every recipe in it, including ones you add later. Only you can change it.';

  @override
  String get deleteCollectionQuestion => 'Delete this collection?';

  @override
  String deleteCollectionMessage(String name) {
    return '\"$name\" will be deleted. The recipes in it are kept.';
  }

  @override
  String removedFromCollection(String title) {
    return 'Removed \"$title\" from this collection';
  }

  @override
  String get undo => 'Undo';

  @override
  String addedRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count recipes',
      one: 'Added 1 recipe',
    );
    return '$_temp0';
  }

  @override
  String get addSomeRecipesFirst => 'Add some recipes first.';

  @override
  String get allRecipesAlreadyIn =>
      'All your recipes are already in this collection.';

  @override
  String get deleteCollection => 'Delete collection';

  @override
  String get collectionNotFound => 'Collection not found.';

  @override
  String get sharedCollectionBanner =>
      'Recipes they add later show up here too. Open one to save a copy.';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '1 recipe',
    );
    return '$_temp0';
  }

  @override
  String get nothingHereYet => 'Nothing here yet';

  @override
  String get pickRecipesToAdd => 'Pick recipes to add to this collection.';

  @override
  String friendAddsShowUp(String name) {
    return 'Recipes $name adds will show up here.';
  }

  @override
  String get addRecipes => 'Add recipes';

  @override
  String get removeFromCollection => 'Remove from collection';

  @override
  String get searchRecipes => 'Search recipes';

  @override
  String get selectRecipes => 'Select recipes';

  @override
  String addNRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count recipes',
      one: 'Add 1 recipe',
    );
    return '$_temp0';
  }

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String fromName(String name) {
    return 'From $name';
  }

  @override
  String collectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count collections',
      one: '1 collection',
    );
    return '$_temp0';
  }

  @override
  String get aFriendLower => 'a friend';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get addFirstRecipe => 'Add your first recipe';

  @override
  String get addFirstRecipeMessage =>
      'Save the dishes you love, with ingredients and steps, and find them in seconds.';

  @override
  String get yourRecipes => 'Your recipes';

  @override
  String get sort => 'Sort';

  @override
  String get newestFirst => 'Newest first';

  @override
  String get aToZ => 'A to Z';

  @override
  String get quickestFirst => 'Quickest first';

  @override
  String searchNRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Search $count recipes or ingredients',
      one: 'Search 1 recipe or ingredients',
    );
    return '$_temp0';
  }

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noMatches => 'No matches';

  @override
  String nothingFits(String filters) {
    return 'Nothing fits \"$filters\". Try another filter, or show all recipes.';
  }

  @override
  String get tryAnotherWord => 'Try another word, or show all recipes.';

  @override
  String get showAll => 'Show all';

  @override
  String deletedCollectionKept(String name) {
    return 'Deleted \"$name\". Its recipes are kept.';
  }

  @override
  String get newCollection => 'New collection';

  @override
  String get groupYourRecipes => 'Group your recipes';

  @override
  String get groupYourRecipesMessage =>
      'Make collections like \"Weeknight dinners\" or \"Baking\" to find recipes faster.';

  @override
  String get yourCollections => 'Your collections';

  @override
  String get sharedWithYou => 'Shared with you';

  @override
  String get empty => 'Empty';

  @override
  String get discardMessage => 'What you typed won\'t be saved.';

  @override
  String get editCollection => 'Edit collection';

  @override
  String get giveCollectionName => 'Give your collection a name';

  @override
  String get name => 'Name';

  @override
  String get collectionNameExample => 'Weeknight dinners';

  @override
  String get description => 'Description';

  @override
  String get collectionDescriptionExample => 'Quick meals for busy evenings';

  @override
  String get createCollection => 'Create collection';

  @override
  String get signInToAccount => 'Sign in to your account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get newHereCreateAccount => 'New here? Create an account';

  @override
  String get enterFirstName => 'Enter your first name';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String checkEmailMessage(String email) {
    return 'Almost done! We sent a confirmation link to $email. Open it, then sign in.';
  }

  @override
  String get goToSignIn => 'Go to sign in';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get nameShownHint =>
      'Shown to your friends; you sign in with your email';

  @override
  String get atLeast6 => 'At least 6 characters';

  @override
  String get createAccount => 'Create account';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get detailsSaved => 'Your details are saved';

  @override
  String get yourDetails => 'Your details';

  @override
  String get lastNameOptional => 'Last name (optional)';

  @override
  String get friendsSeeName =>
      'Your friends see this name when you share recipes or send requests.';

  @override
  String get emailCantChange =>
      'You sign in with this address. It can\'t be changed here.';

  @override
  String get save => 'Save';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get pageNotFoundMessage =>
      'This link doesn\'t lead anywhere. The recipe may have been deleted.';

  @override
  String get goToYourRecipes => 'Go to your recipes';

  @override
  String hoursMinutesValue(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String minutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String hoursValue(int hours) {
    return '$hours h';
  }

  @override
  String servesN(int count) {
    return 'Serves $count';
  }

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredients',
      one: '1 ingredient',
    );
    return '$_temp0';
  }

  @override
  String sharedBy(String name) {
    return 'Shared by $name';
  }

  @override
  String get pasteIngredients => 'Paste ingredients';

  @override
  String get pasteIngredientsHint =>
      'One per line, like \"200 g flour\" or \"2 eggs\". Bullets, numbers and headings are ignored.';

  @override
  String get pasteIngredientsExample =>
      '200 g flour\n300 ml milk\n2 eggs\nPinch of salt';

  @override
  String get pasteFromClipboard => 'Paste from clipboard';

  @override
  String weFoundIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'We found $count ingredients',
      one: 'We found 1 ingredient',
    );
    return '$_temp0';
  }

  @override
  String addN(int count) {
    return 'Add $count';
  }

  @override
  String get noLongerShared => 'No longer shared';

  @override
  String sharedWithN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Shared with $count friends',
      one: 'Shared with 1 friend',
    );
    return '$_temp0';
  }

  @override
  String get noFriendsAddedYet => 'You haven\'t added any friends yet.';

  @override
  String get addFriends => 'Add friends';

  @override
  String get done => 'Done';

  @override
  String get anyTime => 'Any time';

  @override
  String get under30Min => 'Under 30 min';

  @override
  String get under1Hour => 'Under 1 hour';

  @override
  String get oneHourOrMore => '1 hour or more';

  @override
  String get all => 'All';

  @override
  String get mine => 'Mine';

  @override
  String get sharedWithMe => 'Shared with me';

  @override
  String get recipes => 'Recipes';

  @override
  String get collections => 'Collections';

  @override
  String friendRequestsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count friend requests waiting',
      one: '1 friend request waiting',
    );
    return '$_temp0';
  }

  @override
  String get errorOffline =>
      'No connection. Check your internet and try again.';

  @override
  String get errorWrongPassword => 'Wrong email or password.';

  @override
  String get errorConfirmEmailFirst =>
      'Please confirm your email first: open the link we sent you.';

  @override
  String get errorAccountExists =>
      'An account with this email already exists. Sign in instead.';

  @override
  String get errorPasswordTooShort =>
      'Your password needs at least 6 characters.';

  @override
  String get errorTooManyAttempts =>
      'Too many attempts. Please wait a few minutes and try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorOwnEmail => 'That\'s your own email address.';

  @override
  String get errorNotAnEmail => 'That doesn\'t look like an email address.';

  @override
  String get errorTooManyOpenRequests =>
      'You have 50 open requests. Wait for some answers first.';

  @override
  String get errorRecipeLimit =>
      'You\'ve reached 2,000 recipes, the most one account can keep.';

  @override
  String get errorCollectionLimit =>
      'You\'ve reached 300 collections, the most one account can keep.';

  @override
  String get errorIngredientLimit =>
      'A recipe can have at most 200 ingredients.';

  @override
  String get errorSlowDown => 'Slow down a little and try again later.';

  @override
  String get errorNotFound => 'Not found. It may have been deleted.';

  @override
  String get errorCheckValues =>
      'Please check the values: times and servings must be above 0, and a title is required.';

  @override
  String get errorForbidden => 'You don\'t have permission to do that.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get confirmLinkFailed =>
      'That confirmation link didn\'t work here (it may have expired or been opened in another browser). Your email may still be confirmed: try signing in.';

  @override
  String get signInProblem =>
      'Something went wrong with signing in. Please try again.';

  @override
  String get couldNotSignIn => 'Could not sign in. Please try again.';

  @override
  String get couldNotCreateAccount =>
      'Could not create the account. Please try again.';

  @override
  String get couldNotSaveName => 'Could not save your name. Please try again.';

  @override
  String get failedLoadRecipes => 'Failed to load recipes.';

  @override
  String get failedLoadRecipe => 'Failed to load the recipe.';

  @override
  String get failedSaveRecipe => 'Failed to save recipe.';

  @override
  String get onlyOwnerCanChange => 'Only the owner can change this recipe.';

  @override
  String get couldNotSaveCopy => 'Could not save a copy.';

  @override
  String get failedDeleteRecipe => 'Failed to delete recipe.';

  @override
  String get failedLoadCollections => 'Failed to load collections.';

  @override
  String get failedLoadCollection => 'Failed to load the collection.';

  @override
  String get failedSaveCollection => 'Failed to save the collection.';

  @override
  String get failedDeleteCollection => 'Failed to delete the collection.';

  @override
  String get failedAddRecipes => 'Failed to add recipes.';

  @override
  String get failedRemoveRecipe => 'Failed to remove the recipe.';

  @override
  String get failedLoadFriends => 'Failed to load your friends.';

  @override
  String get failedLoadRequests => 'Failed to load friend requests.';

  @override
  String get failedLoadSent => 'Failed to load your sent requests.';

  @override
  String get searchNotWorking => 'Search isn\'t working right now.';

  @override
  String get couldNotSendRequest =>
      'Could not send the request. Please try again.';

  @override
  String get couldNotAccept => 'Could not accept the request.';

  @override
  String get couldNotRemoveRequest => 'Could not remove the request.';

  @override
  String get couldNotRemoveFriend => 'Could not remove this friend.';

  @override
  String get failedLoadShares => 'Failed to load who this is shared with.';

  @override
  String get couldNotUpdateSharing =>
      'Could not update sharing. Please try again.';

  @override
  String get shareOnlyOwn =>
      'You can only share your own recipes and collections, and only with friends.';

  @override
  String get couldNotRemoveIt => 'Could not remove it. Please try again.';

  @override
  String get cookTab => 'Cook';

  @override
  String get whatCanICook => 'What can I cook?';

  @override
  String get whatCanICookHint =>
      'Add what you have at home and get three meal ideas. Salt, oil, flour and spices are counted as there.';

  @override
  String get addWhatYouHave => 'Add what you have';

  @override
  String get addWhatYouHaveExample => 'eggs, tomatoes, rice';

  @override
  String get nothingAddedYet =>
      'Nothing added yet. Type one item, or several separated by commas.';

  @override
  String removeItem(String item) {
    return 'Remove $item';
  }

  @override
  String get clearAll => 'Clear all';

  @override
  String get suggestMeals => 'Suggest meals';

  @override
  String get suggestOtherMeals => 'Suggest other meals';

  @override
  String get thinkingUpMeals => 'Thinking up meals…';

  @override
  String get pickAMeal => 'Pick a meal';

  @override
  String get youHaveEverything => 'You have everything';

  @override
  String youdNeed(String items) {
    return 'You\'d need: $items';
  }

  @override
  String get youHaveThis => 'You have this';

  @override
  String get toBuy => 'To buy';

  @override
  String get saveToMyRecipes => 'Save to my recipes';

  @override
  String get aiCheckNote =>
      'Written by AI: check amounts, times and allergens before you cook.';

  @override
  String get writeStepsWithAi => 'Write the steps with AI';

  @override
  String get writingSteps => 'Writing steps…';

  @override
  String get stepsWritten =>
      'Steps written. Read them through and change anything before saving.';

  @override
  String get aiNeedsNameAndIngredients =>
      'Add a recipe name and at least one ingredient first.';

  @override
  String get replaceStepsQuestion => 'Replace your steps?';

  @override
  String get replaceStepsMessage =>
      'The AI writes new steps in place of the ones you have.';

  @override
  String get replace => 'Replace';

  @override
  String aiLeftToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count AI requests left today',
      one: '1 AI request left today',
      zero: 'No AI requests left today',
    );
    return '$_temp0';
  }

  @override
  String get aiDailyLimit =>
      'You\'ve used today\'s 20 AI requests. Try again tomorrow.';

  @override
  String get aiBusy =>
      'The free AI is busy right now. Try again in a minute; this one didn\'t count.';

  @override
  String get aiNotSetUp => 'The AI helper isn\'t set up yet.';

  @override
  String get aiFailed =>
      'The AI couldn\'t answer this time. Try again; this one didn\'t count.';

  @override
  String aiAnswerIn(String language) {
    return 'AI language: $language';
  }
}
