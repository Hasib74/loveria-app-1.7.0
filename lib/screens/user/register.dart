import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:loveria/common/language/language_extension.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import '../../common/services/utils.dart';
import '../../common/widgets/form_fields.dart';
import '../../common/services/data_transport.dart' as data_transport;
import '../../common/services/auth.dart' as auth;
import '../../support/app_theme.dart' as app_theme;
import '../../common/widgets/common.dart';
import 'package:form_validator/form_validator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'login.dart';

class RegisterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formInputData = {
    'accepted_terms': false,
    'country_code': ''
  };
  RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    auth.redirectIfAuthenticated(context);
    return Scaffold(
      body: FutureBuilder(
          future: prepareData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData &&
                (snapshot.connectionState == ConnectionState.done)) {
              formInputData['dob'] =
                  getItemValue(snapshot.data, 'data.age_restrictions.max');

              List phoneCountries = [
                {'name': 'Select Country Code', 'phone_code': ''}
              ];
              phoneCountries.addAll(getItemValue(
                  snapshot.data, 'data.country_phone_codes',
                  fallbackValue: []));

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 0, left: 32, right: 32, bottom: 0),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: AppLogo(
                            height: 75,
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                               Padding(
                                padding: EdgeInsets.only(
                                  top: 30,
                                ),
                                child: Text(
                                  'Register'.toTranslated(),
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: app_theme.white,
                                  ),
                                ),
                              ),
                              InputField(
                                labelText: "First Name".toTranslated(),
                                onSaved: (String? value) {
                                  formInputData['first_name'] = value;
                                },
                                validation:
                                    ValidationBuilder().minLength(3).build(),
                              ),
                              InputField(
                                labelText: "Last Name".toTranslated(),
                                onSaved: (String? value) {
                                  formInputData['last_name'] = value;
                                },
                                validation:
                                    ValidationBuilder().minLength(3).build(),
                              ),
                              InputField(
                                labelText: "Username".toTranslated(),
                                // prefixIcon: Icons.person,
                                onSaved: (String? value) {
                                  formInputData['username'] = value;
                                },
                                validation:
                                    ValidationBuilder().minLength(3).build(),
                              ),
                              SelectField(
                                listItems:
                                    getItemValue(snapshot.data, 'data.genders'),
                                labelText: 'Gender'.toTranslated(),
                                onSaved: (String? value) {
                                  formInputData['gender'] = value;
                                },
                                validation:
                                    ValidationBuilder().required().build(),
                              ),
                              DateTimeInputPicker(
                                initialValue: formInputData['dob'],
                                minimumDate: getItemValue(snapshot.data,
                                        'data.age_restrictions.min')
                                    .toString(),
                                maximumDate: getItemValue(snapshot.data,
                                        'data.age_restrictions.max')
                                    .toString(),
                                labelText: 'Birthday'.toTranslated(),
                                onChanged: (String? value) {
                                  formInputData['dob'] = value;
                                },
                                validation:
                                    ValidationBuilder().required().build(),
                              ),
                              SelectField(
                                value: formInputData['country_code'].toString(),
                                optionKeyName: 'phone_code',
                                optionLabelName: 'name',
                                showOptionKeyInBracket: true,
                                listItems: phoneCountries,
                                labelText: 'Mobile Country Code'.toTranslated(),
                                onChanged: (String? value) {
                                  formInputData['country_code'] = value;
                                },
                              ),
                              InputField(
                                inputType: TextInputType.phone,
                                labelText: "Mobile Number".toTranslated(),
                                onSaved: (String? value) {
                                  formInputData['mobile_number'] = value;
                                },
                                validation: ValidationBuilder().phone().build(),
                              ),
                              InputField(
                                labelText: "Email".toTranslated(),
                                inputType: TextInputType.emailAddress,
                                onSaved: (String? value) {
                                  formInputData['email'] = value;
                                },
                                validation: ValidationBuilder().email().build(),
                              ),
                              InputField(
                                labelText: "Password".toTranslated(),
                                password: true,
                                validation:
                                    ValidationBuilder().minLength(6).build(),
                                prefixIcon: const Icon(Icons.key),
                                onSaved: (String? value) {
                                  formInputData['password'] = value;
                                },
                              ),
                              InputField(
                                labelText: "Confirm Password".toTranslated(),
                                password: true,
                                validation:
                                    ValidationBuilder().minLength(6).build(),
                                prefixIcon: const Icon(Icons.key),
                                onSaved: (String? value) {
                                  formInputData['repeat_password'] = value;
                                },
                              ),
                              StatefulBuilder(builder: (context, setState) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: formInputData['accepted_terms'],
                                        onChanged: (bool? value) {
                                          setState(
                                            () {
                                              formInputData['accepted_terms'] =
                                                  value;
                                            },
                                          );
                                        },
                                      ),
                                      Flexible(
                                        child: Text.rich(TextSpan(
                                            text: 'I accept all the'.toTranslated()+" ",
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: 'terms & conditions'.toTranslated(),
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        launchUrl(
                                                          Uri.parse(
                                                            getItemValue(
                                                                snapshot.data,
                                                                'data.terms_and_conditions_url'),
                                                          ),
                                                          mode: LaunchMode
                                                              .externalApplication,
                                                        );
                                                      },
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationThickness: 2,
                                                ),
                                              ),
                                              if (getItemValue(snapshot.data,
                                                      'data.privacy_policy_url') !=
                                                  '')
                                                 TextSpan(
                                                  text: " "+'and'.toTranslated()+" ",
                                                ),
                                              if (getItemValue(snapshot.data,
                                                      'data.privacy_policy_url') !=
                                                  '')
                                                TextSpan(
                                                  text: 'privacy policy'.toTranslated(),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          launchUrl(
                                                            Uri.parse(
                                                              getItemValue(
                                                                  snapshot.data,
                                                                  'data.privacy_policy_url'),
                                                            ),
                                                            mode: LaunchMode
                                                                .externalApplication,
                                                          );
                                                        },
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationThickness: 2,
                                                  ),
                                                )
                                            ])),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              LoadingButton(
                                defaultWidget:  Text(
                                  'Register'.toTranslated(),
                                  style: TextStyle(
                                    color: app_theme.primary,
                                    fontSize: 22,
                                  ),
                                ),
                                // width: 196,
                                // height: 60,
                                color: app_theme.white,
                                onPressed: () async {
                                  // Validate returns true if the form is valid, or false otherwise.
                                  _formKey.currentState?.save();
                                  if (_formKey.currentState!.validate()) {
                                    if (!formInputData['accepted_terms']) {
                                      showActionableDialog(
                                        context,
                                        title: 'Terms & Conditions'.toTranslated(),
                                        description:  Text(
                                          'Please accept terms & conditions to proceed'.toTranslated(),
                                        ),
                                        cancelActionText: 'OK',
                                      );
                                      return;
                                    }
                                    await data_transport.post(
                                        'user/process-sign-up',
                                        inputData: formInputData,
                                        context: context,
                                        secured: true,
                                        unSecuredFields: [
                                          'first_name',
                                          'last_name',
                                        ], onSuccess: (responseData) {
                                      if (getItemValue(responseData,
                                              'data.activation_required') !=
                                          true) {
                                        auth.createLoginSession(
                                            responseData, context);
                                      } else {
                                        showActionableDialog(
                                          context,
                                          title: 'Account Created Successfully'.toTranslated(),
                                          description: Text(
                                            getItemValue(
                                                responseData, 'data.message'),
                                          ),
                                          confirmActionText: 'Go to login now'.toTranslated(),
                                          onConfirm: () {
                                            navigatePage(context, const LoginPage());
                                          },
                                        );
                                      }
                                    });
                                  }
                                },
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
                                backgroundColor: app_theme.secondary,
                              ),
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              },
                              child:  Padding(
                                  padding: EdgeInsets.only(
                                    left: 16.0,
                                    right: 16.0,
                                    top: 12,
                                    bottom: 12,
                                  ),
                                  child: Text("GO HOME".toTranslated(),
                                      style: TextStyle(
                                        // color: app_theme.text,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.0,
                                      ))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Align(
                alignment: Alignment.center,
                child: AppItemProgressIndicator(),
              );
            }
          }),
    );
  }

  get prepareData {
    return data_transport.get('user/prepare-sign-up');
  }
}
