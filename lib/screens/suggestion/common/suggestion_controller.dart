import 'package:shared_preferences/shared_preferences.dart';

class SuggestionController {
  //singelton
  static final SuggestionController _instance =
      SuggestionController._internal();

  factory SuggestionController() => _instance;

  SuggestionController._internal();

  List<String> premiumChecked = [];

  savePremiumCheckedIntoLocalDb() async {
    // set premiumChecked into local db

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('premiumChecked', premiumChecked);
  }

  getPremiumCheckedFromLocalDb() async {
    // get premiumChecked from local db

    SharedPreferences prefs = await SharedPreferences.getInstance();

    premiumChecked = prefs.getStringList('premiumChecked') ?? [];
  }
}
