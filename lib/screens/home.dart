import 'package:flutter/material.dart';
import 'package:loveria/common/language/language_extension.dart';
import 'landing.dart';
import 'user/login.dart';
import 'user/register.dart';
import '../common/services/utils.dart';
import '../support/app_theme.dart' as app_theme;
import '../common/widgets/common.dart';
import '../common/services/auth.dart' as auth;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future? getRefreshAuthInfo;

  @override
  void initState() {
    getRefreshAuthInfo = auth.fetchAuthInfo();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const AppBackgroundImage(),
          Padding(
            padding: const EdgeInsets.only(
              top: 0,
              left: 32,
              right: 32,
              bottom: 0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                const AppLogo(
                  height: 180,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: "Most awaited Dating App is here!".toTranslated(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 24.0),
                      child: Text(
                        "Dating doesn't have to be hard.".toTranslated(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: FutureBuilder(
                        future: getRefreshAuthInfo,
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData &&
                              (snapshot.connectionState ==
                                  ConnectionState.done)) {
                            return Align(
                              alignment: Alignment.center,
                              child: auth.isLoggedIn()
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 16.0,
                                          ),
                                          child: SizedBox(
                                            width: 300,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    app_theme.secondary,
                                              ),
                                              onPressed: () {
                                                navigatePage(
                                                  context,
                                                  const LandingPage(),
                                                );
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: 16.0,
                                                  right: 16.0,
                                                  top: 12,
                                                  bottom: 12,
                                                ),
                                                child: Text(
                                                  "Let's Go".toTranslated(),
                                                  style: TextStyle(
                                                    // color: app_theme.text,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 26.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 16.0,
                                          ),
                                          child: SizedBox(
                                            width: 300,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    app_theme.secondary,
                                              ),
                                              onPressed: () {
                                                navigatePage(
                                                  context,
                                                  const LoginPage(),
                                                );
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: 16.0,
                                                  right: 16.0,
                                                  top: 12,
                                                  bottom: 12,
                                                ),
                                                child: Text(
                                                  "Login".toTranslated(),
                                                  style: TextStyle(
                                                    // color: app_theme.text,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 26.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16.0),
                                          child: SizedBox(
                                              width: 300,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      app_theme.secondary,
                                                ),
                                                onPressed: () {
                                                  navigatePage(
                                                    context,
                                                    RegisterPage(),
                                                  );
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 16.0,
                                                    right: 16.0,
                                                    top: 12,
                                                    bottom: 12,
                                                  ),
                                                  child: Text(
                                                    "Register".toTranslated(),
                                                    style: TextStyle(
                                                      // color: app_theme.text,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 26.0,
                                                    ),
                                                  ),
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                            );
                          }
                          return const Align(
                            alignment: Alignment.center,
                            child: AppItemProgressIndicator(),
                          );
                        }),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
