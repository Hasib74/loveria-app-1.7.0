import 'dart:async';
import 'dart:convert';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:expandable/expandable.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loveria/common/language/language_extension.dart';
import 'package:loveria/generated/assets.dart';
import 'package:loveria/screens/myInterest/screen/my_interest_screen.dart';
import 'package:loveria/screens/schedule/schedular.dart';
import 'package:loveria/screens/suggestion/screen/suggestion_list_screen.dart';
import 'banner_screen.dart';
import 'messenger/audio_video_calls.dart';
import 'user/login.dart';
import '../common/services/auth.dart';
import 'encounter.dart';
import '../common/services/utils.dart';
import '../common/widgets/common.dart';
import 'messenger/messenger.dart';
import 'my_photos.dart';
import 'profile_details.dart';
import 'users_list.dart';
import '../common/services/auth.dart' as auth;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class LandingPage extends StatefulWidget {
  const LandingPage(
      {Key? key, this.initialNotificationCount = 0, this.initialActiveTab = 0})
      : super(key: key);

  final int initialNotificationCount;
  final int initialActiveTab;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

int notificationCount = 0;
String tabTitle = '';

class _LandingPageState extends State<LandingPage> with WidgetsBindingObserver {
  Future? _fetchMyData;
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  InterstitialAd? _interstitialAd;
  String _adUnitId = '';
  bool enableAds = true;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      if (configItem('ads.interstitial_id.enable', fallbackValue: false) ==
          true) {
        _adUnitId = configItem(
            'ads.interstitial_id.${isIOSPlatform() ? 'ios' : 'android'}_ad_unit_id',
            fallbackValue: '');
      }

      setTabTitle(widget.initialActiveTab);
      notificationCount = widget.initialNotificationCount;
      _fetchMyData = checkUserLoggedIn();
      initPlatformState();
      FBroadcast.instance().register('local.broadcast.notification_count',
          (eventNotificationCount, callback) {
        setState(() {
          notificationCount = eventNotificationCount;
        });
      });
      enableAds = (_adUnitId != '') &&
          (getAuthInfo(
                  'additional_user_info.features_availability.no_ads', false) !=
              true);
      WidgetsBinding.instance.addObserver(this);
      if (enableAds) {
        Future.delayed(
            const Duration(
              seconds: 15,
            ), () {
          // initial ad load
          _loadInterstitialAd();
          _interstitialAd?.show();
        });
        // show add every 3 minutes
        Timer.periodic(
            Duration(
                seconds: configItem(
              'ads.interstitial_id.frequency_in_seconds',
              fallbackValue: 180,
            )), (timer) {
          _loadInterstitialAd();
          _interstitialAd?.show();
        });
      }
    }
  }

  @override
  void dispose() {
    if (mounted) {
      WidgetsBinding.instance.removeObserver(this);

      /// remove all receivers from the environment
      FBroadcast.instance().unregister(this);
      _interstitialAd?.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      auth.refreshUserInfo();
    }
  }

  initPlatformState() async {
    await pusher.init(
      apiKey: configItem('services.pusher.apiKey'),
      cluster: configItem('services.pusher.cluster'),
      logToConsole: configItem('debug'),
    );
    await pusher.connect();
    pusher.unsubscribe(channelName: "channel-${getAuthInfo('_uid')}");
    await pusher.subscribe(
        channelName: "channel-${getAuthInfo('_uid')}",
        onEvent: (eventResponseData) {
          FBroadcast.instance().broadcast(
            "local.broadcast.user_channel",
            value: eventResponseData,
          );
          Map receivedData = jsonDecode(eventResponseData.data);
          if ((receivedData['showNotification'] != null) &&
              (receivedData['showNotification'] == true)) {
            showToastMessage(context,
                receivedData['notificationMessage'] ?? receivedData['message']);
          }
          int notificationCount = getItemValue(
              receivedData, 'getNotificationList.notificationCount',
              fallbackValue: -1);
          if (notificationCount >= 0) {
            FBroadcast.instance().broadcast(
              "local.broadcast.notification_count",
              value: notificationCount,
            );
          }
          if (eventResponseData.eventName == 'event.call.notification') {
            if (receivedData['type'] == 'caller-calling') {
              SmartDialog.dismiss();
              SmartDialog.show(builder: (ctx) {
                return AudioVideoCall(connectionInfo: receivedData);
              });
            }
          }
        });
  }

  checkUserLoggedIn() async {
    await auth.redirectIfUnauthenticated(context);
    return isLoggedIn();
  }

  setTabTitle(i) {
    setState(() {
      switch (i) {
        case 0:
          tabTitle = 'Home'.toTranslated();
          break;
        case 1:
          tabTitle = 'My Profile'.toTranslated();
          break;
        case 2:
          //   tabTitle = 'Encounter';
          tabTitle = 'My Interest'.toTranslated();
          break;
        case 3:
          tabTitle = 'Schedule'.toTranslated();
          break;
        case 4:
          tabTitle = 'My Matches'.toTranslated();
          break;
        default:
      }
    });
  }

  /// Loads an interstitial ad.
  void _loadInterstitialAd() {
    InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (InterstitialAd ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            pr('InterstitialAd failed to load: $error');
          },
        ));
  }

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawerEnableOpenDragGesture: false,
      onDrawerChanged: (isOpened) {
        print('Drawer is opened : $isOpened');

        setState(() {
          setTabTitle(selectedTab);
        });
      },
      drawer: Container(
          color: Colors.transparent,
          child: Row(
            children: [
              Expanded(flex: 3, child: AppDrawer()),
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    print('Close drawer ....');
                    Navigator.pop(context, true);
                    scaffoldKey.currentState!.openEndDrawer();
                  },
                  child: Container(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.1),
                  ),
                ),
              ),
            ],
          )),
      appBar: mainAppBarWidget(
        title: tabTitle,
        context: context,
        notificationCount: notificationCount,
      ),
      body: Stack(
        children: [
          FutureBuilder(
              future: _fetchMyData,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData &&
                    (snapshot.connectionState == ConnectionState.done)) {
                  if (snapshot.data == true) {
                    return DefaultTabController(
                      length: 5,
                      initialIndex: widget.initialActiveTab,
                      child: Scaffold(
                        body: Column(
                          children: [
                            Expanded(
                              child: TabBarView(
                                children: [
                                  //UsersListPage(),

                                  BannerScreen(),

                                  ProfileDetailsPage(),
                                  //   EncounterPage(),

                                  MyInterestScreen(
                                    hasAppBar: false,
                                  ),

                                  SchedulerPage(),
                                  //MessengerPage(),
                                  /*  UsersListPage(
                                    title: 'Who liked me',
                                    pageBaseUrl: 'who-liked-me',
                                    hasAppBar: false,
                                  ),
*/
                                  SuggestionListScreen(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        bottomNavigationBar: ConvexAppBar(
                          color: Colors.white,
                          activeColor: Theme.of(context).primaryColor,
                          backgroundColor:
                              Theme.of(context).colorScheme.background,
                          items: const [
                            // Find
                            /*   TabItem(
                              icon: CupertinoIcons.search,
                            ),*/
                            // my profile

                            // encounter
                            TabItem(
                              icon: CupertinoIcons.home,
                            ),

                            TabItem(
                              icon: CupertinoIcons.person,
                            ),

                            TabItem(
                              icon: CupertinoIcons.heart_slash_circle,
                            ),
                            // my photos
                            TabItem(
                              icon: CupertinoIcons.calendar_badge_minus,
                            ),
                            // messenger
                            TabItem(
                              icon: CupertinoIcons.heart,
                            ),

                            /*  TabItem(
                              icon: SvgPicture.asset(
                                Assets.imagesMyInterest,
                                color:   Colors.white,
                                width: 24,
                                height: 24,
                              ),
                            ),*/
                          ],
                          onTabNotify: (int i) {
                            selectedTab = i;

                            setTabTitle(i);
                            return true;
                          },
                        ),
                      ),
                    );
                  } else {
                    return const LoginPage();
                  }
                } else {
                  return const Align(
                    alignment: Alignment.center,
                    child: AppItemProgressIndicator(),
                  );
                }
              }),
        ],
      ),
    );
  }
}
