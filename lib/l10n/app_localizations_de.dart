// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Recipe App';

  @override
  String get language => 'Sprache';

  @override
  String get languageAutomatic => 'Automatisch';

  @override
  String languageAutomaticHint(String language) {
    return 'Wie dein Telefon ($language)';
  }

  @override
  String get chooseLanguage => 'Sprache wählen';

  @override
  String get signOutQuestion => 'Abmelden?';

  @override
  String get signOutMessage =>
      'Deine Rezepte bleiben in deinem Konto gespeichert.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get signOut => 'Abmelden';

  @override
  String get account => 'Konto';

  @override
  String get editYourDetails => 'Deine Angaben bearbeiten';

  @override
  String get friends => 'Freunde';

  @override
  String get friendsSubtitle => 'Freunde hinzufügen und Anfragen beantworten';

  @override
  String get appearance => 'Darstellung';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeAutoHint => 'Auto folgt der Einstellung deines Geräts.';

  @override
  String removeFriendQuestion(String name) {
    return '$name entfernen?';
  }

  @override
  String get removeFriendMessage =>
      'Ihr seht dann die geteilten Rezepte und Sammlungen des anderen nicht mehr. Du kannst später eine neue Anfrage senden.';

  @override
  String get remove => 'Entfernen';

  @override
  String removedName(String name) {
    return '$name entfernt';
  }

  @override
  String someListsFailed(String details) {
    return 'Nicht alle Listen wurden geladen. $details';
  }

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get waitingForYou => 'Wartet auf dich';

  @override
  String get wantsToBeFriendsShort => 'möchte befreundet sein';

  @override
  String get declined => 'Abgelehnt';

  @override
  String get decline => 'Ablehnen';

  @override
  String nowFriends(String name) {
    return 'Du und $name seid jetzt befreundet';
  }

  @override
  String get accept => 'Annehmen';

  @override
  String get yourFriends => 'Deine Freunde';

  @override
  String get noFriendsYet =>
      'Noch keine Freunde. Sende oben eine Anfrage und teile Rezepte über die Teilen-Taste eines Rezepts.';

  @override
  String moreFor(String name) {
    return 'Mehr für $name';
  }

  @override
  String get removeFriend => 'Freund entfernen';

  @override
  String get requestsYouSent => 'Deine gesendeten Anfragen';

  @override
  String sentWaiting(String label) {
    return '$label · wartet auf Antwort';
  }

  @override
  String get waitingForAnswer => 'Wartet auf Antwort';

  @override
  String get requestCancelled => 'Anfrage zurückgezogen';

  @override
  String requestSentTo(String name) {
    return 'Anfrage an $name gesendet';
  }

  @override
  String requestSentToEmail(String email) {
    return 'Anfrage an $email gesendet. Wenn die Person Recipe App nutzt, sieht sie sie.';
  }

  @override
  String get addAFriend => 'Freund hinzufügen';

  @override
  String get addFriendHint =>
      'Suche nach Name oder E-Mail. Wähle jemanden aus, um eine Anfrage zu senden.';

  @override
  String get nameOrEmail => 'Name oder E-Mail';

  @override
  String get clear => 'Löschen';

  @override
  String get typeAtLeast3 => 'Mindestens 3 Buchstaben eingeben';

  @override
  String get noOneFound =>
      'Niemand gefunden. Versuche die vollständige E-Mail-Adresse.';

  @override
  String sendRequestTo(String email) {
    return 'Anfrage an $email senden';
  }

  @override
  String get theyWillSeeIt => 'Sie sehen es, sobald sie Recipe App nutzen';

  @override
  String get send => 'Senden';

  @override
  String get requested => 'Angefragt';

  @override
  String get add => 'Hinzufügen';

  @override
  String get wantsToBeFriends => 'Möchte befreundet sein';

  @override
  String get yourFriend => 'dein Freund';

  @override
  String stepDone(int number, String text) {
    return 'Schritt $number, erledigt: $text';
  }

  @override
  String stepUpNext(int number, String text) {
    return 'Schritt $number, als Nächstes: $text';
  }

  @override
  String shareTitle(String title) {
    return '„$title“ teilen';
  }

  @override
  String get shareRecipeExplanation =>
      'Freunde, die du auswählst, können dieses Rezept sehen und eine eigene Kopie speichern. Nur du kannst es ändern.';

  @override
  String get savedToYourRecipes => 'In deinen Rezepten gespeichert';

  @override
  String get open => 'Öffnen';

  @override
  String alsoInSharedCollection(String name) {
    return 'Es ist auch in einer Sammlung, die $name mit dir teilt, und bleibt deshalb dort.';
  }

  @override
  String removedFromYourList(String title) {
    return '„$title“ aus deiner Liste entfernt';
  }

  @override
  String get deleteRecipeQuestion => 'Dieses Rezept löschen?';

  @override
  String deleteRecipeMessage(String title) {
    return '„$title“ wird aus deinen Rezepten und Sammlungen entfernt. Das kann nicht rückgängig gemacht werden.';
  }

  @override
  String get delete => 'Löschen';

  @override
  String deletedTitle(String title) {
    return '„$title“ gelöscht';
  }

  @override
  String get recipeNotFound => 'Rezept nicht gefunden.';

  @override
  String get back => 'Zurück';

  @override
  String get shareWithFriends => 'Mit Freunden teilen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get more => 'Mehr';

  @override
  String get deleteRecipe => 'Rezept löschen';

  @override
  String get removeFromMyList => 'Aus meiner Liste entfernen';

  @override
  String get aFriend => 'Ein Freund';

  @override
  String get sharedRecipeBanner =>
      'Du siehst ihre neueste Version. Speichere eine Kopie, um es nach deinem Geschmack zu ändern.';

  @override
  String get saveACopy => 'Kopie speichern';

  @override
  String get prep => 'Vorbereiten';

  @override
  String get cook => 'Kochen';

  @override
  String get total => 'Gesamt';

  @override
  String get serves => 'Portionen';

  @override
  String get ingredients => 'Zutaten';

  @override
  String get clearTicks => 'Häkchen entfernen';

  @override
  String get noIngredientsYet => 'Noch keine Zutaten hinzugefügt.';

  @override
  String get steps => 'Schritte';

  @override
  String get startOver => 'Von vorn';

  @override
  String get noStepsYet => 'Noch keine Schritte hinzugefügt.';

  @override
  String stepPlain(int number, String text) {
    return 'Schritt $number: $text';
  }

  @override
  String addedIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zutaten hinzugefügt',
      one: '1 Zutat hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String get discardChangesQuestion => 'Änderungen verwerfen?';

  @override
  String get discardRecipeMessage =>
      'Was du in diesem Rezept eingegeben hast, wird nicht gespeichert.';

  @override
  String get discard => 'Verwerfen';

  @override
  String get aboveZero => 'Über 0';

  @override
  String get close => 'Schließen';

  @override
  String get editRecipe => 'Rezept bearbeiten';

  @override
  String get newRecipe => 'Neues Rezept';

  @override
  String get couldNotLoad => 'Konnte nicht geladen werden.';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get saveRecipe => 'Rezept speichern';

  @override
  String get giveRecipeName => 'Gib deinem Rezept einen Namen';

  @override
  String get recipeName => 'Name des Rezepts';

  @override
  String get recipeNameExample => 'Fluffige Pfannkuchen';

  @override
  String get shortDescription => 'Kurzbeschreibung';

  @override
  String get shortDescriptionExample => 'Sonntagsfrühstück-Klassiker';

  @override
  String get timeAndServings => 'Zeit und Portionen';

  @override
  String get minutesShort => 'Min.';

  @override
  String get dragToReorderHint =>
      'Ziehe am Griff, um die Reihenfolge zu ändern.';

  @override
  String get addIngredient => 'Zutat hinzufügen';

  @override
  String get pasteAList => 'Liste einfügen';

  @override
  String get stepsExample =>
      'Mehl, Milch und Eier glatt rühren.\nDen Teig 10 Minuten ruhen lassen.';

  @override
  String get stepsHelper =>
      'Ein Schritt pro Zeile. Sie werden für dich nummeriert.';

  @override
  String get ingredient => 'Zutat';

  @override
  String get amount => 'Menge';

  @override
  String get unit => 'Einheit';

  @override
  String get dragToReorder => 'Zum Verschieben ziehen';

  @override
  String get removeIngredient => 'Zutat entfernen';

  @override
  String get shareCollectionExplanation =>
      'Freunde, die du auswählst, können diese Sammlung und jedes Rezept darin sehen, auch später hinzugefügte. Nur du kannst sie ändern.';

  @override
  String get deleteCollectionQuestion => 'Diese Sammlung löschen?';

  @override
  String deleteCollectionMessage(String name) {
    return '„$name“ wird gelöscht. Die Rezepte darin bleiben erhalten.';
  }

  @override
  String removedFromCollection(String title) {
    return '„$title“ aus dieser Sammlung entfernt';
  }

  @override
  String get undo => 'Rückgängig';

  @override
  String addedRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte hinzugefügt',
      one: '1 Rezept hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String get addSomeRecipesFirst => 'Füge zuerst ein paar Rezepte hinzu.';

  @override
  String get allRecipesAlreadyIn =>
      'Alle deine Rezepte sind schon in dieser Sammlung.';

  @override
  String get deleteCollection => 'Sammlung löschen';

  @override
  String get collectionNotFound => 'Sammlung nicht gefunden.';

  @override
  String get sharedCollectionBanner =>
      'Rezepte, die später hinzukommen, erscheinen hier auch. Öffne eines, um eine Kopie zu speichern.';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte',
      one: '1 Rezept',
    );
    return '$_temp0';
  }

  @override
  String get nothingHereYet => 'Hier ist noch nichts';

  @override
  String get pickRecipesToAdd => 'Wähle Rezepte für diese Sammlung aus.';

  @override
  String friendAddsShowUp(String name) {
    return 'Rezepte, die $name hinzufügt, erscheinen hier.';
  }

  @override
  String get addRecipes => 'Rezepte hinzufügen';

  @override
  String get removeFromCollection => 'Aus Sammlung entfernen';

  @override
  String get searchRecipes => 'Rezepte suchen';

  @override
  String get selectRecipes => 'Rezepte auswählen';

  @override
  String addNRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte hinzufügen',
      one: '1 Rezept hinzufügen',
    );
    return '$_temp0';
  }

  @override
  String get goodMorning => 'Guten Morgen';

  @override
  String get goodAfternoon => 'Guten Tag';

  @override
  String get goodEvening => 'Guten Abend';

  @override
  String fromName(String name) {
    return 'Von $name';
  }

  @override
  String collectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sammlungen',
      one: '1 Sammlung',
    );
    return '$_temp0';
  }

  @override
  String get aFriendLower => 'einem Freund';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get addFirstRecipe => 'Füge dein erstes Rezept hinzu';

  @override
  String get addFirstRecipeMessage =>
      'Speichere deine Lieblingsgerichte mit Zutaten und Schritten und finde sie in Sekunden wieder.';

  @override
  String get yourRecipes => 'Deine Rezepte';

  @override
  String get sort => 'Sortieren';

  @override
  String get newestFirst => 'Neueste zuerst';

  @override
  String get aToZ => 'A bis Z';

  @override
  String get quickestFirst => 'Schnellste zuerst';

  @override
  String searchNRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte oder Zutaten durchsuchen',
      one: '1 Rezept oder Zutaten durchsuchen',
    );
    return '$_temp0';
  }

  @override
  String get clearSearch => 'Suche löschen';

  @override
  String get noMatches => 'Keine Treffer';

  @override
  String nothingFits(String filters) {
    return 'Nichts passt zu „$filters“. Versuche einen anderen Filter oder zeige alle Rezepte.';
  }

  @override
  String get tryAnotherWord =>
      'Versuche ein anderes Wort oder zeige alle Rezepte.';

  @override
  String get showAll => 'Alle zeigen';

  @override
  String deletedCollectionKept(String name) {
    return '„$name“ gelöscht. Die Rezepte bleiben erhalten.';
  }

  @override
  String get newCollection => 'Neue Sammlung';

  @override
  String get groupYourRecipes => 'Ordne deine Rezepte';

  @override
  String get groupYourRecipesMessage =>
      'Erstelle Sammlungen wie „Unter der Woche“ oder „Backen“, um Rezepte schneller zu finden.';

  @override
  String get yourCollections => 'Deine Sammlungen';

  @override
  String get sharedWithYou => 'Mit dir geteilt';

  @override
  String get empty => 'Leer';

  @override
  String get discardMessage =>
      'Was du eingegeben hast, wird nicht gespeichert.';

  @override
  String get editCollection => 'Sammlung bearbeiten';

  @override
  String get giveCollectionName => 'Gib deiner Sammlung einen Namen';

  @override
  String get name => 'Name';

  @override
  String get collectionNameExample => 'Unter der Woche';

  @override
  String get description => 'Beschreibung';

  @override
  String get collectionDescriptionExample =>
      'Schnelle Gerichte für volle Abende';

  @override
  String get createCollection => 'Sammlung erstellen';

  @override
  String get signInToAccount => 'Melde dich bei deinem Konto an';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get signIn => 'Anmelden';

  @override
  String get newHereCreateAccount => 'Neu hier? Konto erstellen';

  @override
  String get enterFirstName => 'Gib deinen Vornamen ein';

  @override
  String get createYourAccount => 'Erstelle dein Konto';

  @override
  String checkEmailMessage(String email) {
    return 'Fast geschafft! Wir haben einen Bestätigungslink an $email gesendet. Öffne ihn und melde dich dann an.';
  }

  @override
  String get goToSignIn => 'Zur Anmeldung';

  @override
  String get firstName => 'Vorname';

  @override
  String get lastName => 'Nachname';

  @override
  String get nameShownHint =>
      'Für deine Freunde sichtbar; du meldest dich mit deiner E-Mail an';

  @override
  String get atLeast6 => 'Mindestens 6 Zeichen';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get alreadyHaveAccount => 'Schon ein Konto? Anmelden';

  @override
  String get detailsSaved => 'Deine Angaben sind gespeichert';

  @override
  String get yourDetails => 'Deine Angaben';

  @override
  String get lastNameOptional => 'Nachname (optional)';

  @override
  String get friendsSeeName =>
      'Deine Freunde sehen diesen Namen, wenn du Rezepte teilst oder Anfragen sendest.';

  @override
  String get emailCantChange =>
      'Du meldest dich mit dieser Adresse an. Sie kann hier nicht geändert werden.';

  @override
  String get save => 'Speichern';

  @override
  String get pageNotFound => 'Seite nicht gefunden';

  @override
  String get pageNotFoundMessage =>
      'Dieser Link führt nirgendwohin. Vielleicht wurde das Rezept gelöscht.';

  @override
  String get goToYourRecipes => 'Zu deinen Rezepten';

  @override
  String hoursMinutesValue(int hours, int minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String minutesValue(int minutes) {
    return '$minutes Min.';
  }

  @override
  String hoursValue(int hours) {
    return '$hours Std.';
  }

  @override
  String servesN(int count) {
    return '$count Portionen';
  }

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zutaten',
      one: '1 Zutat',
    );
    return '$_temp0';
  }

  @override
  String sharedBy(String name) {
    return 'Geteilt von $name';
  }

  @override
  String get pasteIngredients => 'Zutaten einfügen';

  @override
  String get pasteIngredientsHint =>
      'Eine pro Zeile, z. B. „200 g Mehl“ oder „2 Eier“. Aufzählungszeichen, Nummern und Überschriften werden ignoriert.';

  @override
  String get pasteIngredientsExample =>
      '200 g Mehl\n300 ml Milch\n2 Eier\nPrise Salz';

  @override
  String get pasteFromClipboard => 'Aus Zwischenablage einfügen';

  @override
  String weFoundIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zutaten gefunden',
      one: '1 Zutat gefunden',
    );
    return '$_temp0';
  }

  @override
  String addN(int count) {
    return '$count hinzufügen';
  }

  @override
  String get noLongerShared => 'Nicht mehr geteilt';

  @override
  String sharedWithN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mit $count Freunden geteilt',
      one: 'Mit 1 Freund geteilt',
    );
    return '$_temp0';
  }

  @override
  String get noFriendsAddedYet => 'Du hast noch keine Freunde hinzugefügt.';

  @override
  String get addFriends => 'Freunde hinzufügen';

  @override
  String get done => 'Fertig';

  @override
  String get anyTime => 'Beliebig';

  @override
  String get under30Min => 'Unter 30 Min.';

  @override
  String get under1Hour => 'Unter 1 Std.';

  @override
  String get oneHourOrMore => '1 Std. oder länger';

  @override
  String get all => 'Alle';

  @override
  String get mine => 'Meine';

  @override
  String get sharedWithMe => 'Mit mir geteilt';

  @override
  String get recipes => 'Rezepte';

  @override
  String get collections => 'Sammlungen';

  @override
  String friendRequestsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Freundschaftsanfragen warten',
      one: '1 Freundschaftsanfrage wartet',
    );
    return '$_temp0';
  }

  @override
  String get errorOffline =>
      'Keine Verbindung. Prüfe dein Internet und versuche es erneut.';

  @override
  String get errorWrongPassword => 'Falsche E-Mail oder falsches Passwort.';

  @override
  String get errorConfirmEmailFirst =>
      'Bestätige zuerst deine E-Mail: Öffne den Link, den wir dir geschickt haben.';

  @override
  String get errorAccountExists =>
      'Mit dieser E-Mail gibt es schon ein Konto. Melde dich stattdessen an.';

  @override
  String get errorPasswordTooShort =>
      'Dein Passwort braucht mindestens 6 Zeichen.';

  @override
  String get errorTooManyAttempts =>
      'Zu viele Versuche. Warte ein paar Minuten und versuche es erneut.';

  @override
  String get errorGeneric =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get errorOwnEmail => 'Das ist deine eigene E-Mail-Adresse.';

  @override
  String get errorNotAnEmail => 'Das sieht nicht wie eine E-Mail-Adresse aus.';

  @override
  String get errorTooManyOpenRequests =>
      'Du hast 50 offene Anfragen. Warte zuerst auf ein paar Antworten.';

  @override
  String get errorRecipeLimit =>
      'Du hast 2.000 Rezepte erreicht, das Maximum für ein Konto.';

  @override
  String get errorCollectionLimit =>
      'Du hast 300 Sammlungen erreicht, das Maximum für ein Konto.';

  @override
  String get errorIngredientLimit =>
      'Ein Rezept kann höchstens 200 Zutaten haben.';

  @override
  String get errorSlowDown =>
      'Etwas langsamer bitte, versuche es später erneut.';

  @override
  String get errorNotFound => 'Nicht gefunden. Vielleicht wurde es gelöscht.';

  @override
  String get errorCheckValues =>
      'Bitte prüfe die Werte: Zeiten und Portionen müssen über 0 liegen, und ein Titel ist nötig.';

  @override
  String get errorForbidden => 'Dazu hast du keine Berechtigung.';

  @override
  String get errorSessionExpired =>
      'Deine Sitzung ist abgelaufen. Bitte melde dich erneut an.';

  @override
  String get confirmLinkFailed =>
      'Dieser Bestätigungslink hat hier nicht funktioniert (vielleicht ist er abgelaufen oder wurde in einem anderen Browser geöffnet). Deine E-Mail ist eventuell trotzdem bestätigt: Versuche dich anzumelden.';

  @override
  String get signInProblem =>
      'Bei der Anmeldung ist etwas schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get couldNotSignIn =>
      'Anmeldung fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get couldNotCreateAccount =>
      'Das Konto konnte nicht erstellt werden. Bitte versuche es erneut.';

  @override
  String get couldNotSaveName =>
      'Dein Name konnte nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get failedLoadRecipes => 'Rezepte konnten nicht geladen werden.';

  @override
  String get failedLoadRecipe => 'Das Rezept konnte nicht geladen werden.';

  @override
  String get failedSaveRecipe => 'Das Rezept konnte nicht gespeichert werden.';

  @override
  String get onlyOwnerCanChange =>
      'Nur der Besitzer kann dieses Rezept ändern.';

  @override
  String get couldNotSaveCopy => 'Die Kopie konnte nicht gespeichert werden.';

  @override
  String get failedDeleteRecipe => 'Das Rezept konnte nicht gelöscht werden.';

  @override
  String get failedLoadCollections =>
      'Sammlungen konnten nicht geladen werden.';

  @override
  String get failedLoadCollection =>
      'Die Sammlung konnte nicht geladen werden.';

  @override
  String get failedSaveCollection =>
      'Die Sammlung konnte nicht gespeichert werden.';

  @override
  String get failedDeleteCollection =>
      'Die Sammlung konnte nicht gelöscht werden.';

  @override
  String get failedAddRecipes => 'Rezepte konnten nicht hinzugefügt werden.';

  @override
  String get failedRemoveRecipe => 'Das Rezept konnte nicht entfernt werden.';

  @override
  String get failedLoadFriends => 'Deine Freunde konnten nicht geladen werden.';

  @override
  String get failedLoadRequests =>
      'Freundschaftsanfragen konnten nicht geladen werden.';

  @override
  String get failedLoadSent =>
      'Deine gesendeten Anfragen konnten nicht geladen werden.';

  @override
  String get searchNotWorking => 'Die Suche funktioniert gerade nicht.';

  @override
  String get couldNotSendRequest =>
      'Die Anfrage konnte nicht gesendet werden. Bitte versuche es erneut.';

  @override
  String get couldNotAccept => 'Die Anfrage konnte nicht angenommen werden.';

  @override
  String get couldNotRemoveRequest =>
      'Die Anfrage konnte nicht entfernt werden.';

  @override
  String get couldNotRemoveFriend =>
      'Dieser Freund konnte nicht entfernt werden.';

  @override
  String get failedLoadShares =>
      'Es konnte nicht geladen werden, mit wem das geteilt ist.';

  @override
  String get couldNotUpdateSharing =>
      'Das Teilen konnte nicht aktualisiert werden. Bitte versuche es erneut.';

  @override
  String get shareOnlyOwn =>
      'Du kannst nur deine eigenen Rezepte und Sammlungen teilen, und nur mit Freunden.';

  @override
  String get couldNotRemoveIt =>
      'Konnte nicht entfernt werden. Bitte versuche es erneut.';

  @override
  String get cookTab => 'Kochen';

  @override
  String get whatCanICook => 'Was kann ich kochen?';

  @override
  String get whatCanICookHint =>
      'Füge hinzu, was du zu Hause hast, und bekomme drei Essensideen. Salz, Öl, Mehl und Gewürze zählen als vorhanden.';

  @override
  String get addWhatYouHave => 'Füge hinzu, was du hast';

  @override
  String get addWhatYouHaveExample => 'Eier, Tomaten, Reis';

  @override
  String get nothingAddedYet =>
      'Noch nichts hinzugefügt. Tippe eine Zutat oder mehrere, durch Kommas getrennt.';

  @override
  String removeItem(String item) {
    return '$item entfernen';
  }

  @override
  String get clearAll => 'Alles löschen';

  @override
  String get suggestMeals => 'Gerichte vorschlagen';

  @override
  String get suggestOtherMeals => 'Andere Gerichte vorschlagen';

  @override
  String get thinkingUpMeals => 'Gerichte werden ausgedacht…';

  @override
  String get pickAMeal => 'Wähle ein Gericht';

  @override
  String get youHaveEverything => 'Du hast alles da';

  @override
  String youdNeed(String items) {
    return 'Du brauchst noch: $items';
  }

  @override
  String get youHaveThis => 'Hast du da';

  @override
  String get toBuy => 'Noch kaufen';

  @override
  String get saveToMyRecipes => 'In meinen Rezepten speichern';

  @override
  String get aiCheckNote =>
      'Von KI geschrieben: Prüfe Mengen, Zeiten und Allergene, bevor du kochst.';

  @override
  String get writeStepsWithAi => 'Schritte mit KI schreiben';

  @override
  String get writingSteps => 'Schritte werden geschrieben…';

  @override
  String get stepsWritten =>
      'Schritte geschrieben. Lies sie durch und ändere, was du willst, bevor du speicherst.';

  @override
  String get aiNeedsNameAndIngredients =>
      'Gib zuerst einen Rezeptnamen und mindestens eine Zutat ein.';

  @override
  String get replaceStepsQuestion => 'Deine Schritte ersetzen?';

  @override
  String get replaceStepsMessage =>
      'Die KI schreibt neue Schritte anstelle deiner jetzigen.';

  @override
  String get replace => 'Ersetzen';

  @override
  String aiLeftToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Heute noch $count KI-Anfragen',
      one: 'Heute noch 1 KI-Anfrage',
      zero: 'Heute keine KI-Anfragen mehr',
    );
    return '$_temp0';
  }

  @override
  String get aiDailyLimit =>
      'Du hast die 20 KI-Anfragen für heute verbraucht. Versuch es morgen wieder.';

  @override
  String get aiBusy =>
      'Die kostenlose KI ist gerade ausgelastet. Versuch es in einer Minute; diese Anfrage zählt nicht.';

  @override
  String get aiNotSetUp => 'Die KI-Hilfe ist noch nicht eingerichtet.';

  @override
  String get aiFailed =>
      'Die KI konnte diesmal nicht antworten. Versuch es noch einmal; diese Anfrage zählt nicht.';
}
