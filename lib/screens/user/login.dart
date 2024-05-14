import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loveria/common/language/language_extension.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import '../../common/services/utils.dart';
import '../../common/widgets/form_fields.dart';
import '../../common/services/data_transport.dart' as data_transport;
import '../../common/services/auth.dart' as auth;
import '../../support/app_theme.dart' as app_theme;
import '../../common/widgets/common.dart';
import 'package:form_validator/form_validator.dart';
import '../home.dart';
import 'forgot_password.dart';

/// The scopes required by this application.
const List<String> scopes = <String>[
  'email',
  // 'https://www.googleapis.com/auth/contacts.readonly',
];

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> formInputData = {};
  bool isInProcess = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    clientId:
        isIOSPlatform() ? configItem('social_logins.google.client_id') : null,
    scopes: scopes,
  );

  @override
  Widget build(BuildContext context) {
    auth.redirectIfAuthenticated(context);
    return Scaffold(
        body: Stack(children: <Widget>[
      // const AppBackgroundImage(),
      SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 0, left: 32, right: 32, bottom: 0),
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
                if (isInProcess)
                  const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                      child: AppItemProgressIndicator(),
                    ),
                  ),
                if (!isInProcess)
                  Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                             Padding(
                              padding: EdgeInsets.only(
                                bottom: 30,
                                top: 25,
                              ),
                              child: Text(
                                'Sign in'.toTranslated(),
                                style: TextStyle(
                                  fontSize: 30,
                                  color: app_theme.white,
                                ),
                              ),
                            ),
                            InputField(
                              placeholder: "Email or Username".toTranslated(),
                              prefixIcon: const Icon(Icons.person),
                              onSaved: (String? value) {
                                formInputData['email_or_username'] = value;
                              },
                              validation:
                                  ValidationBuilder().minLength(3).build(),
                            ),
                            InputField(
                              placeholder: "Password".toTranslated(),
                              password: true,
                              validation:
                                  ValidationBuilder().minLength(6).build(),
                              prefixIcon: const Icon(Icons.key),
                              onSaved: (String? value) {
                                formInputData['password'] = value;
                              },
                            ),
                            LoadingButton(
                              height: 60,
                              // loadingWidget: const AppItemProgressIndicator(),
                              defaultWidget:  Text(
                                'Login'.toTranslated(),
                                style: TextStyle(
                                  color: app_theme.primary,
                                  fontSize: 22,
                                ),
                              ),
                              color: app_theme.white,
                              onPressed: () async {
                                // Validate returns true if the form is valid, or false otherwise.
                                _formKey.currentState?.save();
                                if (_formKey.currentState!.validate()) {
                                  await data_transport.post(
                                    'user/login-process',
                                    inputData: formInputData,
                                    context: context,
                                    secured: true,
                                    onSuccess: (responseData) {
                                      if (responseData != null) {
                                        auth.createLoginSession(
                                            responseData, context);
                                      }
                                    },
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            navigatePage(context, const ForgotPasswordPage());
                          },
                          child:  Text('Forgot Password?'.toTranslated()),
                        ),
                      ),
                      Divider(
                        color: Theme.of(context).secondaryHeaderColor,
                        thickness: 0.2,
                        height: 30,
                      ),
                      if (configItem('social_logins.facebook.enable'))
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SocialLoginButton(
                            buttonType: SocialLoginButtonType.facebook,
                            onPressed: () async {
                              final LoginResult fbLoginResult =
                                  await FacebookAuth.instance.login();
                              if (fbLoginResult.status == LoginStatus.success) {
                                // you are logged
                                final AccessToken accessToken =
                                    fbLoginResult.accessToken!;
                                setState(() {
                                  isInProcess = true;
                                });
                                // ignore: use_build_context_synchronously
                                await data_transport.post(
                                  'user/social-login/response/via-facebook',
                                  inputData: {
                                    'access_token': accessToken.token
                                  },
                                  context: context,
                                  onSuccess: (responseData) {
                                    if (responseData != null) {
                                      auth.createLoginSession(
                                          responseData, context);
                                    }
                                  },
                                  thenCallback: (responseData) {
                                    setState(() {
                                      isInProcess = false;
                                    });
                                  },
                                );
                              } else {
                                setState(() {
                                  isInProcess = false;
                                });
                                pr(fbLoginResult.message);
                                // ignore: use_build_context_synchronously
                                showToastMessage(
                                  context,
                                  'Failed to initialize'.toTranslated(),
                                  type: 'error',
                                );
                              }
                            },
                            imageWidth: 20,
                          ),
                        ),
                      if (configItem('social_logins.google.enable'))
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SocialLoginButton(
                            buttonType: SocialLoginButtonType.google,
                            onPressed: () async {
                              await _googleSignIn.signOut();
                              _googleSignIn.signIn().then((result) {
                                result?.authentication.then((googleKey) {
                                  setState(() {
                                    isInProcess = true;
                                  });
                                  data_transport.post(
                                    'user/social-login/response/via-google',
                                    inputData: {
                                      'access_token': googleKey.accessToken
                                    },
                                    context: context,
                                    onSuccess: (responseData) {
                                      if (responseData != null) {
                                        auth.createLoginSession(
                                            responseData, context);
                                      }
                                    },
                                    thenCallback: (responseData) {
                                      setState(() {
                                        isInProcess = false;
                                      });
                                    },
                                  );
                                }).catchError((err) {
                                  pr(err);
                                  setState(() {
                                    isInProcess = false;
                                  });
                                });
                              }).catchError((err) {
                                pr(err);
                                setState(() {
                                  isInProcess = false;
                                });
                              });
                            },
                            imageWidth: 20,
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
                              navigatePage(context, const HomePage());
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
              ],
            ),
          ),
        ),
      )
    ]));
  }
}
