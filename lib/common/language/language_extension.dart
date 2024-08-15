import 'language_controller.dart';

extension languageExtension on String {
  String toTranslated() {
    if (AppLanguageController().isEnglish) {
      return this;
    } else {
      return AppLanguageController().language![capitalize()] ?? this;
    }
  }
}


extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}