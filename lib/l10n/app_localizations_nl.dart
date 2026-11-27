// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'Recipe App';

  @override
  String get language => 'Taal';

  @override
  String get languageAutomatic => 'Automatisch';

  @override
  String languageAutomaticHint(String language) {
    return 'Volgt je telefoon ($language)';
  }

  @override
  String get chooseLanguage => 'Kies een taal';

  @override
  String get signOutQuestion => 'Uitloggen?';

  @override
  String get signOutMessage => 'Je recepten blijven bewaard in je account.';

  @override
  String get cancel => 'Annuleren';

  @override
  String get signOut => 'Uitloggen';

  @override
  String get account => 'Account';

  @override
  String get editYourDetails => 'Je gegevens bewerken';

  @override
  String get friends => 'Vrienden';

  @override
  String get friendsSubtitle => 'Vrienden toevoegen en verzoeken beantwoorden';

  @override
  String get appearance => 'Weergave';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Licht';

  @override
  String get themeDark => 'Donker';

  @override
  String get themeAutoHint => 'Auto volgt de instelling van je apparaat.';

  @override
  String removeFriendQuestion(String name) {
    return '$name verwijderen?';
  }

  @override
  String get removeFriendMessage =>
      'Jullie zien elkaars gedeelde recepten en verzamelingen dan niet meer. Je kunt later een nieuw verzoek sturen.';

  @override
  String get remove => 'Verwijderen';

  @override
  String removedName(String name) {
    return '$name verwijderd';
  }

  @override
  String someListsFailed(String details) {
    return 'Niet alle lijsten zijn geladen. $details';
  }

  @override
  String get tryAgain => 'Opnieuw proberen';

  @override
  String get waitingForYou => 'Wacht op jou';

  @override
  String get wantsToBeFriendsShort => 'wil vrienden worden';

  @override
  String get declined => 'Geweigerd';

  @override
  String get decline => 'Weigeren';

  @override
  String nowFriends(String name) {
    return 'Jij en $name zijn nu vrienden';
  }

  @override
  String get accept => 'Accepteren';

  @override
  String get yourFriends => 'Je vrienden';

  @override
  String get noFriendsYet =>
      'Nog geen vrienden. Stuur hierboven een verzoek en deel recepten met de knop Delen bij een recept.';

  @override
  String moreFor(String name) {
    return 'Meer voor $name';
  }

  @override
  String get removeFriend => 'Vriend verwijderen';

  @override
  String get requestsYouSent => 'Verzoeken die je hebt gestuurd';

  @override
  String sentWaiting(String label) {
    return '$label · wacht op antwoord';
  }

  @override
  String get waitingForAnswer => 'Wacht op antwoord';

  @override
  String get requestCancelled => 'Verzoek ingetrokken';

  @override
  String requestSentTo(String name) {
    return 'Verzoek gestuurd naar $name';
  }

  @override
  String requestSentToEmail(String email) {
    return 'Verzoek gestuurd naar $email. Als die persoon Recipe App gebruikt, ziet die het.';
  }

  @override
  String get addAFriend => 'Vriend toevoegen';

  @override
  String get addFriendHint =>
      'Zoek op naam of e-mail. Kies iemand om een verzoek te sturen.';

  @override
  String get nameOrEmail => 'Naam of e-mail';

  @override
  String get clear => 'Wissen';

  @override
  String get typeAtLeast3 => 'Typ minstens 3 letters';

  @override
  String get noOneFound =>
      'Niemand gevonden. Probeer het volledige e-mailadres.';

  @override
  String sendRequestTo(String email) {
    return 'Verzoek sturen naar $email';
  }

  @override
  String get theyWillSeeIt => 'Ze zien het zodra ze Recipe App gebruiken';

  @override
  String get send => 'Sturen';

  @override
  String get requested => 'Gevraagd';

  @override
  String get add => 'Toevoegen';

  @override
  String get wantsToBeFriends => 'Wil vrienden worden';

  @override
  String get yourFriend => 'je vriend';

  @override
  String stepDone(int number, String text) {
    return 'Stap $number, klaar: $text';
  }

  @override
  String stepUpNext(int number, String text) {
    return 'Stap $number, nu aan de beurt: $text';
  }

  @override
  String shareTitle(String title) {
    return '\"$title\" delen';
  }

  @override
  String get shareRecipeExplanation =>
      'Vrienden die je kiest, kunnen dit recept zien en een eigen kopie bewaren. Alleen jij kunt het wijzigen.';

  @override
  String get savedToYourRecipes => 'Bewaard bij je recepten';

  @override
  String get open => 'Openen';

  @override
  String alsoInSharedCollection(String name) {
    return 'Het staat ook in een verzameling die $name met je deelt, dus daar blijft het staan.';
  }

  @override
  String removedFromYourList(String title) {
    return '\"$title\" uit je lijst verwijderd';
  }

  @override
  String get deleteRecipeQuestion => 'Dit recept verwijderen?';

  @override
  String deleteRecipeMessage(String title) {
    return '\"$title\" wordt uit je recepten en verzamelingen verwijderd. Dit kan niet ongedaan worden gemaakt.';
  }

  @override
  String get delete => 'Verwijderen';

  @override
  String deletedTitle(String title) {
    return '\"$title\" verwijderd';
  }

  @override
  String get recipeNotFound => 'Recept niet gevonden.';

  @override
  String get back => 'Terug';

  @override
  String get shareWithFriends => 'Delen met vrienden';

  @override
  String get edit => 'Bewerken';

  @override
  String get more => 'Meer';

  @override
  String get deleteRecipe => 'Recept verwijderen';

  @override
  String get removeFromMyList => 'Uit mijn lijst halen';

  @override
  String get aFriend => 'Een vriend';

  @override
  String get sharedRecipeBanner =>
      'Je ziet hun nieuwste versie. Bewaar een kopie om het naar jouw smaak aan te passen.';

  @override
  String get saveACopy => 'Kopie bewaren';

  @override
  String get prep => 'Voorwerk';

  @override
  String get cook => 'Koken';

  @override
  String get total => 'Totaal';

  @override
  String get serves => 'Personen';

  @override
  String get ingredients => 'Ingrediënten';

  @override
  String get clearTicks => 'Vinkjes wissen';

  @override
  String get noIngredientsYet => 'Nog geen ingrediënten toegevoegd.';

  @override
  String get steps => 'Stappen';

  @override
  String get startOver => 'Opnieuw beginnen';

  @override
  String get noStepsYet => 'Nog geen stappen toegevoegd.';

  @override
  String stepPlain(int number, String text) {
    return 'Stap $number: $text';
  }

  @override
  String addedIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingrediënten toegevoegd',
      one: '1 ingrediënt toegevoegd',
    );
    return '$_temp0';
  }

  @override
  String get discardChangesQuestion => 'Wijzigingen weggooien?';

  @override
  String get discardRecipeMessage =>
      'Wat je in dit recept hebt getypt, wordt niet bewaard.';

  @override
  String get discard => 'Weggooien';

  @override
  String get aboveZero => 'Meer dan 0';

  @override
  String get close => 'Sluiten';

  @override
  String get editRecipe => 'Recept bewerken';

  @override
  String get newRecipe => 'Nieuw recept';

  @override
  String get couldNotLoad => 'Kon dit niet laden.';

  @override
  String get saveChanges => 'Wijzigingen bewaren';

  @override
  String get saveRecipe => 'Recept bewaren';

  @override
  String get giveRecipeName => 'Geef je recept een naam';

  @override
  String get recipeName => 'Naam van het recept';

  @override
  String get recipeNameExample => 'Luchtige pannenkoeken';

  @override
  String get shortDescription => 'Korte beschrijving';

  @override
  String get shortDescriptionExample => 'Klassieker voor de zondagochtend';

  @override
  String get timeAndServings => 'Tijd en personen';

  @override
  String get minutesShort => 'min';

  @override
  String get dragToReorderHint =>
      'Sleep aan het handvat om de volgorde te veranderen.';

  @override
  String get addIngredient => 'Ingrediënt toevoegen';

  @override
  String get pasteAList => 'Lijst plakken';

  @override
  String get stepsExample =>
      'Klop de bloem, melk en eieren glad.\nLaat het beslag 10 minuten rusten.';

  @override
  String get stepsHelper => 'Eén stap per regel. Ze worden voor je genummerd.';

  @override
  String get ingredient => 'Ingrediënt';

  @override
  String get amount => 'Hoeveelheid';

  @override
  String get unit => 'Eenheid';

  @override
  String get dragToReorder => 'Sleep om te verplaatsen';

  @override
  String get removeIngredient => 'Ingrediënt verwijderen';

  @override
  String get shareCollectionExplanation =>
      'Vrienden die je kiest, kunnen deze verzameling en elk recept erin zien, ook recepten die je later toevoegt. Alleen jij kunt hem wijzigen.';

  @override
  String get deleteCollectionQuestion => 'Deze verzameling verwijderen?';

  @override
  String deleteCollectionMessage(String name) {
    return '\"$name\" wordt verwijderd. De recepten erin blijven bewaard.';
  }

  @override
  String removedFromCollection(String title) {
    return '\"$title\" uit deze verzameling gehaald';
  }

  @override
  String get undo => 'Ongedaan maken';

  @override
  String addedRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recepten toegevoegd',
      one: '1 recept toegevoegd',
    );
    return '$_temp0';
  }

  @override
  String get addSomeRecipesFirst => 'Voeg eerst wat recepten toe.';

  @override
  String get allRecipesAlreadyIn =>
      'Al je recepten staan al in deze verzameling.';

  @override
  String get deleteCollection => 'Verzameling verwijderen';

  @override
  String get collectionNotFound => 'Verzameling niet gevonden.';

  @override
  String get sharedCollectionBanner =>
      'Recepten die ze later toevoegen, verschijnen hier ook. Open er een om een kopie te bewaren.';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recepten',
      one: '1 recept',
    );
    return '$_temp0';
  }

  @override
  String get nothingHereYet => 'Hier staat nog niets';

  @override
  String get pickRecipesToAdd =>
      'Kies recepten om aan deze verzameling toe te voegen.';

  @override
  String friendAddsShowUp(String name) {
    return 'Recepten die $name toevoegt, verschijnen hier.';
  }

  @override
  String get addRecipes => 'Recepten toevoegen';

  @override
  String get removeFromCollection => 'Uit verzameling halen';

  @override
  String get searchRecipes => 'Recepten zoeken';

  @override
  String get selectRecipes => 'Kies recepten';

  @override
  String addNRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recepten toevoegen',
      one: '1 recept toevoegen',
    );
    return '$_temp0';
  }

  @override
  String get goodMorning => 'Goedemorgen';

  @override
  String get goodAfternoon => 'Goedemiddag';

  @override
  String get goodEvening => 'Goedenavond';

  @override
  String fromName(String name) {
    return 'Van $name';
  }

  @override
  String collectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verzamelingen',
      one: '1 verzameling',
    );
    return '$_temp0';
  }

  @override
  String get aFriendLower => 'een vriend';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get addFirstRecipe => 'Voeg je eerste recept toe';

  @override
  String get addFirstRecipeMessage =>
      'Bewaar de gerechten waar je van houdt, met ingrediënten en stappen, en vind ze in een paar seconden terug.';

  @override
  String get yourRecipes => 'Je recepten';

  @override
  String get sort => 'Sorteren';

  @override
  String get newestFirst => 'Nieuwste eerst';

  @override
  String get aToZ => 'A tot Z';

  @override
  String get quickestFirst => 'Snelste eerst';

  @override
  String searchNRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zoek in $count recepten of ingrediënten',
      one: 'Zoek in 1 recept of ingrediënten',
    );
    return '$_temp0';
  }

  @override
  String get clearSearch => 'Zoekopdracht wissen';

  @override
  String get noMatches => 'Geen resultaten';

  @override
  String nothingFits(String filters) {
    return 'Niets past bij \"$filters\". Probeer een ander filter, of toon alle recepten.';
  }

  @override
  String get tryAnotherWord =>
      'Probeer een ander woord, of toon alle recepten.';

  @override
  String get showAll => 'Alles tonen';

  @override
  String deletedCollectionKept(String name) {
    return '\"$name\" verwijderd. De recepten blijven bewaard.';
  }

  @override
  String get newCollection => 'Nieuwe verzameling';

  @override
  String get groupYourRecipes => 'Groepeer je recepten';

  @override
  String get groupYourRecipesMessage =>
      'Maak verzamelingen zoals \"Doordeweekse avonden\" of \"Bakken\" om recepten sneller te vinden.';

  @override
  String get yourCollections => 'Je verzamelingen';

  @override
  String get sharedWithYou => 'Met jou gedeeld';

  @override
  String get empty => 'Leeg';

  @override
  String get discardMessage => 'Wat je hebt getypt, wordt niet bewaard.';

  @override
  String get editCollection => 'Verzameling bewerken';

  @override
  String get giveCollectionName => 'Geef je verzameling een naam';

  @override
  String get name => 'Naam';

  @override
  String get collectionNameExample => 'Doordeweekse avonden';

  @override
  String get description => 'Beschrijving';

  @override
  String get collectionDescriptionExample =>
      'Snelle maaltijden voor drukke avonden';

  @override
  String get createCollection => 'Verzameling maken';

  @override
  String get signInToAccount => 'Log in op je account';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Wachtwoord';

  @override
  String get signIn => 'Inloggen';

  @override
  String get newHereCreateAccount => 'Nieuw hier? Maak een account';

  @override
  String get enterFirstName => 'Vul je voornaam in';

  @override
  String get createYourAccount => 'Maak je account';

  @override
  String checkEmailMessage(String email) {
    return 'Bijna klaar! We hebben een bevestigingslink gestuurd naar $email. Open die en log dan in.';
  }

  @override
  String get goToSignIn => 'Naar inloggen';

  @override
  String get firstName => 'Voornaam';

  @override
  String get lastName => 'Achternaam';

  @override
  String get nameShownHint =>
      'Zichtbaar voor je vrienden; je logt in met je e-mail';

  @override
  String get atLeast6 => 'Minstens 6 tekens';

  @override
  String get createAccount => 'Account maken';

  @override
  String get alreadyHaveAccount => 'Heb je al een account? Log in';

  @override
  String get detailsSaved => 'Je gegevens zijn bewaard';

  @override
  String get yourDetails => 'Je gegevens';

  @override
  String get lastNameOptional => 'Achternaam (optioneel)';

  @override
  String get friendsSeeName =>
      'Je vrienden zien deze naam als je recepten deelt of verzoeken stuurt.';

  @override
  String get emailCantChange =>
      'Je logt in met dit adres. Het kan hier niet worden gewijzigd.';

  @override
  String get save => 'Bewaren';

  @override
  String get pageNotFound => 'Pagina niet gevonden';

  @override
  String get pageNotFoundMessage =>
      'Deze link leidt nergens heen. Misschien is het recept verwijderd.';

  @override
  String get goToYourRecipes => 'Naar je recepten';

  @override
  String hoursMinutesValue(int hours, int minutes) {
    return '$hours u $minutes min';
  }

  @override
  String minutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String hoursValue(int hours) {
    return '$hours u';
  }

  @override
  String servesN(int count) {
    return '$count personen';
  }

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingrediënten',
      one: '1 ingrediënt',
    );
    return '$_temp0';
  }

  @override
  String sharedBy(String name) {
    return 'Gedeeld door $name';
  }

  @override
  String get pasteIngredients => 'Ingrediënten plakken';

  @override
  String get pasteIngredientsHint =>
      'Eén per regel, zoals \"200 g bloem\" of \"2 eieren\". Opsommingstekens, nummers en kopjes worden overgeslagen.';

  @override
  String get pasteIngredientsExample =>
      '200 g bloem\n300 ml melk\n2 eieren\nSnufje zout';

  @override
  String get pasteFromClipboard => 'Plakken van klembord';

  @override
  String weFoundIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingrediënten gevonden',
      one: '1 ingrediënt gevonden',
    );
    return '$_temp0';
  }

  @override
  String addN(int count) {
    return '$count toevoegen';
  }

  @override
  String get noLongerShared => 'Niet meer gedeeld';

  @override
  String sharedWithN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gedeeld met $count vrienden',
      one: 'Gedeeld met 1 vriend',
    );
    return '$_temp0';
  }

  @override
  String get noFriendsAddedYet => 'Je hebt nog geen vrienden toegevoegd.';

  @override
  String get addFriends => 'Vrienden toevoegen';

  @override
  String get done => 'Klaar';

  @override
  String get anyTime => 'Elke tijd';

  @override
  String get under30Min => 'Onder 30 min';

  @override
  String get under1Hour => 'Onder 1 uur';

  @override
  String get oneHourOrMore => '1 uur of langer';

  @override
  String get all => 'Alle';

  @override
  String get mine => 'Van mij';

  @override
  String get sharedWithMe => 'Met mij gedeeld';

  @override
  String get recipes => 'Recepten';

  @override
  String get collections => 'Verzamelingen';

  @override
  String friendRequestsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vriendschapsverzoeken wachten',
      one: '1 vriendschapsverzoek wacht',
    );
    return '$_temp0';
  }

  @override
  String get errorOffline =>
      'Geen verbinding. Controleer je internet en probeer het opnieuw.';

  @override
  String get errorWrongPassword => 'Verkeerd e-mailadres of wachtwoord.';

  @override
  String get errorConfirmEmailFirst =>
      'Bevestig eerst je e-mailadres: open de link die we je hebben gestuurd.';

  @override
  String get errorAccountExists =>
      'Er bestaat al een account met dit e-mailadres. Log in.';

  @override
  String get errorPasswordTooShort =>
      'Je wachtwoord moet minstens 6 tekens hebben.';

  @override
  String get errorTooManyAttempts =>
      'Te veel pogingen. Wacht een paar minuten en probeer het opnieuw.';

  @override
  String get errorGeneric => 'Er ging iets mis. Probeer het opnieuw.';

  @override
  String get errorOwnEmail => 'Dat is je eigen e-mailadres.';

  @override
  String get errorNotAnEmail => 'Dat lijkt geen e-mailadres.';

  @override
  String get errorTooManyOpenRequests =>
      'Je hebt 50 openstaande verzoeken. Wacht eerst op een paar antwoorden.';

  @override
  String get errorRecipeLimit =>
      'Je hebt 2.000 recepten, het maximum voor één account.';

  @override
  String get errorCollectionLimit =>
      'Je hebt 300 verzamelingen, het maximum voor één account.';

  @override
  String get errorIngredientLimit =>
      'Een recept kan maximaal 200 ingrediënten hebben.';

  @override
  String get errorSlowDown => 'Rustig aan, probeer het straks opnieuw.';

  @override
  String get errorNotFound => 'Niet gevonden. Misschien is het verwijderd.';

  @override
  String get errorCheckValues =>
      'Controleer de waarden: tijden en personen moeten boven 0 liggen, en een titel is verplicht.';

  @override
  String get errorForbidden => 'Dat mag je niet doen.';

  @override
  String get errorSessionExpired => 'Je sessie is verlopen. Log opnieuw in.';

  @override
  String get confirmLinkFailed =>
      'Die bevestigingslink werkte hier niet (misschien is hij verlopen of in een andere browser geopend). Je e-mail is mogelijk toch bevestigd: probeer in te loggen.';

  @override
  String get signInProblem =>
      'Er ging iets mis met inloggen. Probeer het opnieuw.';

  @override
  String get couldNotSignIn => 'Inloggen lukte niet. Probeer het opnieuw.';

  @override
  String get couldNotCreateAccount =>
      'Het account kon niet worden gemaakt. Probeer het opnieuw.';

  @override
  String get couldNotSaveName =>
      'Je naam kon niet worden bewaard. Probeer het opnieuw.';

  @override
  String get failedLoadRecipes => 'Recepten laden mislukt.';

  @override
  String get failedLoadRecipe => 'Het recept laden mislukt.';

  @override
  String get failedSaveRecipe => 'Recept bewaren mislukt.';

  @override
  String get onlyOwnerCanChange =>
      'Alleen de eigenaar kan dit recept wijzigen.';

  @override
  String get couldNotSaveCopy => 'Kon geen kopie bewaren.';

  @override
  String get failedDeleteRecipe => 'Recept verwijderen mislukt.';

  @override
  String get failedLoadCollections => 'Verzamelingen laden mislukt.';

  @override
  String get failedLoadCollection => 'De verzameling laden mislukt.';

  @override
  String get failedSaveCollection => 'De verzameling bewaren mislukt.';

  @override
  String get failedDeleteCollection => 'De verzameling verwijderen mislukt.';

  @override
  String get failedAddRecipes => 'Recepten toevoegen mislukt.';

  @override
  String get failedRemoveRecipe => 'Het recept eruit halen mislukt.';

  @override
  String get failedLoadFriends => 'Je vrienden laden mislukt.';

  @override
  String get failedLoadRequests => 'Vriendschapsverzoeken laden mislukt.';

  @override
  String get failedLoadSent => 'Je verstuurde verzoeken laden mislukt.';

  @override
  String get searchNotWorking => 'Zoeken werkt nu even niet.';

  @override
  String get couldNotSendRequest =>
      'Het verzoek kon niet worden gestuurd. Probeer het opnieuw.';

  @override
  String get couldNotAccept => 'Het verzoek kon niet worden geaccepteerd.';

  @override
  String get couldNotRemoveRequest => 'Het verzoek kon niet worden verwijderd.';

  @override
  String get couldNotRemoveFriend => 'Deze vriend kon niet worden verwijderd.';

  @override
  String get failedLoadShares => 'Laden met wie dit gedeeld is mislukt.';

  @override
  String get couldNotUpdateSharing =>
      'Delen kon niet worden bijgewerkt. Probeer het opnieuw.';

  @override
  String get shareOnlyOwn =>
      'Je kunt alleen je eigen recepten en verzamelingen delen, en alleen met vrienden.';

  @override
  String get couldNotRemoveIt =>
      'Kon het niet verwijderen. Probeer het opnieuw.';

  @override
  String get cookTab => 'Koken';

  @override
  String get whatCanICook => 'Wat kan ik koken?';

  @override
  String get whatCanICookHint =>
      'Voeg toe wat je in huis hebt en krijg drie maaltijdideeën. Zout, olie, bloem en kruiden tellen als aanwezig.';

  @override
  String get addWhatYouHave => 'Voeg toe wat je hebt';

  @override
  String get addWhatYouHaveExample => 'eieren, tomaten, rijst';

  @override
  String get nothingAddedYet =>
      'Nog niets toegevoegd. Typ één ding, of meerdere gescheiden door komma\'s.';

  @override
  String removeItem(String item) {
    return '$item verwijderen';
  }

  @override
  String get clearAll => 'Alles wissen';

  @override
  String get suggestMeals => 'Stel maaltijden voor';

  @override
  String get suggestOtherMeals => 'Andere maaltijden';

  @override
  String get thinkingUpMeals => 'Maaltijden bedenken…';

  @override
  String get pickAMeal => 'Kies een maaltijd';

  @override
  String get youHaveEverything => 'Je hebt alles in huis';

  @override
  String youdNeed(String items) {
    return 'Nog nodig: $items';
  }

  @override
  String get youHaveThis => 'Heb je in huis';

  @override
  String get toBuy => 'Nog kopen';

  @override
  String get saveToMyRecipes => 'Bewaar in mijn recepten';

  @override
  String get aiCheckNote =>
      'Geschreven door AI: controleer hoeveelheden, tijden en allergenen voor je gaat koken.';

  @override
  String get writeStepsWithAi => 'Schrijf de stappen met AI';

  @override
  String get writingSteps => 'Stappen schrijven…';

  @override
  String get stepsWritten =>
      'Stappen geschreven. Lees ze na en pas aan wat je wilt voor je opslaat.';

  @override
  String get aiNeedsNameAndIngredients =>
      'Voeg eerst een receptnaam en minstens één ingrediënt toe.';

  @override
  String get replaceStepsQuestion => 'Je stappen vervangen?';

  @override
  String get replaceStepsMessage =>
      'De AI schrijft nieuwe stappen in plaats van die je nu hebt.';

  @override
  String get replace => 'Vervangen';

  @override
  String aiLeftToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nog $count AI-verzoeken vandaag',
      one: 'Nog 1 AI-verzoek vandaag',
      zero: 'Vandaag geen AI-verzoeken meer',
    );
    return '$_temp0';
  }

  @override
  String get aiDailyLimit =>
      'Je hebt de 20 AI-verzoeken van vandaag gebruikt. Probeer het morgen weer.';

  @override
  String get aiBusy =>
      'De gratis AI is nu druk. Probeer het over een minuut; dit verzoek telde niet mee.';

  @override
  String get aiNotSetUp => 'De AI-hulp is nog niet ingesteld.';

  @override
  String get aiFailed =>
      'De AI kon nu geen antwoord geven. Probeer het opnieuw; dit verzoek telde niet mee.';
}
