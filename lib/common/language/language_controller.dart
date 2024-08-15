import 'package:loveria/common/language/language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguageController {
  //singleton

  static AppLanguageController? _instance;

  bool isEnglish = true;

  AppLanguageController._() {
    getLanguage();
  }

  storeLanguageTypeIntoLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('language', isEnglish ? 'en' : 'ch');
  }

  getLanguageTypeFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isEnglish = prefs.getString('language') == 'en' ? true : false;
  }

  factory AppLanguageController() {
    _instance ??= AppLanguageController._();
    return _instance!;
  }

  LanguageSrice languageSrice = LanguageSrice();
  Map<String, dynamic>? language;

  getLanguage() async {
    language = await languageSrice.getLanguage();

    print("Language is : ${language}");
  }
}
