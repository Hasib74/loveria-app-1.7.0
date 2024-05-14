import 'package:flutter/material.dart';
import 'package:photo_card_swiper/models/photo_card.dart';
import '../common/services/data_transport.dart' as data_transport;
import '../common/services/auth.dart' as auth;
import '../support/app_theme.dart' as app_theme;
import '../common/services/utils.dart';
import '../common/widgets/common.dart';
import 'purchase.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  PremiumPageState createState() => PremiumPageState();
}

class PremiumPageState extends State<PremiumPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  PhotoCard? encounterCard;
  Map encounteredUserData = {};
  bool isLoaded = false;
  bool isCountUpdating = false;
  bool isListenerSet = false;
  Map premiumData = {};
  Map premiumPlansData = {};
  Map premiumFeatures = {};
  Map userSubscriptionData = {};
  int? creditsRemaining;
  String? selectedPackage;
  @override
  void initState() {
    if (mounted) {
      getPremiumPlansInfo();
    }
    super.initState();
  }

  getPremiumPlansInfo() async {
    setState(() {
      isCountUpdating = true;
    });
    return data_transport.get(
      'premium-plan/premium-plan-data',
      context: context,
      onSuccess: (responseData) {
        setState(() {
          premiumData = getItemValue(responseData, 'data.premiumPlanData');
          premiumPlansData = getItemValue(premiumData, 'premiumPlans');
          premiumFeatures = getItemValue(premiumData, 'premiumFeature');
          if (getItemValue(premiumData, 'userSubscriptionData').isNotEmpty) {
            userSubscriptionData =
                getItemValue(premiumData, 'userSubscriptionData');
          }
          isLoaded = true;
        });
      },
    );
  }

  @override
  void dispose() {
    if (mounted) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Premium'),
      ),
      body: !isLoaded
          ? const Center(child: AppItemProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: PremiumBadgeWidget(
                        size: 148,
                        preventTap: true,
                      ),
                    ),
                    if (premiumData['isPremiumUser'])
                      Column(
                        children: [
                          const Text('You are premium user'),
                          const Divider(
                            height: 20,
                            thickness: 0.01,
                          ),
                          Text(
                            'Premium Membership Expiry',
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor),
                          ),
                          Text(userSubscriptionData['expiry_at'].toString()),
                          const Divider(
                            height: 20,
                            thickness: 0.1,
                          ),
                        ],
                      ),
                    for (String featuresItemIndex in premiumFeatures.keys)
                      Builder(builder: (context) {
                        Map featureItem = premiumFeatures[featuresItemIndex];
                        if (featureItem['enable']) {
                          return ListTile(
                            leading: const Icon(
                              Icons.star,
                              color: Colors.yellowAccent,
                            ),
                            title: Text(featureItem['title']),
                          );
                        }
                        return Container();
                      }),
                    const Divider(
                      height: 20,
                      thickness: 0.2,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (String itemIndex in premiumPlansData.keys)
                            Builder(builder: (context) {
                              Map item = premiumPlansData[itemIndex];
                              if (item['enable']) {
                                return RadioListTile(
                                  title: Text(item['title'].toString()),
                                  secondary: Text(
                                    '${item['price']} credits',
                                  ),
                                  value: itemIndex,
                                  groupValue: selectedPackage,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedPackage = value.toString();
                                    });
                                  },
                                );
                              } else {
                                return Container();
                              }
                            }),
                          ElevatedButton(
                            onPressed: (() {
                              if (selectedPackage == null) {
                                showActionableDialog(context,
                                    title: 'Select Plan',
                                    description:
                                        const Text('Please select a plan'),
                                    confirmActionText: 'OK');
                                return;
                              }
                              data_transport.post(
                                'premium-plan/buy-plans',
                                inputData: {
                                  'selectedPlan': {
                                    'select_plan': selectedPackage
                                  }
                                },
                                // context: context,
                                thenCallback: (responseData) {
                                  if (getItemValue(responseData, 'reaction') ==
                                      1) {
                                    showSuccessMessage(
                                        context,
                                        getItemValue(
                                            responseData, 'data.message',
                                            fallbackValue: ''));
                                  } else {
                                    showToastMessage(
                                      context,
                                      getItemValue(responseData, 'data.message',
                                          fallbackValue: ''),
                                      type: 'error',
                                    );
                                  }
                                },
                                onSuccess: (responseData) async {
                                  auth.refreshUserInfo();
                                  await getPremiumPlansInfo();
                                },
                              );
                            }),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: app_theme.secondary,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                premiumData['isPremiumUser']
                                    ? 'Extend Premium Membership'
                                    : 'Be Premium Now',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                navigatePage(
                                  context,
                                  const PurchasePage(),
                                );
                              },
                              child: const Text('Buy Credits'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
