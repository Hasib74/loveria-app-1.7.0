import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_card_swiper/models/photo_card.dart';
import 'package:photo_card_swiper/photo_card_swiper.dart';
import '../common/services/data_transport.dart' as data_transport;
import '../common/services/utils.dart';
import '../common/widgets/common.dart';
import 'profile_details.dart';
import 'user_common.dart';

class EncounterPage extends StatefulWidget {
  const EncounterPage({super.key});

  @override
  EncounterPageState createState() => EncounterPageState();
}

class EncounterPageState extends State<EncounterPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  PhotoCard? encounterCard;
  Map encounteredUserData = {};
  bool isLoaded = false;
  bool encounterAvailability = false;
  List<PhotoCard> encounterCards = [];
  @override
  void initState() {
    if (mounted) {
      getEncounterData();
    }
    super.initState();
  }

  /// get initial encounter data
  getEncounterData() {
    data_transport.get(
      'encounter-data',
      context: context,
      onSuccess: (responseData) {
        setState(() {
          isLoaded = true;
          encounterAvailability =
              getItemValue(responseData, 'data.encounterAvailability');
          var tempEncounteredUserData = getItemValue(
            responseData,
            'data.randomUserData',
            fallbackValue: {},
          );
          if (tempEncounteredUserData is List) {
            encounteredUserData = {};
          } else {
            encounteredUserData = tempEncounteredUserData;
          }

          if (encounteredUserData.isNotEmpty) {
            encounterCards = [
              PhotoCard(
                cardId: encounteredUserData['_uid'],
                description: Column(
                  children: [
                    Text(
                      encounteredUserData['userFullName'],
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const Divider(
                      height: 10,
                    ),
                    Text(encounteredUserData['detailString'] ?? ''),
                    Text(encounteredUserData['countryName'] ?? ''),
                  ],
                ),
                itemWidget: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    AppCachedNetworkImage(
                      height: double.infinity,
                      imageUrl: encounteredUserData['userCoverUrl'],
                    ),
                    Positioned(
                      bottom: 10,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: appCachedNetworkImageProvider(
                          imageUrl: encounteredUserData['userImageUrl'],
                        ),
                      ),
                    ),
                    if ((encounteredUserData['isPremiumUser'] != null) &&
                        encounteredUserData['isPremiumUser'])
                      const Positioned(
                        top: 10,
                        right: 10,
                        child: PremiumBadgeWidget(),
                      ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: ((encounteredUserData['userOnlineStatus'] == 1)
                              ? Colors.green
                              : (encounteredUserData['userOnlineStatus'] == 2
                                  ? Colors.orange
                                  : Colors.red)),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                isLocalImage: false,
              ),
            ];
          }
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: !isLoaded
          ? const Center(child: AppItemProgressIndicator())
          : encounterAvailability == false
              ? const BePremiumAlertInfo()
              : (encounteredUserData.isNotEmpty
                  ? PhotoCardSwiper(
                      cardBgColor: const Color.fromARGB(100, 0, 0, 0),
                      photos: encounterCards,
                      showLoading: true,
                      hideCenterButton: false,
                      leftButtonIcon: CupertinoIcons.heart_slash_circle_fill,
                      rightButtonIcon: CupertinoIcons.heart_circle_fill,
                      centerButtonIcon: Icons.chevron_right,
                      onCardTap: (params) {
                        navigatePage(
                            context,
                            ProfileDetailsPage(
                              userProfileItem: {
                                'fullName': encounteredUserData['userFullName'],
                                'profileImage':
                                    encounteredUserData['userImageUrl'],
                                'coverImage':
                                    encounteredUserData['userCoverUrl'],
                                'id': encounteredUserData['_id'],
                                'username': encounteredUserData['username'],
                              },
                            ));
                      },
                      cardSwiped: (CardActionDirection direction, int index) {
                        if (direction == CardActionDirection.cardCenterAction) {
                          data_transport.post(
                              "encounters/${encounteredUserData['_uid']}/skip-encounter-user",
                              context: context, onSuccess: (responseData) {
                            getEncounterData();
                          });
                        }
                      },
                      rightButtonAction: () {
                        // encounteredUserData
                        data_transport.post(
                            "encounters/${encounteredUserData['_uid']}/1/user-encounter-like-dislike",
                            context: context, onSuccess: (responseData) {
                          getEncounterData();
                        });
                      },
                      leftButtonAction: () {
                        // encounteredUserData
                        data_transport.post(
                            "encounters/${encounteredUserData['_uid']}/2/user-encounter-like-dislike",
                            context: context, onSuccess: (responseData) {
                          getEncounterData();
                        });
                      },
                    )
                  : const Center(
                      child: Text(
                          'Your daily limit for encounters may exceed or there are no users to show.'),
                    )),
    );
  }
}
