import 'dart:convert';

import 'package:http/http.dart' as https;

class LanguageSrice {
  Future<Map<String, dynamic>?> getLanguage() async {
    var language =
        await https.get(Uri.parse("http://dating.paksang.com/lang.json"));

    if (language.statusCode == 200) {


      print("Before response decode message : ${language.body}");

      return jsonDecode(utf8.decode(language.bodyBytes));
    }
    return null;
  }
}
