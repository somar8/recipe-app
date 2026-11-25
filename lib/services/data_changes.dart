import 'package:flutter/foundation.dart';

/// Goes up by one whenever recipes, collections, sharing or friends change anywhere in
/// the app. Lists listen to it, so a tab you're not looking at is up to date when you
/// switch back (for example after deleting a recipe from inside a collection).
final dataChanges = ValueNotifier<int>(0);

void markDataChanged() => dataChanges.value++;
