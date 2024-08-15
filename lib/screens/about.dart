import 'package:flutter/material.dart';
import '../support/app_config.dart' as app_config;
// import '../support/app_config.dart' as app_config;
import '../common/widgets/common.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: mainAppBarWidget(context: context),
        body: const Stack(children: <Widget>[
          // const AppBackgroundImage(),
          SingleChildScrollView(
            child: Padding(
              padding:
                  EdgeInsets.only(top: 0, left: 32, right: 32, bottom: 0),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    AppLogo(
                      height: 150,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 30,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'About us',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Divider(),
                          Text(
                            'Version',
                          ),
                          Text("1.0.0"
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ]));
  }
}
