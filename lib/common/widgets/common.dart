import 'dart:ui';

import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:loveria/common/language/language_controller.dart';
import 'package:loveria/common/language/language_extension.dart';
import 'package:loveria/generated/assets.dart';
import 'package:loveria/screens/myInterest/screen/my_interest_screen.dart';
import '../../screens/premium.dart';
import '../../screens/user/change_email.dart';
import '../../screens/user/change_password.dart';
import '../../screens/notification_list.dart';
import '../../screens/about.dart';
import '../../screens/booster.dart';
import '../../screens/landing.dart';
import '../../screens/profile_image_update.dart';
import '../../screens/user/user_settings.dart';
import '../../screens/user_common.dart';
import '../../screens/users_list.dart';
import '../../screens/wallet_transaction_list.dart';
import '../services/utils.dart';
import '../../support/app_theme.dart' as app_theme;
import './../services/data_transport.dart' as data_transport;
import './../services/auth.dart' as auth;

/// App background Image
/// Widget
class AppBackgroundImage extends StatelessWidget {
  const AppBackgroundImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: app_theme.primaryGradient,
        image: DecorationImage(
          opacity: 0.4,
          image: app_theme.backgroundImage,
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 3,
          sigmaY: 3,
        ),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
        ),
      ),
    );
  }
}

///
/// App Logo Widget
class AppLogo extends StatelessWidget {
  final double height;

  const AppLogo({Key? key, this.height = 250}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, child: app_theme.logoImage);
  }
}

class AppDrawer extends StatefulWidget {
  GlobalKey<ScaffoldState>? scaffoldKey = GlobalKey<ScaffoldState>();

  AppDrawer({
    Key? key,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: app_theme.sidebarBgColor,
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: GestureDetector(
              onTap: () {
                navigatePage(
                  context,
                  const LandingPage(
                    initialActiveTab: 1,
                  ),
                );
              },
              child: Text(
                  '${auth.getAuthInfo('full_name')} (${auth.getAuthInfo('username')})'),
            ),
            accountEmail: Text(auth.getAuthInfo('email')),
            currentAccountPicture: GestureDetector(
              onTap: () {
                navigatePage(
                    context,
                    ProfileImageView(
                      title: Text('Profile Photo'.toTranslated()),
                      imageUrl: auth.getAuthInfo('profile_picture_url'),
                      actions: [
                        IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Upload New Photos'.toTranslated(),
                            onPressed: () {
                              navigatePage(
                                context,
                                const ProfileImageUpdatePage(),
                              );
                            }),
                      ],
                    ));
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: appCachedNetworkImageProvider(
                      imageUrl: auth.getAuthInfo('profile_picture_url'),
                    ),
                  ),
                  if (auth.getAuthInfo('is_premium'))
                    Positioned(
                      top: 8,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          navigatePage(context, const PremiumPage());
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(14.0),
                          child: PremiumBadgeWidget(
                            size: 32,
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
            decoration: const BoxDecoration(),
            otherAccountsPictures: [
              GestureDetector(
                onTap: () {
                  navigatePage(
                    context,
                    const AboutPage(),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: AppLogo(),
                ),
              ),
              // AppLogo(),
            ],
            otherAccountsPicturesSize: const Size.square(80),
          ),
          if (!auth.getAuthInfo('is_premium'))
            /* ListTile(
              leading: const PremiumBadgeWidget(
                size: 24,
                preventTap: true,
              ),
              title: Text(
                'Be Premium',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onTap: () {
                // Then close the drawer
                Navigator.pop(context);
                navigatePage(context, const PremiumPage());
              },
            ),*/
            /* ListTile(
            leading: const Icon(
              Icons.star,
              // color: Theme.of(context).primaryColor,
            ),
            title: Text(
              'Featured Users',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              navigatePage(
                  context,
                  UsersListPage(
                    title: 'Featured Users',
                    pageBaseUrl: 'get-featured-user-data',
                  ));
            },
          ),*/
            /*ListTile(
            leading: const Icon(
              Icons.blender,
              // color: Theme.of(context).primaryColor,
            ),
            title: const Text(
              'Random Users',
              style: TextStyle(
                  // color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              navigatePage(
                  context,
                  UsersListPage(
                    title: 'Random Users',
                    pageBaseUrl: 'random-user',
                  ));
            },
          ),*/
            /* ListTile(
            leading: const Icon(Icons.wallet),
            title: const Text("Credit Wallet"),
            onTap: () {
              Navigator.pop(context);
              navigatePage(
                context,
                const WalletTransactionListPage(),
              );
            },
          ),*/
            /* ListTile(
              leading: const Icon(Icons.thumb_up),
              title: Row(
                children: [
                  const Text('Who liked me'),
                  if (auth.getAuthInfo(
                          'additional_user_info.is_premium_only.show_likes',
                          false) ==
                      true)
                    const PremiumBadgeWidget(
                      size: 24,
                    )
                ],
              ),
              onTap: () {
                // Then close the drawer
                Navigator.pop(context);
                navigatePage(
                    context,
                    UsersListPage(
                      title: 'Who liked me',
                      pageBaseUrl: 'who-liked-me',
                    ));
              },
            ),*/
            /*  ListTile(
            leading: SvgPicture.asset(
              Assets.imagesMyInterest,
              color: Colors.white,
              width: 24,
              height: 24,
            ),
            title: Row(
              children: [
                const Text('My Interests'),
                if (auth.getAuthInfo(
                        'additional_user_info.is_premium_only.show_likes',
                        false) ==
                    true)
                  const PremiumBadgeWidget(
                    size: 24,
                  )
              ],
            ),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);

              navigatePage(context, MyInterestScreen());
            },
          ),*/
            /*      ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('Mutual likes'),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              navigatePage(
                  context,
                  UsersListPage(
                    title: 'Mutual likes',
                    pageBaseUrl: 'mutual-likes',
                  ));
            },
          ),*/
            /*    ListTile(
            leading: const Icon(CupertinoIcons.heart),
            title: const Text('My Likes'),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              navigatePage(
                  context,
                  UsersListPage(
                    title: 'My Likes',
                    pageBaseUrl: 'my-likes',
                  ));
            },
          ),*/
            /*   ListTile(
            leading: const Icon(CupertinoIcons.heart_slash),
            title: const Text('My Dislikes'),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              navigatePage(
                  context,
                  UsersListPage(
                    title: 'My Dislikes',
                    pageBaseUrl: 'disliked',
                  ));
            },
          ),*/
            Visibility(
              visible: false,
              child: ListTile(
                leading: const Icon(CupertinoIcons.heart),
                title: const Text('Visitors'),
                onTap: () {
                  // Then close the drawer
                  Navigator.pop(context);
                  navigatePage(
                      context,
                      UsersListPage(
                        title: 'Visitors',
                        pageBaseUrl: 'visitors',
                      ));
                },
              ),
            ),
          /*       ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Blocked Users'),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              navigatePage(
                  context,
                  UsersListPage(
                    title: 'Blocked Users',
                    pageBaseUrl: 'blocked-users-list',
                  ));
            },
          ),
          const Divider(),*/
          ListTile(
            leading: const Icon(Icons.password),
            title: Text('Change Password'.toTranslated()),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              navigatePage(
                context,
                const ChangePasswordPage(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text('Change Email'.toTranslated()),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              navigatePage(
                context,
                const ChangeEmailPage(),
              );
            },
          ),
          Row(
            children: [
              SizedBox(
                width: 16,
              ),
              Icon(Icons.language),
              SizedBox(
                width: 16,
              ),
              Text(
                "Language".toTranslated(),
                style: TextStyle(color: app_theme.white),
              ),
              SizedBox(
                width: 16,
              ),
              FlutterSwitch(
                showOnOff: true,
                value: AppLanguageController().isEnglish ?? true,
                activeIcon: const Text("EN"),
                activeText: "EN",
                inactiveIcon: const Text("CH"),
                inactiveText: "CH",
                inactiveColor: Colors.pink,
                activeColor: Colors.pink,
                activeTextFontWeight: FontWeight.normal,
                inactiveTextFontWeight: FontWeight.normal,
                onToggle: (val) {
                  setState(() {
                    AppLanguageController().isEnglish = val;

                    print('Language changed to ${val ? 'EN' : 'CH'}');
                  });

                  AppLanguageController().storeLanguageTypeIntoLocal();
                },
              ),
            ],
          ),
          /*ListTile(
            leading: const Icon(Icons.settings),
            title: Text('Settings'.toTranslated()),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              navigatePage(
                context,
                const UserSettingsPage(),
              );
            },
          ),*/
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('Logout'.toTranslated()),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              data_transport.post(
                'user/logout',
              );
              auth.logout().then((response) {
                auth.redirectIfUnauthenticated(context);
              });
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: Text(
              'Delete Account'.toTranslated(),
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              data_transport.post(
                'user/logout',
              );
              auth.logout().then((response) {
                auth.redirectIfUnauthenticated(context);
              });
            },
          ),
        ],
      ),
    );
  }
}

class PageTitle extends StatelessWidget {
  final String title;

  const PageTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30, top: 25),
      child: Text(
        title,
        style: const TextStyle(fontSize: 30, color: app_theme.white),
      ),
    );
  }
}

/* class RequestProgressIndicator extends StatelessWidget {
  final String message;
  final Color textColor;
  const RequestProgressIndicator(
      {Key? key,
      this.message = 'Please wait ...',
      this.textColor = app_theme.white})
      : super(key: key);

  // final message = 'Please wait ...';

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
} */

class AppItemProgressIndicator extends StatelessWidget {
  final double? size;

  const AppItemProgressIndicator({Key? key, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        (size != null)
            ? Center(
                child: SizedBox(
                  height: size,
                  width: size,
                  child: const CircularProgressIndicator.adaptive(
                    strokeWidth: 1.5,
                  ),
                ),
              )
            : const CircularProgressIndicator.adaptive()
      ],
    );
  }
}

PreferredSizeWidget innerAppBar(
    {required String title, List<Widget>? actions}) {
  return AppBar(
    // backgroundColor: app_theme.topAndBottomBar,
    elevation: 0.0,
    title: Text(title),
    actions: actions,
  );
}

/// confirmation dialog
///
showActionableDialog(
  BuildContext context, {
  String title = 'Are you sure?',
  Widget? description,
  String? confirmActionText,
  String? cancelActionText,
  Function? onConfirm,
  VoidCallback? onCancel,
}) {
  // show the dialog
  if (isIOSPlatform()) {
    CupertinoAlertDialog iosDialog = CupertinoAlertDialog(
      title: Text(title),
      content: description, //(description != null) ? Text(description) : null,
      actions: <Widget>[
        if (confirmActionText != null)
          CupertinoDialogAction(
            child: Text(
              confirmActionText,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
            onPressed: () {
              if (onConfirm != null) {
                if (onConfirm() != false) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        if (cancelActionText != null)
          CupertinoDialogAction(
            child: Text(cancelActionText,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).secondaryHeaderColor)),
            onPressed: () {
              Navigator.of(context).pop();
              if (onCancel != null) onCancel();
            },
          ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return iosDialog;
      },
    );
  } else {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: description, //(description != null) ? Text(description) : null,
      actions: [
        if (cancelActionText != null)
          TextButton(
            child: Text(cancelActionText,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).secondaryHeaderColor)),
            onPressed: () {
              Navigator.of(context).pop(); // dismiss dialog
              if (onCancel != null) onCancel();
            },
          ),
        if (confirmActionText != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // dismiss dialog
              if (onConfirm != null) onConfirm();
            },
            child: Text(
              confirmActionText,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
          ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    Key? key,
    required this.imageUrl,
    this.height = 300,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => const AppItemProgressIndicator(
        size: 20,
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      height: height,
      width: width,
      // alignment: Alignment.center,
      fit: fit,
    );
  }
}

appCachedNetworkImageProvider({imageUrl}) {
  return CachedNetworkImageProvider(imageUrl);
}

AppBar mainAppBarWidget(
    {String? title,
    List<Widget>? actionWidgets,
    int notificationCount = 0,
    required BuildContext context}) {
  return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      toolbarOpacity: 0.6,
      /*   leading: Builder(builder: (context) {
              return IconButton(
                icon: Icon(CupertinoIcons.list_dash),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            }), */
      // backgroundColor: app_theme.topAndBottomBar,
      elevation: 0,
      title: title != null
          ? Text(title)
          : Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: SizedBox(
                height: 45,
                width: 80,
                child: app_theme.logoImage,
              ),
            ),
      /*     title: Text(
              configItem('appTitle'),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w100,
              ),
            ), */
      centerTitle: false,
      actions: actionWidgets ??
          <Widget>[
            /* IconButton(
              icon: const Icon(Icons.bolt),
              tooltip: 'Boost Profile',
              onPressed: () {
                navigatePage(context, const BoosterPage());
              },
            ),*/
            /* IconButton(
              icon: const Icon(Icons.wallet),
              tooltip: 'Credit Wallet',
              onPressed: () {
                navigatePage(context, const WalletTransactionListPage());
              },
            ),*/
            IconButton(
              icon: Container(
                margin: const EdgeInsets.only(right: 30),
                child: badges.Badge(
                  badgeAnimation: const badges.BadgeAnimation.fade(),
                  position: badges.BadgePosition.topEnd(end: -18),
                  badgeStyle: badges.BadgeStyle(
                      badgeColor: Theme.of(context).primaryColor),
                  showBadge: notificationCount > 0,
                  badgeContent: Text(notificationCount.toString()),
                  child: const Icon(CupertinoIcons.bell),
                ),
              ),
              tooltip: 'Show Snackbar',
              onPressed: () {
                navigatePage(context, const NotificationListPage());
              },
            ),
          ]);
}

class PremiumBadgeWidget extends StatelessWidget {
  const PremiumBadgeWidget({
    Key? key,
    this.size = 48,
    this.preventTap = false,
  }) : super(key: key);
  final double size;
  final bool preventTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: preventTap
          ? null
          : () {
              navigatePage(context, const PremiumPage());
            },
      child: SizedBox(
        width: size,
        height: size,
        // ignore: prefer_const_constructors
        child: app_theme.premiumBadge,
      ),
    );
  }
}
