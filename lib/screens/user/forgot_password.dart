import 'package:flutter/material.dart';
import 'package:loveria/common/language/language_extension.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import 'package:form_validator/form_validator.dart';
import '../../common/services/utils.dart';
import '../../common/widgets/common.dart';
import '../../common/widgets/form_fields.dart';
import '../../common/services/data_transport.dart' as data_transport;
import '../../support/app_theme.dart' as app_theme;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _requestOtpFormKey = GlobalKey<FormState>();
  final _resetPasswordFormKey = GlobalKey<FormState>();

  bool emailOtpSent = false;
  bool emailOtpVerified = false;
  String alertMessage = '';

  final Map<String, dynamic> formInputData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBarWidget(
          context: context, title: 'Forgot Password'.toTranslated(), actionWidgets: []),
      body: Padding(
        padding: const EdgeInsets.only(top: 0, left: 32, right: 32, bottom: 0),
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (alertMessage != '')
                  Text(
                    alertMessage,
                    style: const TextStyle(
                      color: app_theme.warning,
                    ),
                  ),
                // Request email OTP
                if (!emailOtpSent && !emailOtpVerified)
                  Form(
                    key: _requestOtpFormKey,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            InputField(
                              labelText: "Your email address".toTranslated(),
                              inputType: TextInputType.emailAddress,
                              onSaved: (String? value) {
                                formInputData['email'] = value;
                              },
                              validation:
                                  ValidationBuilder().minLength(3).build(),
                            ),
                            LoadingButton(
                              defaultWidget:  Text(
                                'Send Email OTP'.toTranslated(),
                              ),
                              color: app_theme.white,
                              onPressed: () async {
                                // Validate returns true if the form is valid, or false otherwise.
                                _requestOtpFormKey.currentState?.save();
                                if (_requestOtpFormKey.currentState!
                                    .validate()) {
                                  await data_transport.post(
                                    'user/request-new-password',
                                    inputData: formInputData,
                                    context: context,
                                    secured: true,
                                    onSuccess: (responseData) {
                                      if (getItemValue(
                                              responseData, 'data.mail_sent') ==
                                          true) {
                                        setState(() {
                                          emailOtpSent = true;
                                          alertMessage = getItemValue(
                                            responseData,
                                            'data.message',
                                          );
                                        });
                                      }
                                      // Navigator.pop(context);
                                    },
                                    onFailed: (responseData) {},
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                if (emailOtpSent)
                  Form(
                    key: _resetPasswordFormKey,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            InputField(
                              readOnly: true,
                              initialValue: formInputData['email'],
                              labelText: "Email".toTranslated(),
                              validation:
                                  ValidationBuilder().minLength(3).build(),
                            ),
                            InputField(
                              labelText: "Email OTP".toTranslated(),
                              inputType: TextInputType.emailAddress,
                              onSaved: (String? value) {
                                formInputData['otp'] = value;
                              },
                              validation:
                                  ValidationBuilder().minLength(3).build(),
                            ),
                            InputField(
                              labelText: "New Password".toTranslated(),
                              password: true,
                              onSaved: (String? value) {
                                formInputData['password'] = value;
                              },
                              validation:
                                  ValidationBuilder().minLength(3).build(),
                            ),
                            InputField(
                              labelText: "Confirm New Password".toTranslated(),
                              password: true,
                              onSaved: (String? value) {
                                formInputData['password_confirmation'] = value;
                              },
                              validation:
                                  ValidationBuilder().minLength(3).build(),
                            ),
                            LoadingButton(
                              defaultWidget: const Text(
                                'Submit',
                              ),
                              color: app_theme.white,
                              onPressed: () async {
                                // Validate returns true if the form is valid, or false otherwise.
                                _resetPasswordFormKey.currentState?.save();
                                if (_resetPasswordFormKey.currentState!
                                    .validate()) {
                                  await data_transport.post(
                                    'user/process-reset-password',
                                    inputData: formInputData,
                                    context: context,
                                    // secured: true,
                                    onSuccess: (responseData) {
                                      if (getItemValue(responseData,
                                              'data.password_changed') ==
                                          true) {
                                        Navigator.pop(context);
                                      }
                                    },
                                    onFailed: (responseData) {},
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: app_theme.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
