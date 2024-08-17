import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loveria/common/language/language_extension.dart';
import 'package:loveria/common/services/auth.dart';
import 'package:loveria/screens/suggestion/common/suggestion_controller.dart';
import 'package:loveria/screens/suggestion/model/suggestion_list_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../common/widgets/common.dart';
import '../../premium_profile_view_alart.dart';
import '../../profile_details.dart';

class SuggestionListScreen extends StatefulWidget {
  const SuggestionListScreen({Key? key}) : super(key: key);

  @override
  State<SuggestionListScreen> createState() => _SuggestionListScreenState();
}

class _SuggestionListScreenState extends State<SuggestionListScreen> {
  SuggestionListResponseModel? suggestionListResponseModel;

  bool? isProfileDone;

  bool? isInterestDone;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    onInit();

    print("_SuggestionListScreenState initial state");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (isProfileDone == null || isInterestDone == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (isProfileDone == false || isInterestDone == false) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                        visible: isProfileDone == false,
                        child: Column(
                          children: [
                            Text("* ${"Complete your full profile (all fields) to receive matching suggestions."
                                    .toTranslated()}"),
                            SizedBox(
                              height: 8,
                            ),
                          ],
                        )),
                    Visibility(
                        visible: isInterestDone == false,
                        child: Column(
                          children: [
                            Text("* ${'Answer at least three questions under "Interests" for tailored suggestions.'
                                    .toTranslated()}"),
                            SizedBox(
                              height: 8,
                            ),
                            Text("* ${'Answer the "Special Requirement" question under "Interests" for better matches.'
                                    .toTranslated()}"),
                          ],
                        ))
                  ],
                ),
              ),
            ),
          );
        }

        return suggestionListResponseModel == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : suggestionListResponseModel?.data?.length == 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Your matching suggestions are unavailable. Please contact for new suggestions.",
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        FilledButton(
                          onPressed: () {
                            String mes = "I want new suggestions!";

                            print("Message  : ${mes}");
                            var whatsappUrl = Uri.parse(
                                "whatsapp://send?phone=${"+85290802890"}" +
                                    "&text=${Uri.encodeComponent(mes)}");

                            try {
                              launchUrl(whatsappUrl);
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                          child: const Text("Contact"),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    itemCount: suggestionListResponseModel?.data?.length ?? 0,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      crossAxisCount: constraints.maxWidth > 600
                          ? (constraints.maxWidth ~/ 200)
                          : 2,
                    ),
                    itemBuilder: (BuildContext context, index) {
                      var userData = suggestionListResponseModel?.data?[index];

                      return OpenContainer<bool>(
                        transitionType: ContainerTransitionType.fade,
                        openBuilder:
                            (BuildContext _, VoidCallback openContainer) {
                          return ProfileDetailsPage(
                            userProfileItem: userData!.toJson(),
                          );
                        },
                        openColor: Theme.of(context).colorScheme.background,
                        closedColor: Theme.of(context).colorScheme.background,
                        closedShape: const RoundedRectangleBorder(),
                        closedElevation: 0.0,
                        closedBuilder:
                            (BuildContext _, VoidCallback openContainer) {
                          bool? isPremium = SuggestionController()
                              .premiumChecked
                              .contains(userData?.id.toString());
                          return Stack(
                            children: [
                              Card(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(4)),
                                        child: /*isPremium
                                        ? AppCachedNetworkImage(
                                            imageUrl: userData?.image ?? "")
                                        :*/
                                            AppCachedNetworkImage(
                                                    imageUrl:
                                                        userData?.image ?? "")
                                                .blurred(
                                          blur: 10,
                                        )),
                                    Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: <Color>[
                                            Color.fromRGBO(0, 0, 0, 0),
                                            Color.fromRGBO(0, 0, 0, 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            (userData?.firstName ?? "") +
                                                " " +
                                                (userData?.lastName ?? ""),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.clip,
                                            softWrap: true,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Visibility(
                                            visible: !isPremium,
                                            child: FilledButton(
                                                onPressed: () {
                                                  String mes =
                                                      "Hello, I want to do regular matching with ${userData?.firstName} ${userData?.lastName} (#${userData?.id})";

                                                  print("Message  : ${mes}");
                                                  var whatsappUrl = Uri.parse(
                                                      "whatsapp://send?phone=${"+85290802890"}" +
                                                          "&text=${Uri.encodeComponent(mes)}");

                                                  try {
                                                    launchUrl(whatsappUrl);
                                                  } catch (e) {
                                                    debugPrint(e.toString());
                                                  }
                                                },
                                                child: Text(
                                                    "Regular".toTranslated())),
                                          ),
                                          Visibility(
                                            visible: true,
                                            child: FilledButton(
                                                onPressed: () async {
                                                  bool? isYes =
                                                      await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PremiumProfileViewAlert(
                                                        name:
                                                            "${userData?.firstName} ${userData?.lastName}",
                                                        imageUrl:
                                                            userData?.image ??
                                                                "",
                                                        id: userData!.id,
                                                      ),
                                                    ),
                                                  );

                                                  //  if (isYes == true) {

                                                  print(
                                                      "Premium Checked : ${SuggestionController().premiumChecked}");
                                                  setState(() {});
                                                  //  }
                                                },
                                                child: Text(
                                                    "Premium".toTranslated())),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
      }),
    );
  }

  void loadData() async {
    var res = await http.get(Uri.parse(
        "http://dating.paksang.com/matched_interest/${userInfo["_id"]}"));

    if (res.statusCode == 200) {
      suggestionListResponseModel =
          SuggestionListResponseModel.fromJson(jsonDecode(res.body));

      SuggestionController().getPremiumCheckedFromLocalDb();

      setState(() {});
    }
  }

  void onInit() async {
    await loadProfileIsDoneApi();
    await loadInterestIsDoneApi();

    loadData();
  }

  loadProfileIsDoneApi() async {
    //http://dating.paksang.com/is_profile_update_done/143
    var res = await http.get(Uri.parse(
        "http://dating.paksang.com/is_profile_update_done/${userInfo["_id"]}"));

    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      isProfileDone = data["isDone"];
      print("isProfileDone : ${isProfileDone}");
      setState(() {});
    }
  }

  loadInterestIsDoneApi() {
    //http://dating.paksang.com/is_interest_update_done/143
    http
        .get(Uri.parse(
            "http://dating.paksang.com/is_interest_update_done/${userInfo["_id"]}"))
        .then((res) {
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        isInterestDone = data["isDone"];

        print("isInterestDone : ${isInterestDone}");
        setState(() {});
      }
    });
  }
}
