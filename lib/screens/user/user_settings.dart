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

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({
    Key? key,
  }) : super(key: key);
  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoadingInProcess = true;
  Map mobileNumberOptions = {};
  Map<String, dynamic> formInputData = {};
  Map<String, dynamic> accountDeleteInputData = {};

  @override
  initState() {
    data_transport.get(
      'notification/get-setting-data',
      onSuccess: (responseData) {
        setState(() {
          formInputData = getItemValue(responseData, 'data.userSettingData');
          mobileNumberOptions = getItemValue(responseData,
              'data.userSettingData.user_choice_display_mobile_number');
          isLoadingInProcess = false;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBarWidget(
        context: context,
        title: 'Settings',
        actionWidgets: [],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 32,
          right: 32,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (isLoadingInProcess) const AppItemProgressIndicator(),
                  if (!isLoadingInProcess)
                    Column(
                      children: [
                        StatefulBuilder(builder: (context, setState) {
                          return Column(
                            children: [
                              CheckboxListTile(
                                  title:
                                      const Text('Show Visitor Notifications'),
                                  activeColor: Theme.of(context).primaryColor,
                                  value: formInputData[
                                      'show_visitor_notification'],
                                  onChanged: (bool? value) {
                                    setState(
                                      () {
                                        formInputData[
                                                'show_visitor_notification'] =
                                            value;
                                      },
                                    );
                                  }),
                              CheckboxListTile(
                                  title: const Text('Show Likes Notifications'),
                                  activeColor: Theme.of(context).primaryColor,
                                  value:
                                      formInputData['show_like_notification'],
                                  onChanged: (bool? value) {
                                    setState(
                                      () {
                                        formInputData[
                                            'show_like_notification'] = value;
                                      },
                                    );
                                  }),
                              CheckboxListTile(
                                  title: const Text('Show Gifts Notifications'),
                                  activeColor: Theme.of(context).primaryColor,
                                  value:
                                      formInputData['show_gift_notification'],
                                  onChanged: (bool? value) {
                                    setState(
                                      () {
                                        formInputData[
                                            'show_gift_notification'] = value;
                                      },
                                    );
                                  }),
                              CheckboxListTile(
                                  title:
                                      const Text('Show Messages Notifications'),
                                  activeColor: Theme.of(context).primaryColor,
                                  value: formInputData[
                                      'show_message_notification'],
                                  onChanged: (bool? value) {
                                    setState(
                                      () {
                                        formInputData[
                                                'show_message_notification'] =
                                            value;
                                      },
                                    );
                                  }),
                              CheckboxListTile(
                                  title: const Text(
                                      'Show Login Notifications for your Liked Users'),
                                  activeColor: Theme.of(context).primaryColor,
                                  value: formInputData[
                                      'show_user_login_notification'],
                                  onChanged: (bool? value) {
                                    setState(
                                      () {
                                        formInputData[
                                                'show_user_login_notification'] =
                                            value;
                                      },
                                    );
                                  }),
                            ],
                          );
                        }),
                        if (mobileNumberOptions.isNotEmpty)
                          SelectField(
                            value: formInputData['display_user_mobile_number']
                                .toString(),
                            listItems: mobileNumberOptions,
                            labelText: 'Display Mobile Number',
                            onChanged: (String? value) {
                              formInputData['display_user_mobile_number'] =
                                  value.toString();
                            },
                          ),
                        const Divider(
                          thickness: 0.1,
                          height: 80,
                        ),
                        LoadingButton(
                          defaultWidget: const Text(
                            'Update Settings',
                          ),
                          color: app_theme.white,
                          onPressed: () async {
                            // Validate returns true if the form is valid, or false otherwise.
                            _formKey.currentState?.save();
                            if (_formKey.currentState!.validate()) {
                              await data_transport.post(
                                'notification/user-setting-store',
                                inputData: formInputData,
                                context: context,
                                onSuccess: (responseData) {},
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
                  const Divider(
                    thickness: 0.1,
                    height: 50,
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
                          backgroundColor: app_theme.error,
                        ),
                        onPressed: () {
                          showActionableDialog(
                            context,
                            title: 'Delete Account',
                            description: Column(
                              children: [
                                const Text(
                                  'All content including photos and other data will be permanently removed!',
                                ),
                                InputField(
                                  labelText: "Confirm Password",
                                  password: true,
                                  onChanged: (String? value) {
                                    accountDeleteInputData['password'] = value;
                                  },
                                  validation:
                                      ValidationBuilder().minLength(3).build(),
                                ),
                              ],
                            ),
                            confirmActionText: 'Yes delete',
                            cancelActionText: 'Cancel',
                            onConfirm: () {
                              if ((accountDeleteInputData['password'] == '') ||
                                  (accountDeleteInputData['password'] ==
                                      null)) {
                                return false;
                              }

                              data_transport.post(
                                'delete-account',
                                inputData: accountDeleteInputData,
                                secured: true,
                                onFailed: (responseData) {
                                  setState(() {
                                    accountDeleteInputData['password'] = '';
                                  });
                                  showErrorMessage(
                                    context,
                                    getItemValue(responseData, 'data.message'),
                                  );
                                },
                                onSuccess: (responseData) {
                                  data_transport.post(
                                    'user/logout',
                                  );
                                  showSuccessMessage(
                                      context,
                                      getItemValue(
                                          responseData, 'data.message'));
                                  auth.logout().then((response) {
                                    auth.redirectIfUnauthenticated(context);
                                  });
                                },
                              );
                            },
                          );
                        },
                        child: const Text(
                          "Delete Account",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
