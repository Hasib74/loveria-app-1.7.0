import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../support/app_theme.dart' as app_theme;
import '../../support/app_config.dart' as app_config;

class Utils {}

/// get configuration settings from app_config file
dynamic configItem(String itemRequested, {fallbackValue}) {
  return getItemValue(app_config.configItems, itemRequested, fallbackValue: fallbackValue);
}

/// print debug messages
void pr(dynamic params, {int lineNumber = 1}) {
  if (app_config.debug == true) {
    List lines = StackTrace.current.toString().trimRight().split('\n');
    printLongString('\x1B[34m$params\x1B[0m');
    printLongString(
        // ignore: prefer_interpolation_to_compose_strings
        '\x1B[36mRef#----------------------------------------------------------------------${DateTime.now()} -' +
            lines[lineNumber] +
            '\x1B[0m');
  }
}

/// Print Long String
void printLongString(String text) {
  final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern
      .allMatches(text)
      // ignore: avoid_print
      .forEach((RegExpMatch match) => print(match.group(0)));
}

// print message with exit for debug
void dd(dynamic params) {
  if (app_config.debug == true) {
    List lines = StackTrace.current.toString().trimRight().split('\n');
    printLongString('\x1B[34m$params\x1B[0m');
    printLongString(
        // ignore: prefer_interpolation_to_compose_strings
        '\x1B[36m-----------------------------------------------------------------------------------' +
            lines[1] +
            '\x1B[0m');
    throw '_______ dd';
  }
}

/// access the array/map values using . notation
getItemValue(sourceItem, String keyToAccess, {dynamic fallbackValue}) {
  if (sourceItem == null) {
    return fallbackValue;
  }
  if (sourceItem is String) {
    sourceItem = jsonDecode(sourceItem);
  }
  var keyArray = keyToAccess.split('.');
  var valueToReturn = sourceItem;
  for (var element in keyArray) {
    try {
      valueToReturn = valueToReturn[element];
    } catch (e) {
      return fallbackValue;
    }
  }
  return valueToReturn;
}

/// show success toast message
void showSuccessMessage(BuildContext context, String? message) {
  if ((message != '') && (message != null)) {
    showToastMessage(context, message, type: 'success');
  }
}

/// show error message
void showErrorMessage(BuildContext context, String? message) {
  if ((message != '') && (message != null)) {
    showToastMessage(context, message, type: 'error');
  }
}

/// show toast message
void showToastMessage(
  BuildContext context,
  String message, {
  String type = 'message',
}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
      ),
    ),
    backgroundColor: type == 'success'
        ? app_theme.success
        : ((type == 'error') ? app_theme.error : app_theme.black),
  );
  // Find the ScaffoldMessenger in the widget tree
  // and use it to show a SnackBar.
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

// build api url using config base api url and sent path
Uri apiUrl(
  String url, {
  Map<String, dynamic>? queryParameters,
}) {
  String processedUrl = url;
  if (!url.startsWith('http')) {
    processedUrl = app_config.baseApiUrl + url;
  }

  if (queryParameters != null) {
    String queryString = '';
    queryParameters.forEach((key, value) {
      if (value is List) {
        for (int i = 0; i < value.length; i++) {
          var elementValue = value[i];
          if (elementValue is String ||
              elementValue is int ||
              elementValue is double) {
            queryString += '$key[$elementValue]=$elementValue&';
          } else {
            queryString += '$key[]=$elementValue&';
          }
        }
      } else {
        queryString += '$key=$value&';
      }
    });
    if (queryString != '') {
      processedUrl = processedUrl.contains('?')
          ? '$processedUrl&$queryString'
          : '$processedUrl?$queryString';
    }
  }
  return Uri.parse(processedUrl);
}

// Navigate page helper
void navigatePage(BuildContext context, pageClass) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => pageClass),
  );
}

// response debug messages print from server
void jsdd(response) {
  if (app_config.debug) {
    bool ddExecuted = false;
    bool prExecuted = false;
    bool clogExecuted = false;
    if ((response['__dd'] == true) && (!response['__pr'].isEmpty)) {
      if (!prExecuted) {
        int prCount = 1;
        for (var prValue in response['__pr']) {
          String debugBacktrace = '';
          // ignore: avoid_print
          printLongString(
              "Server __pr $prCount --------------------------------------------------");
          for (String key in prValue.keys) {
            var value = prValue[key];
            if (key != 'debug_backtrace') {
              // ignore: avoid_print
              printLongString(value);
            } else {
              debugBacktrace = value;
            }
          }
          // ignore: avoid_print
          printLongString(
              'Reference  --------------------------------------------------');
          // ignore: avoid_print
          printLongString(debugBacktrace);
          prCount++;
        }
        prExecuted = true;
        // ignore: avoid_print
        printLongString(
            "------------------------------------------------------------ __pr end");
      }
    }
    if ((response['__dd'] == '__dd') && (response['__clog'] == '__clog')) {
      if (!clogExecuted) {
        // ignore: avoid_print
        printLongString(response);
        clogExecuted = true;
      }
    }

    if (response['__dd'] == '__dd') {
      if (!ddExecuted) {
        // ignore: avoid_print
        printLongString(
            'Server __dd  --------------------------------------------------');
        for (String key in response['data'].keys) {
          var value = response['data'][key];
          if (key != 'debug_backtrace') {
            // ignore: avoid_print
            printLongString(value);
          } else {
            // ignore: avoid_print
            printLongString(
                "Reference  --------------------------------------------------");
            // ignore: avoid_print
            printLongString(value);
          }
        }
        ddExecuted = true;
      }
      // printLongString( "------------------------------------------------------------ __dd end");
      throw '------------------------------------------------------------ __dd end.';
    }
  }
}

// check if ios platform
bool isIOSPlatform() {
  return Platform.isIOS;
}

// material color swatch generator
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
