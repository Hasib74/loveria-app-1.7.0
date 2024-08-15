import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:loveria/common/language/language_extension.dart';
import 'package:loveria/common/services/auth.dart';
import 'package:loveria/screens/suggestion/common/suggestion_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumProfileViewAlert extends StatefulWidget {
  String? imageUrl;

  String? name;

  String? date;

  String? city;

  String? id;

  PremiumProfileViewAlert(
      {this.imageUrl, this.name, this.date, this.city, this.id});
  @override
  State<PremiumProfileViewAlert> createState() =>
      _PremiumProfileViewAlertState();
}

class _PremiumProfileViewAlertState extends State<PremiumProfileViewAlert> {
  bool? isPremium;

  bool isBlur = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isBlur ? _profie().blurred(blur: 10) : _profie(),
                const SizedBox(
                  height: 32,
                ),
                Visibility(
                  visible: isBlur,
                  child:  Text(
                    'If you press yes, the regular match button will be muted once you have viewed the profile.'.toTranslated(),
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (isBlur) {
                          setState(() {
                            isBlur = false;
                          });

                          if (SuggestionController().premiumChecked.isEmpty ||
                              SuggestionController()
                                      .premiumChecked
                                      .contains(widget.id) ==
                                  false) {
                            SuggestionController()
                                .premiumChecked
                                .add(widget.id!);



                            SuggestionController().savePremiumCheckedIntoLocalDb();

                          }

                          return;
                        }

                        if (isBlur == false) {
                          var msg =
                              '''Hello, I want to do premium matching with ${widget.name}  (#${widget?.id}) ''';

                          var whatsappUrl = Uri.parse(
                              "whatsapp://send?phone=${"+85290802890"}" +
                                  "&text=${Uri.encodeComponent(msg)}");

                          try {
                            launchUrl(whatsappUrl);
                          } catch (e) {
                            debugPrint(e.toString());
                          }
                        }
                      },
                      child: Text(isBlur == true ? 'Yes'.toTranslated() : "Continue".toTranslated()),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Visibility(
                      visible: isBlur,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child:  Text('No'.toTranslated()),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  Container _profie() {
    return Container(
      width: 150,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: NetworkImage(widget.imageUrl!),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.name ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  void _init() {
    print("The id ${widget.id}");

    print("The premium checked ${SuggestionController().premiumChecked}");
    isPremium = SuggestionController().premiumChecked.contains(widget.id)
        ? true
        : false;

    print("Is premium : $isPremium");

    setState(() {
      isBlur = !isPremium!;
    });
  }
}
