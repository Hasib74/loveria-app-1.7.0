import 'package:flutter/material.dart';
import 'package:loveria/common/language/language_extension.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import 'package:form_validator/form_validator.dart';
import '../../common/widgets/form_fields.dart';
import '../../common/services/data_transport.dart' as data_transport;
import '../../support/app_theme.dart' as app_theme;

class AbuseReportPage extends StatefulWidget {
  const AbuseReportPage(
      {Key? key, required this.userFullName, required this.userUid})
      : super(key: key);

  final String userFullName;
  final String userUid;

  @override
  State<AbuseReportPage> createState() => _AbuseReportPageState();
}

class _AbuseReportPageState extends State<AbuseReportPage> {
  final _formKey = GlobalKey<FormState>();
  bool isUserReported = false;
  final Map<String, dynamic> formInputData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Abuse report'.toTranslated()),
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
                  if (isUserReported)
                     Text('User has been reported successfully'.toTranslated()),
                  if (!isUserReported)
                    Column(
                      children: [
                         Text('Report'.toTranslated()),
                        Text(
                          widget.userFullName,
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        InputField(
                          inputType: TextInputType.multiline,
                          labelText: "Reason".toTranslated(),
                          onSaved: (String? value) {
                            formInputData['report_reason'] = value;
                          },
                          validation: ValidationBuilder().minLength(3).build(),
                        ),
                        LoadingButton(
                          defaultWidget:  Text(
                            'Report User'.toTranslated(),
                          ),
                          color: app_theme.white,
                          onPressed: () async {
                            // Validate returns true if the form is valid, or false otherwise.
                            _formKey.currentState?.save();
                            if (_formKey.currentState!.validate()) {
                              await data_transport.post(
                                '${widget.userUid}/report-user',
                                inputData: formInputData,
                                context: context,
                                onSuccess: (responseData) {
                                  setState(() {
                                    isUserReported = true;
                                  });
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
      ),
    );
  }
}
