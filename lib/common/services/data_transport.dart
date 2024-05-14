import 'dart:convert';
import 'dart:ffi';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../screens/user/login.dart';
import 'input_security.dart';
import '../../support/app_config.dart' as app_config;
import 'auth.dart' as auth;
import 'utils.dart';

String token = '';

_setHeaders() {
  token = auth.getAuthToken();
  return {
    'Content-type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
    // mark as ajax request
    'X-Requested-With': 'XMLHttpRequest',
    // let the system knows this is mobile app request
    'api-request-signature': 'mobile-app-request',
    'Authorization': 'Bearer $token'
  };
}

typedef OnCallbackType = Function(Map<String, dynamic>? responseData);

Future /* <http.Response> */ post(
  String requestedUrl, {
  Map<String, dynamic>? inputData,
  BuildContext? context,
  bool? secured = false,
  List<String>? unSecuredFields,
  OnCallbackType? onSuccess,
  OnCallbackType? thenCallback,
  Function? onError,
  OnCallbackType? onFailed,
}) async {
  Map<String, dynamic>? newInputData = {};
  if ((secured == true) && (inputData != null)) {
    /* inputData = inputData.map((key, value) {
      if ((unSecuredFields != null) && unSecuredFields.contains(key)) {
        return value;
      } else {
        return InputSecurity().text(value);
      }
    }); */
    inputData.forEach((key, value) {
      if ((unSecuredFields != null) && unSecuredFields.contains(key)) {
        newInputData[key] = value;
      } else {
        newInputData[InputSecurity().text(key)] =
            InputSecurity().text(value.toString());
      }
    });
  }
  Uri urlToProcess = apiUrl(requestedUrl);
  pr('http POST request: $urlToProcess');
  if ((inputData != null) && (inputData.isNotEmpty)) {
    pr('http post data: $inputData');
  }
  final httpResponse = await http
      .post(
    urlToProcess,
    headers: _setHeaders(),
    body: jsonEncode(newInputData.isEmpty ? inputData : newInputData),
  )
      .then((value) {
    // process the further request
    _thenProcessing(value, inputData, onSuccess, context, thenCallback, onError,
        failedCallbackAction: onFailed);
    return value;
  });
  return httpResponse.body;
}

// http.Response
Future get(
  String requestedUrl, {
  BuildContext? context,
  OnCallbackType? onSuccess,
  OnCallbackType? thenCallback,
  Function? onError,
  Map<String, dynamic>? queryParameters,
  OnCallbackType? onFailed,
}) async {
  Uri urlToProcess = apiUrl(requestedUrl, queryParameters: queryParameters);
  pr('http GET request: $urlToProcess', lineNumber: 2);
  var httpResponse = await http
      .get(
    urlToProcess,
    headers: _setHeaders(),
  )
      .then((value) {
    // process the further request
    _thenProcessing(value, {}, onSuccess, context, thenCallback, null,
        failedCallbackAction: onFailed);
    return value;
  }).catchError((error) {
    if ((context != null) && (app_config.debug == true)) {
      showToastMessage(context, error.toString(), type: 'error');
    }
    _thenProcessing(error.toString(), {}, null, context, thenCallback, onError,
        failedCallbackAction: onFailed);
    return error;
  });
  return httpResponse.body;
}

uploadFile(String filename, String url,
    {BuildContext? context,
    OnCallbackType? onSuccess,
    OnCallbackType? thenCallback,
    Map<String, String> inputData = const {},
    Function? onError,
    Function? onFailed}) async {
  var request = http.MultipartRequest('POST', apiUrl(url));
  request.headers.addAll(_setHeaders());

  if (inputData.isNotEmpty) {
    request.fields.addAll(inputData);
  }
  request.files.add(await http.MultipartFile.fromPath('filepond', filename));
  var response = await request.send();
  //for getting and decoding the response into json format
  var responseFromStream = await http.Response.fromStream(response);
  // ignore: use_build_context_synchronously
  _thenProcessing(
      responseFromStream, filename, onSuccess, context, thenCallback, onError,
      failedCallbackAction: onFailed);
}

void _thenProcessing(
    value,
    inputData,
    OnCallbackType? successCallbackAction,
    BuildContext? context,
    OnCallbackType? thenCallbackAction,
    Function? onError,
    {Function? failedCallbackAction}) {
  Map<String, dynamic> responseData;
  try {
    responseData = jsonDecode(value.body);
  } catch (e) {
    if (context != null) {
      showToastMessage(context, 'Something went wrong', type: 'error');
    }

    if ((value is String) || (value is Int)) {
      if (onError != null) {
        onError(value);
      }
      pr(value);
    } else {
      if (onError != null) {
        onError(value.body);
      }
      pr(value.body);
    }
    return;
  }
  jsdd(responseData);
  // update the notification count
  int notificationCount = getItemValue(
      responseData, 'client_models.notifications.notificationCount',
      fallbackValue: -1);
  if (notificationCount >= 0) {
    FBroadcast.instance().broadcast(
      "local.broadcast.notification_count",
      value: notificationCount,
    );
  }
  // set the toke if refreshed
  if (responseData['data']?['additional']?['token_refreshed'] != null) {
    auth.storeAuthToken(responseData['data']['additional']['token_refreshed']);
  }
  // check user is authenticated or not
  if (responseData['data']?['auth_info']?['authorized'] == false) {
    auth.logout();
    if (context != null) {
      navigatePage(context, const LoginPage());
    }
  } else if (value.statusCode == 200) {
    if (thenCallbackAction != null) {
      thenCallbackAction(jsonDecode(value.body));
    }
    if (responseData['reaction'] == 1) {
      if (successCallbackAction != null) {
        successCallbackAction(responseData);
      }
      if (context != null) {
        showSuccessMessage(context, responseData['data']['message']);
      }
    } else {
      if (failedCallbackAction != null) {
        failedCallbackAction(responseData);
      }
      if (context != null) {
        showToastMessage(context, responseData['data']['message'],
            type: 'error');
      }
    }
  } else if (value.statusCode == 422) {
    Map<String, dynamic> responseErrors = responseData['errors'];
    String errorString = responseData['message'];
    for (String key in responseErrors.keys) {
      String errorMessage = responseErrors[key][0];
      if (errorString != errorMessage) errorString += '\n $errorMessage';
    }
    if ((errorString != '') && (context != null)) {
      showToastMessage(context, errorString, type: 'error');
    }
  } else {
    if (context != null) {
      showToastMessage(context, 'Something went wrong', type: 'error');
    }
    if (onError != null) {
      onError(value.body);
    }
    throw "DataTransport: Request Failed ${value.body}";
  }
}
