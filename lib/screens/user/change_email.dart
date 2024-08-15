import 'package:flutter/material.dart';
import 'package:loveria/common/language/language_extension.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import 'package:form_validator/form_validator.dart';
import '../../common/services/auth.dart' as auth;
import '../../common/services/utils.dart';
import '../../common/widgets/common.dart';
import '../../common/widgets/form_fields.dart';
import '../../common/services/data_transport.dart' as data_transport;
import '../../support/app_theme.dart' as app_theme;

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({Key? key}) : super(key: key);

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();

  bool activationRequired = false;

  final Map<String, dynamic> formInputData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBarWidget(
          context: context, title: 'Change Email'.toTranslated(), actionWidgets: []),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 32,
          right: 32,
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (activationRequired)
                         Column(
                          children: [
                            Text(
                              'Activate your new email address'.toTranslated(),
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                                'Almost finished... You need to confirm your email address. To complete the activation process, please click the link in the email we just sent you.'.toTranslated())
                          ],
                        ),
                      if (!activationRequired)
                        Column(
                          children: [
                            InputField(
                              readOnly: true,
                              initialValue: auth.getAuthInfo('email'),
                              labelText: "Current Email".toTranslated(),
                              onSaved: (String? value) {
                                formInputData['current_email'] = value;
                              },
                              validation: ValidationBuilder()
                                  .minLength(3)
                                  .email()
                                  .build(),
                            ),
                            InputField(
                              labelText: "New Email".toTranslated(),
                              onSaved: (String? value) {
                                formInputData['new_email'] = value;
                              },
                              validation: ValidationBuilder()
                                  .minLength(3)
                                  .email()
                                  .build(),
                            ),
                            InputField(
                              labelText: "Password".toTranslated(),
                              password: true,
                              validation:
                                  ValidationBuilder().minLength(6).build(),
                              onSaved: (String? value) {
                                formInputData['current_password'] = value;
                              },
                            ),
                            LoadingButton(
                              defaultWidget:  Text(
                                'Change Email'.toTranslated(),
                              ),
                              color: app_theme.white,
                              onPressed: () async {
                                // Validate returns true if the form is valid, or false otherwise.
                                _formKey.currentState?.save();
                                if (_formKey.currentState!.validate()) {
                                  await data_transport.post(
                                    'profile/update-email-process',
                                    inputData: formInputData,
                                    context: context,
                                    onSuccess: (responseData) {
                                      setState(() {
                                        activationRequired = getItemValue(
                                          responseData,
                                          'data.activationRequired',
                                        );
                                      });
                                      if (!activationRequired) {
                                        auth.refreshUserInfo();
                                        Navigator.pop(context);
                                      }
                                    },
                                    onFailed: (responseData) {},
                                  );
                                }
                              },
                            ),
                          ],
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
                            child:  Text(
                              "Go back".toTranslated(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
