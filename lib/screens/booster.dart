import 'package:custom_timer/custom_timer.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:photo_card_swiper/models/photo_card.dart';
import '../common/services/data_transport.dart' as data_transport;
import '../common/services/utils.dart';
import '../common/widgets/common.dart';
import 'purchase.dart';

class BoosterPage extends StatefulWidget {
  const BoosterPage({super.key});

  @override
  BoosterPageState createState() => BoosterPageState();
}

class BoosterPageState extends State<BoosterPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  PhotoCard? encounterCard;
  Map encounteredUserData = {};
  bool isLoaded = false;
  bool isCountUpdating = false;
  bool encounterAvailability = false;
  bool isListenerSet = false;
  Map boosterInfo = {};
  int remainingBoosterTime = 0;
  late CustomTimerController _customTimerController;
  int? creditsRemaining;
  @override
  void initState() {
    if (mounted) {
      _customTimerController = CustomTimerController(
        vsync: this,
        begin: const Duration(),
        end: const Duration(),
      );
      getBoosterInfo();
    }
    super.initState();
  }

  getBoosterInfo() async {
    setState(() {
      isCountUpdating = true;
    });
    return data_transport.get(
      'get-booster-info',
      context: context,
      onSuccess: (responseData) {
        _customTimerController.finish();
        setState(() {
          isLoaded = true;
          isCountUpdating = false;
          boosterInfo = getItemValue(responseData, 'data');
          remainingBoosterTime = boosterInfo['remaining_booster_time'];
        });
        if (remainingBoosterTime > 0) {
          _customTimerController.end = const Duration();
          _customTimerController.begin = Duration(
            seconds: remainingBoosterTime,
          );
          _customTimerController.start();
          if (!isListenerSet) {
            // set the listener
            _customTimerController.state.addListener(() {
              if (_customTimerController.state.value ==
                  CustomTimerState.finished) {
                setState(() {
                  remainingBoosterTime = 0;
                  _customTimerController.finish();
                });
              }
              setState(() {
                isListenerSet = true;
              });
            });
          }
        }
      },
    );
  }

  @override
  void dispose() {
    if (mounted) {
      _customTimerController.dispose();
      // remove all receivers from the environment
      FBroadcast.instance().unregister(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: mainAppBarWidget(
          context: context, title: 'Boost my Profile', actionWidgets: []),
      body: !isLoaded
          ? const Center(child: AppItemProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (remainingBoosterTime > 0)
                    Column(
                      children: [
                        const Icon(
                          Icons.bolt,
                          size: 164,
                        ),
                        const Text(
                          'Your profile is boosted for',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        CustomTimer(
                            controller: _customTimerController,
                            builder: (state, time) {
                              return Text(
                                "${time.hours}:${time.minutes}:${time.seconds}",
                                style: TextStyle(
                                  fontSize: 62,
                                  color: Theme.of(context).primaryColor,
                                ),
                              );
                            }),
                        const Divider(),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      textAlign: TextAlign.center,
                      "By boosting your profile you will be a part of featured user and will a get priority in search and random users. It will costs you ${getItemValue(boosterInfo, 'booster_price')} credits for immediate ${getItemValue(boosterInfo, 'booster_period')} minutes",
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (isCountUpdating)
                    const AppItemProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: (() {
                        data_transport.post(
                          'boost-profile',
                          thenCallback: (responseData) {
                            if (getItemValue(responseData, 'reaction') == 2) {
                              setState(() {
                                creditsRemaining = getItemValue(
                                    responseData, 'data.creditsRemaining',
                                    fallbackValue: '');
                              });
                              showToastMessage(
                                context,
                                getItemValue(
                                  responseData,
                                  'data.message',
                                  fallbackValue: '',
                                ),
                                type: 'error',
                              );
                            }
                          },
                          onSuccess: (responseData) async {
                            FBroadcast.instance().broadcast(
                              "local.broadcast.credits_update",
                              value: {},
                            );
                            await getBoosterInfo();
                          },
                        );
                      }),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              (remainingBoosterTime > 0)
                                  ? 'Boost Again'
                                  : 'Boost my Profile',
                              style: const TextStyle(
                                fontSize: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (creditsRemaining != null && creditsRemaining! <= 0)
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
    );
  }
}
