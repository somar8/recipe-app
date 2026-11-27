// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Recipe App';

  @override
  String get language => 'اللغة';

  @override
  String get languageAutomatic => 'تلقائي';

  @override
  String languageAutomaticHint(String language) {
    return 'حسب هاتفك ($language)';
  }

  @override
  String get chooseLanguage => 'اختر لغة';

  @override
  String get signOutQuestion => 'تسجيل الخروج؟';

  @override
  String get signOutMessage => 'تبقى وصفاتك محفوظة في حسابك.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get account => 'الحساب';

  @override
  String get editYourDetails => 'تعديل بياناتك';

  @override
  String get friends => 'الأصدقاء';

  @override
  String get friendsSubtitle => 'أضف أصدقاء وردّ على الطلبات';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeAuto => 'تلقائي';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeAutoHint => 'الوضع التلقائي يتبع إعداد جهازك.';

  @override
  String removeFriendQuestion(String name) {
    return 'إزالة $name؟';
  }

  @override
  String get removeFriendMessage =>
      'لن يرى أيٌّ منكما وصفات ومجموعات الآخر المشتركة بعد الآن. يمكنك إرسال طلب جديد لاحقًا.';

  @override
  String get remove => 'إزالة';

  @override
  String removedName(String name) {
    return 'تمت إزالة $name';
  }

  @override
  String someListsFailed(String details) {
    return 'لم يتم تحميل بعض القوائم. $details';
  }

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get waitingForYou => 'بانتظار ردّك';

  @override
  String get wantsToBeFriendsShort => 'يريد أن يكون صديقك';

  @override
  String get declined => 'تم الرفض';

  @override
  String get decline => 'رفض';

  @override
  String nowFriends(String name) {
    return 'أنت و$name صديقان الآن';
  }

  @override
  String get accept => 'قبول';

  @override
  String get yourFriends => 'أصدقاؤك';

  @override
  String get noFriendsYet =>
      'لا أصدقاء بعد. أرسل طلبًا من الأعلى، ثم شارك الوصفات من زر المشاركة في أي وصفة.';

  @override
  String moreFor(String name) {
    return 'المزيد لـ $name';
  }

  @override
  String get removeFriend => 'إزالة الصديق';

  @override
  String get requestsYouSent => 'الطلبات التي أرسلتها';

  @override
  String sentWaiting(String label) {
    return '$label · بانتظار الرد';
  }

  @override
  String get waitingForAnswer => 'بانتظار الرد';

  @override
  String get requestCancelled => 'تم إلغاء الطلب';

  @override
  String requestSentTo(String name) {
    return 'تم إرسال الطلب إلى $name';
  }

  @override
  String requestSentToEmail(String email) {
    return 'تم إرسال الطلب إلى $email. إذا كان يستخدم Recipe App فسيراه.';
  }

  @override
  String get addAFriend => 'أضف صديقًا';

  @override
  String get addFriendHint =>
      'ابحث بالاسم أو البريد الإلكتروني. اختر شخصًا لإرسال طلب.';

  @override
  String get nameOrEmail => 'الاسم أو البريد الإلكتروني';

  @override
  String get clear => 'مسح';

  @override
  String get typeAtLeast3 => 'اكتب 3 أحرف على الأقل';

  @override
  String get noOneFound => 'لم يُعثر على أحد. جرّب البريد الإلكتروني الكامل.';

  @override
  String sendRequestTo(String email) {
    return 'أرسل طلبًا إلى $email';
  }

  @override
  String get theyWillSeeIt => 'سيرونه عندما يستخدمون Recipe App';

  @override
  String get send => 'إرسال';

  @override
  String get requested => 'تم الطلب';

  @override
  String get add => 'إضافة';

  @override
  String get wantsToBeFriends => 'يريد أن يكون صديقك';

  @override
  String get yourFriend => 'صديقك';

  @override
  String stepDone(int number, String text) {
    return 'الخطوة $number، تمت: $text';
  }

  @override
  String stepUpNext(int number, String text) {
    return 'الخطوة $number، التالية: $text';
  }

  @override
  String shareTitle(String title) {
    return 'مشاركة «$title»';
  }

  @override
  String get shareRecipeExplanation =>
      'يمكن للأصدقاء الذين تختارهم رؤية هذه الوصفة وحفظ نسخة خاصة بهم. أنت وحدك يمكنك تعديلها.';

  @override
  String get savedToYourRecipes => 'حُفظت في وصفاتك';

  @override
  String get open => 'فتح';

  @override
  String alsoInSharedCollection(String name) {
    return 'إنها موجودة أيضًا في مجموعة شاركها $name معك، لذا ستبقى هناك.';
  }

  @override
  String removedFromYourList(String title) {
    return 'تمت إزالة «$title» من قائمتك';
  }

  @override
  String get deleteRecipeQuestion => 'حذف هذه الوصفة؟';

  @override
  String deleteRecipeMessage(String title) {
    return 'ستُحذف «$title» من وصفاتك ومجموعاتك. لا يمكن التراجع عن ذلك.';
  }

  @override
  String get delete => 'حذف';

  @override
  String deletedTitle(String title) {
    return 'تم حذف «$title»';
  }

  @override
  String get recipeNotFound => 'الوصفة غير موجودة.';

  @override
  String get back => 'رجوع';

  @override
  String get shareWithFriends => 'مشاركة مع الأصدقاء';

  @override
  String get edit => 'تعديل';

  @override
  String get more => 'المزيد';

  @override
  String get deleteRecipe => 'حذف الوصفة';

  @override
  String get removeFromMyList => 'إزالة من قائمتي';

  @override
  String get aFriend => 'صديق';

  @override
  String get sharedRecipeBanner =>
      'ترى أحدث نسخة لديهم. احفظ نسخة لتعدّلها على طريقتك.';

  @override
  String get saveACopy => 'حفظ نسخة';

  @override
  String get prep => 'التحضير';

  @override
  String get cook => 'الطهي';

  @override
  String get total => 'المجموع';

  @override
  String get serves => 'يكفي';

  @override
  String get ingredients => 'المكونات';

  @override
  String get clearTicks => 'مسح العلامات';

  @override
  String get noIngredientsYet => 'لم تُضف مكونات بعد.';

  @override
  String get steps => 'الخطوات';

  @override
  String get startOver => 'البدء من جديد';

  @override
  String get noStepsYet => 'لم تُضف خطوات بعد.';

  @override
  String stepPlain(int number, String text) {
    return 'الخطوة $number: $text';
  }

  @override
  String addedIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت إضافة $count مكوّن',
      many: 'تمت إضافة $count مكوّنًا',
      few: 'تمت إضافة $count مكونات',
      two: 'تمت إضافة مكوّنين',
      one: 'تمت إضافة مكوّن واحد',
    );
    return '$_temp0';
  }

  @override
  String get discardChangesQuestion => 'تجاهل التغييرات؟';

  @override
  String get discardRecipeMessage => 'لن يُحفظ ما كتبته في هذه الوصفة.';

  @override
  String get discard => 'تجاهل';

  @override
  String get aboveZero => 'أكبر من 0';

  @override
  String get close => 'إغلاق';

  @override
  String get editRecipe => 'تعديل الوصفة';

  @override
  String get newRecipe => 'وصفة جديدة';

  @override
  String get couldNotLoad => 'تعذّر تحميل هذا.';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get saveRecipe => 'حفظ الوصفة';

  @override
  String get giveRecipeName => 'أعطِ وصفتك اسمًا';

  @override
  String get recipeName => 'اسم الوصفة';

  @override
  String get recipeNameExample => 'فطائر هشة';

  @override
  String get shortDescription => 'وصف قصير';

  @override
  String get shortDescriptionExample => 'فطور يوم العطلة المفضّل';

  @override
  String get timeAndServings => 'الوقت وعدد الحصص';

  @override
  String get minutesShort => 'د';

  @override
  String get dragToReorderHint => 'اسحب المقبض لتغيير الترتيب.';

  @override
  String get addIngredient => 'إضافة مكوّن';

  @override
  String get pasteAList => 'لصق قائمة';

  @override
  String get stepsExample =>
      'اخفق الطحين والحليب والبيض حتى يصبح ناعمًا.\nاترك الخليط يرتاح 10 دقائق.';

  @override
  String get stepsHelper => 'خطوة واحدة في كل سطر. سنرقّمها لك.';

  @override
  String get ingredient => 'المكوّن';

  @override
  String get amount => 'الكمية';

  @override
  String get unit => 'الوحدة';

  @override
  String get dragToReorder => 'اسحب لإعادة الترتيب';

  @override
  String get removeIngredient => 'إزالة المكوّن';

  @override
  String get shareCollectionExplanation =>
      'يمكن للأصدقاء الذين تختارهم رؤية هذه المجموعة وكل وصفة فيها، بما في ذلك ما تضيفه لاحقًا. أنت وحدك يمكنك تعديلها.';

  @override
  String get deleteCollectionQuestion => 'حذف هذه المجموعة؟';

  @override
  String deleteCollectionMessage(String name) {
    return 'ستُحذف «$name». تبقى الوصفات التي فيها.';
  }

  @override
  String removedFromCollection(String title) {
    return 'تمت إزالة «$title» من هذه المجموعة';
  }

  @override
  String get undo => 'تراجع';

  @override
  String addedRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت إضافة $count وصفة',
      many: 'تمت إضافة $count وصفة',
      few: 'تمت إضافة $count وصفات',
      two: 'تمت إضافة وصفتين',
      one: 'تمت إضافة وصفة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get addSomeRecipesFirst => 'أضف بعض الوصفات أولًا.';

  @override
  String get allRecipesAlreadyIn => 'كل وصفاتك موجودة بالفعل في هذه المجموعة.';

  @override
  String get deleteCollection => 'حذف المجموعة';

  @override
  String get collectionNotFound => 'المجموعة غير موجودة.';

  @override
  String get sharedCollectionBanner =>
      'تظهر هنا أيضًا الوصفات التي يضيفونها لاحقًا. افتح إحداها لحفظ نسخة.';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وصفة',
      many: '$count وصفة',
      few: '$count وصفات',
      two: 'وصفتان',
      one: 'وصفة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get nothingHereYet => 'لا شيء هنا بعد';

  @override
  String get pickRecipesToAdd => 'اختر وصفات لإضافتها إلى هذه المجموعة.';

  @override
  String friendAddsShowUp(String name) {
    return 'ستظهر هنا الوصفات التي يضيفها $name.';
  }

  @override
  String get addRecipes => 'إضافة وصفات';

  @override
  String get removeFromCollection => 'إزالة من المجموعة';

  @override
  String get searchRecipes => 'ابحث في الوصفات';

  @override
  String get selectRecipes => 'اختر وصفات';

  @override
  String addNRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إضافة $count وصفة',
      many: 'إضافة $count وصفة',
      few: 'إضافة $count وصفات',
      two: 'إضافة وصفتين',
      one: 'إضافة وصفة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String fromName(String name) {
    return 'من $name';
  }

  @override
  String collectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مجموعة',
      many: '$count مجموعة',
      few: '$count مجموعات',
      two: 'مجموعتان',
      one: 'مجموعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get aFriendLower => 'صديق';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting يا $name';
  }

  @override
  String get addFirstRecipe => 'أضف وصفتك الأولى';

  @override
  String get addFirstRecipeMessage =>
      'احفظ الأطباق التي تحبها مع مكوناتها وخطواتها، وجدها في ثوانٍ.';

  @override
  String get yourRecipes => 'وصفاتك';

  @override
  String get sort => 'ترتيب';

  @override
  String get newestFirst => 'الأحدث أولًا';

  @override
  String get aToZ => 'أبجديًا';

  @override
  String get quickestFirst => 'الأسرع أولًا';

  @override
  String searchNRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ابحث في $count وصفة أو المكونات',
      many: 'ابحث في $count وصفة أو المكونات',
      few: 'ابحث في $count وصفات أو المكونات',
      two: 'ابحث في وصفتين أو المكونات',
      one: 'ابحث في وصفة واحدة أو المكونات',
    );
    return '$_temp0';
  }

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get noMatches => 'لا نتائج';

  @override
  String nothingFits(String filters) {
    return 'لا شيء يطابق «$filters». جرّب عامل تصفية آخر أو اعرض كل الوصفات.';
  }

  @override
  String get tryAnotherWord => 'جرّب كلمة أخرى أو اعرض كل الوصفات.';

  @override
  String get showAll => 'عرض الكل';

  @override
  String deletedCollectionKept(String name) {
    return 'تم حذف «$name». تبقى وصفاتها.';
  }

  @override
  String get newCollection => 'مجموعة جديدة';

  @override
  String get groupYourRecipes => 'نظّم وصفاتك';

  @override
  String get groupYourRecipesMessage =>
      'أنشئ مجموعات مثل «عشاء أيام الأسبوع» أو «المخبوزات» لتجد الوصفات أسرع.';

  @override
  String get yourCollections => 'مجموعاتك';

  @override
  String get sharedWithYou => 'مشتركة معك';

  @override
  String get empty => 'فارغة';

  @override
  String get discardMessage => 'لن يُحفظ ما كتبته.';

  @override
  String get editCollection => 'تعديل المجموعة';

  @override
  String get giveCollectionName => 'أعطِ مجموعتك اسمًا';

  @override
  String get name => 'الاسم';

  @override
  String get collectionNameExample => 'عشاء أيام الأسبوع';

  @override
  String get description => 'الوصف';

  @override
  String get collectionDescriptionExample => 'وجبات سريعة للأمسيات المزدحمة';

  @override
  String get createCollection => 'إنشاء مجموعة';

  @override
  String get signInToAccount => 'سجّل الدخول إلى حسابك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get newHereCreateAccount => 'جديد هنا؟ أنشئ حسابًا';

  @override
  String get enterFirstName => 'أدخل اسمك الأول';

  @override
  String get createYourAccount => 'أنشئ حسابك';

  @override
  String checkEmailMessage(String email) {
    return 'اقتربت! أرسلنا رابط تأكيد إلى $email. افتحه ثم سجّل الدخول.';
  }

  @override
  String get goToSignIn => 'الذهاب لتسجيل الدخول';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get nameShownHint => 'يظهر لأصدقائك؛ تسجّل الدخول ببريدك الإلكتروني';

  @override
  String get atLeast6 => '6 أحرف على الأقل';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get alreadyHaveAccount => 'لديك حساب؟ سجّل الدخول';

  @override
  String get detailsSaved => 'تم حفظ بياناتك';

  @override
  String get yourDetails => 'بياناتك';

  @override
  String get lastNameOptional => 'اسم العائلة (اختياري)';

  @override
  String get friendsSeeName =>
      'يرى أصدقاؤك هذا الاسم عندما تشارك وصفات أو ترسل طلبات.';

  @override
  String get emailCantChange =>
      'تسجّل الدخول بهذا العنوان. لا يمكن تغييره هنا.';

  @override
  String get save => 'حفظ';

  @override
  String get pageNotFound => 'الصفحة غير موجودة';

  @override
  String get pageNotFoundMessage =>
      'هذا الرابط لا يؤدي إلى أي مكان. ربما حُذفت الوصفة.';

  @override
  String get goToYourRecipes => 'الذهاب إلى وصفاتك';

  @override
  String hoursMinutesValue(int hours, int minutes) {
    return '$hours س $minutes د';
  }

  @override
  String minutesValue(int minutes) {
    return '$minutes د';
  }

  @override
  String hoursValue(int hours) {
    return '$hours س';
  }

  @override
  String servesN(int count) {
    return 'يكفي $count';
  }

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مكوّن',
      many: '$count مكوّنًا',
      few: '$count مكونات',
      two: 'مكوّنان',
      one: 'مكوّن واحد',
    );
    return '$_temp0';
  }

  @override
  String sharedBy(String name) {
    return 'شاركها $name';
  }

  @override
  String get pasteIngredients => 'لصق المكونات';

  @override
  String get pasteIngredientsHint =>
      'مكوّن في كل سطر، مثل «200 غ طحين» أو «2 بيض». يتم تجاهل النقاط والأرقام والعناوين.';

  @override
  String get pasteIngredientsExample =>
      '200 غ طحين\n300 مل حليب\n2 بيض\nرشة ملح';

  @override
  String get pasteFromClipboard => 'لصق من الحافظة';

  @override
  String weFoundIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'وجدنا $count مكوّن',
      many: 'وجدنا $count مكوّنًا',
      few: 'وجدنا $count مكونات',
      two: 'وجدنا مكوّنين',
      one: 'وجدنا مكوّنًا واحدًا',
    );
    return '$_temp0';
  }

  @override
  String addN(int count) {
    return 'إضافة $count';
  }

  @override
  String get noLongerShared => 'لم تعد مشتركة';

  @override
  String sharedWithN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت المشاركة مع $count صديق',
      many: 'تمت المشاركة مع $count صديقًا',
      few: 'تمت المشاركة مع $count أصدقاء',
      two: 'تمت المشاركة مع صديقين',
      one: 'تمت المشاركة مع صديق واحد',
    );
    return '$_temp0';
  }

  @override
  String get noFriendsAddedYet => 'لم تُضف أي أصدقاء بعد.';

  @override
  String get addFriends => 'إضافة أصدقاء';

  @override
  String get done => 'تم';

  @override
  String get anyTime => 'أي مدة';

  @override
  String get under30Min => 'أقل من 30 د';

  @override
  String get under1Hour => 'أقل من ساعة';

  @override
  String get oneHourOrMore => 'ساعة أو أكثر';

  @override
  String get all => 'الكل';

  @override
  String get mine => 'وصفاتي';

  @override
  String get sharedWithMe => 'مشتركة معي';

  @override
  String get recipes => 'الوصفات';

  @override
  String get collections => 'المجموعات';

  @override
  String friendRequestsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب صداقة بانتظارك',
      many: '$count طلب صداقة بانتظارك',
      few: '$count طلبات صداقة بانتظارك',
      two: 'طلبا صداقة بانتظارك',
      one: 'طلب صداقة واحد بانتظارك',
    );
    return '$_temp0';
  }

  @override
  String get errorOffline => 'لا يوجد اتصال. تحقّق من الإنترنت وحاول مرة أخرى.';

  @override
  String get errorWrongPassword =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get errorConfirmEmailFirst =>
      'أكّد بريدك الإلكتروني أولًا: افتح الرابط الذي أرسلناه إليك.';

  @override
  String get errorAccountExists =>
      'يوجد حساب بهذا البريد الإلكتروني بالفعل. سجّل الدخول بدلًا من ذلك.';

  @override
  String get errorPasswordTooShort =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.';

  @override
  String get errorTooManyAttempts =>
      'محاولات كثيرة جدًا. انتظر بضع دقائق وحاول مرة أخرى.';

  @override
  String get errorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get errorOwnEmail => 'هذا بريدك الإلكتروني أنت.';

  @override
  String get errorNotAnEmail => 'لا يبدو هذا عنوان بريد إلكتروني.';

  @override
  String get errorTooManyOpenRequests =>
      'لديك 50 طلبًا مفتوحًا. انتظر بعض الردود أولًا.';

  @override
  String get errorRecipeLimit =>
      'وصلت إلى 2000 وصفة، وهو الحد الأقصى للحساب الواحد.';

  @override
  String get errorCollectionLimit =>
      'وصلت إلى 300 مجموعة، وهو الحد الأقصى للحساب الواحد.';

  @override
  String get errorIngredientLimit =>
      'يمكن أن تحتوي الوصفة على 200 مكوّن كحد أقصى.';

  @override
  String get errorSlowDown => 'تمهّل قليلًا وحاول مرة أخرى لاحقًا.';

  @override
  String get errorNotFound => 'غير موجود. ربما تم حذفه.';

  @override
  String get errorCheckValues =>
      'تحقّق من القيم: يجب أن تكون الأوقات وعدد الحصص أكبر من 0، والعنوان مطلوب.';

  @override
  String get errorForbidden => 'ليس لديك إذن للقيام بذلك.';

  @override
  String get errorSessionExpired => 'انتهت جلستك. سجّل الدخول مرة أخرى.';

  @override
  String get confirmLinkFailed =>
      'لم يعمل رابط التأكيد هنا (ربما انتهت صلاحيته أو فُتح في متصفح آخر). قد يكون بريدك مؤكدًا بالفعل: جرّب تسجيل الدخول.';

  @override
  String get signInProblem => 'حدث خطأ أثناء تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get couldNotSignIn => 'تعذّر تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get couldNotCreateAccount => 'تعذّر إنشاء الحساب. حاول مرة أخرى.';

  @override
  String get couldNotSaveName => 'تعذّر حفظ اسمك. حاول مرة أخرى.';

  @override
  String get failedLoadRecipes => 'تعذّر تحميل الوصفات.';

  @override
  String get failedLoadRecipe => 'تعذّر تحميل الوصفة.';

  @override
  String get failedSaveRecipe => 'تعذّر حفظ الوصفة.';

  @override
  String get onlyOwnerCanChange => 'صاحب الوصفة وحده يمكنه تعديلها.';

  @override
  String get couldNotSaveCopy => 'تعذّر حفظ نسخة.';

  @override
  String get failedDeleteRecipe => 'تعذّر حذف الوصفة.';

  @override
  String get failedLoadCollections => 'تعذّر تحميل المجموعات.';

  @override
  String get failedLoadCollection => 'تعذّر تحميل المجموعة.';

  @override
  String get failedSaveCollection => 'تعذّر حفظ المجموعة.';

  @override
  String get failedDeleteCollection => 'تعذّر حذف المجموعة.';

  @override
  String get failedAddRecipes => 'تعذّرت إضافة الوصفات.';

  @override
  String get failedRemoveRecipe => 'تعذّرت إزالة الوصفة.';

  @override
  String get failedLoadFriends => 'تعذّر تحميل أصدقائك.';

  @override
  String get failedLoadRequests => 'تعذّر تحميل طلبات الصداقة.';

  @override
  String get failedLoadSent => 'تعذّر تحميل الطلبات التي أرسلتها.';

  @override
  String get searchNotWorking => 'البحث لا يعمل حاليًا.';

  @override
  String get couldNotSendRequest => 'تعذّر إرسال الطلب. حاول مرة أخرى.';

  @override
  String get couldNotAccept => 'تعذّر قبول الطلب.';

  @override
  String get couldNotRemoveRequest => 'تعذّرت إزالة الطلب.';

  @override
  String get couldNotRemoveFriend => 'تعذّرت إزالة هذا الصديق.';

  @override
  String get failedLoadShares => 'تعذّر تحميل من تمت المشاركة معهم.';

  @override
  String get couldNotUpdateSharing => 'تعذّر تحديث المشاركة. حاول مرة أخرى.';

  @override
  String get shareOnlyOwn =>
      'يمكنك مشاركة وصفاتك ومجموعاتك فقط، ومع الأصدقاء فقط.';

  @override
  String get couldNotRemoveIt => 'تعذّرت الإزالة. حاول مرة أخرى.';

  @override
  String get cookTab => 'اطبخ';

  @override
  String get whatCanICook => 'ماذا أطبخ؟';

  @override
  String get whatCanICookHint =>
      'أضف ما لديك في البيت واحصل على ثلاث أفكار لوجبات. الملح والزيت والطحين والبهارات محسوبة.';

  @override
  String get addWhatYouHave => 'أضف ما لديك';

  @override
  String get addWhatYouHaveExample => 'بيض، طماطم، أرز';

  @override
  String get nothingAddedYet =>
      'لم تُضف شيئًا بعد. اكتب عنصرًا واحدًا أو عدة عناصر مفصولة بفواصل.';

  @override
  String removeItem(String item) {
    return 'إزالة $item';
  }

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get suggestMeals => 'اقترح وجبات';

  @override
  String get suggestOtherMeals => 'اقترح وجبات أخرى';

  @override
  String get thinkingUpMeals => 'جارٍ التفكير في وجبات…';

  @override
  String get pickAMeal => 'اختر وجبة';

  @override
  String get youHaveEverything => 'لديك كل شيء';

  @override
  String youdNeed(String items) {
    return 'ستحتاج إلى: $items';
  }

  @override
  String get youHaveThis => 'متوفر لديك';

  @override
  String get toBuy => 'للشراء';

  @override
  String get saveToMyRecipes => 'حفظ في وصفاتي';

  @override
  String get aiCheckNote =>
      'كُتبت بالذكاء الاصطناعي: تحقّق من الكميات والأوقات ومسببات الحساسية قبل الطهي.';

  @override
  String get writeStepsWithAi => 'اكتب الخطوات بالذكاء الاصطناعي';

  @override
  String get writingSteps => 'جارٍ كتابة الخطوات…';

  @override
  String get stepsWritten => 'كُتبت الخطوات. اقرأها وعدّل ما تريد قبل الحفظ.';

  @override
  String get aiNeedsNameAndIngredients =>
      'أضف اسم الوصفة ومكوّنًا واحدًا على الأقل أولًا.';

  @override
  String get replaceStepsQuestion => 'استبدال خطواتك؟';

  @override
  String get replaceStepsMessage =>
      'سيكتب الذكاء الاصطناعي خطوات جديدة بدلًا من خطواتك الحالية.';

  @override
  String get replace => 'استبدال';

  @override
  String aiLeftToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بقي $count طلب اليوم',
      many: 'بقي $count طلبًا اليوم',
      few: 'بقيت $count طلبات اليوم',
      two: 'بقي طلبان اليوم',
      one: 'بقي طلب واحد اليوم',
      zero: 'لا طلبات ذكاء اصطناعي متبقية اليوم',
    );
    return '$_temp0';
  }

  @override
  String get aiDailyLimit =>
      'استخدمت طلبات الذكاء الاصطناعي العشرين لهذا اليوم. حاول مرة أخرى غدًا.';

  @override
  String get aiBusy =>
      'الذكاء الاصطناعي المجاني مشغول الآن. حاول بعد دقيقة؛ لم يُحتسب هذا الطلب.';

  @override
  String get aiNotSetUp => 'لم يتم إعداد مساعد الذكاء الاصطناعي بعد.';

  @override
  String get aiFailed =>
      'لم يتمكن الذكاء الاصطناعي من الإجابة هذه المرة. حاول مرة أخرى؛ لم يُحتسب هذا الطلب.';
}
