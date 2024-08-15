import 'dart:convert';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../../common/services/auth.dart';
import '../../common/services/data_transport.dart' as data_transport;
import '../../common/services/utils.dart';
import '../../common/widgets/common.dart';
import 'audio_video_calls.dart';
import '../profile_details.dart';
import '../user_common.dart';
import 'package:fbroadcast/fbroadcast.dart';

class MessengerChatListPage extends StatefulWidget {
  const MessengerChatListPage({Key? key, required this.sourceElement})
      : super(key: key);
  final Map sourceElement;
  @override
  State<MessengerChatListPage> createState() => _MessengerChatListPageState();
}

class _MessengerChatListPageState extends State<MessengerChatListPage> {
  late int targetUserId = 0;
  bool enableAudioVideoLinks = false;
  bool allowAudioCall = false;
  bool allowVideoCall = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      targetUserId = widget.sourceElement['user_id'] ??
          widget.sourceElement['_id'] ??
          widget.sourceElement['id'];
    });
  }

  void setAudioVideoLinksStatus(
      {enableAudioVideoLinksValue, allowAudioCallValue, allowVideoCallValue}) {
    setState(() {
      enableAudioVideoLinks = enableAudioVideoLinksValue;
      allowAudioCall = allowAudioCallValue;
      allowVideoCall = allowVideoCallValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              "https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(210, 0, 0, 0),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 0,
          title: Row(
            children: [
              GestureDetector(
                onTap: () => navigatePage(
                    context,
                    ProfileImageView(
                        title: Text(widget.sourceElement['user_full_name']),
                        imageUrl: widget.sourceElement['profile_picture'])),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    widget.sourceElement['profile_picture'].toString(),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => navigatePage(
                    context,
                    ProfileDetailsPage(
                      userProfileItem: {
                        'fullName':
                            widget.sourceElement['user_full_name'] ?? '',
                        'username': widget.sourceElement['username'] ?? '',
                        'profileImage':
                            widget.sourceElement['profile_picture'] ?? '',
                        'coverImage': widget.sourceElement['cover_photo'] ?? '',
                        'id': widget.sourceElement['user_id'] ?? '',
                      },
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.sourceElement['user_full_name'],
                    ),
                  ),
                ),
              ),
            ],
          ),
          centerTitle: false,
          actions: [
            if (allowVideoCall)
              IconButton(
                onPressed: !enableAudioVideoLinks
                    ? null
                    : () {
                        data_transport.post(
                            'messenger/${widget.sourceElement["user_uid"] ?? targetUserId}/video/call-initialize',
                            thenCallback: (responseData) {
                          if (responseData?['reaction'] != 1) {
                            showActionableDialog(
                              context,
                              title: 'Alert',
                              confirmActionText: 'Ok',
                              description: Text(
                                  getItemValue(responseData, 'data.message')),
                            );
                          } else {
                            navigatePage(
                              context,
                              AudioVideoCall(
                                isIncomingCall: false,
                                initiateCall: true,
                                connectionInfo:
                                    getItemValue(responseData, 'data'),
                              ),
                            );
                          }
                        });
                      },
                icon: const Icon(Icons.video_call),
              ),
            if (allowAudioCall)
              IconButton(
                onPressed: !enableAudioVideoLinks
                    ? null
                    : () {
                        data_transport.post(
                            'messenger/${widget.sourceElement["user_uid"] ?? targetUserId}/audio/call-initialize',
                            thenCallback: (responseData) {
                          if (responseData?['reaction'] != 1) {
                            showActionableDialog(
                              context,
                              title: 'Alert',
                              confirmActionText: 'Ok',
                              description: Text(
                                  getItemValue(responseData, 'data.message')),
                            );
                          } else {
                            navigatePage(
                              context,
                              AudioVideoCall(
                                isIncomingCall: false,
                                initiateCall: true,
                                connectionInfo:
                                    getItemValue(responseData, 'data'),
                              ),
                            );
                          }
                        });
                      },
                icon: const Icon(Icons.call),
              ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'delete_all_chat') {
                  showActionableDialog(context,
                      description: const Text(
                          'You want to delete all the chat message of this user?'),
                      onConfirm: () {
                    data_transport.post(
                        'messenger/$targetUserId/delete-all-messages',
                        inputData: {'to_user_id': targetUserId},
                        onSuccess: ((responseData) {
                      showSuccessMessage(
                          context, getItemValue(responseData, 'data.message'));
                      Navigator.pop(context);
                    }));
                  }, confirmActionText: 'Yes', cancelActionText: 'No');
                }
              },
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'delete_all_chat',
                    child: Text('Delete All Chat'),
                  )
                ].toList();
              },
            ),
          ],
        ),
        body: ChatListWidget(
          sourceElement: widget.sourceElement,
          setAudioVideoLinksStatus: setAudioVideoLinksStatus,
        ),
      ),
    );
  }
}

class ChatListWidget extends StatefulWidget {
  const ChatListWidget(
      {Key? key,
      required this.sourceElement,
      required this.setAudioVideoLinksStatus})
      : super(key: key);
  final Map sourceElement;
  final Function setAudioVideoLinksStatus;
  @override
  State<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  int totalCount = 0;
  List chatMessages = [];
  Map dataResponse = {};
  Map userData = {};
  Map mobileAppData = {};
  bool isMessagesLoading = true;
  List<Widget> messagesContainer = [];
  bool isRequestPending = false;
  bool didYouRequestDenied = false;
  final ScrollController _controller = ScrollController();
  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  String loggedInUserUid = getAuthInfo('_uid');
  int loggedInUserId = getAuthInfo('_id');
  String userChannelName = "channel-${getAuthInfo('_uid')}";
  String messageDraft = '';
  final _messageDraftController = TextEditingController();
  late FocusNode messageDraftFocusNode;
  bool emojiShowing = false;
  int targetUserId = 0;
  List stickerListData = [];
  @override
  void initState() {
    super.initState();
    targetUserId =
        widget.sourceElement["user_id"] ?? widget.sourceElement["_id"];
    messageDraftFocusNode = FocusNode();
    data_transport
        .get('messenger/$targetUserId/get-user-messages', context: context)
        .then((dataReceived) {
      setState(() {
        userData = getItemValue(dataReceived, 'data.userData');
        mobileAppData = getItemValue(dataReceived, 'data.mobileAppData');
        widget.setAudioVideoLinksStatus(
          enableAudioVideoLinksValue: getItemValue(
              userData, 'enableAudioVideoLinks',
              fallbackValue: false),
          allowAudioCallValue: getItemValue(mobileAppData, 'allowAudioCall',
              fallbackValue: false),
          allowVideoCallValue: getItemValue(mobileAppData, 'allowVideoCall',
              fallbackValue: false),
        );
        isRequestPending =
            userData['messageRequestStatus'] == 'MESSAGE_REQUEST_RECEIVED';
        didYouRequestDenied =
            userData['messageRequestStatus'] == 'MESSAGE_REQUEST_DECLINE';
        chatMessages = getItemValue(dataReceived, 'data.userConversations')
            .reversed
            .toList();
        isMessagesLoading = false;
        subscribeChannelForChat();
      });
    });
    fetchAvailableStickers();
  }

  fetchAvailableStickers() {
    data_transport.get(
      'messenger/fetch-stickers',
      context: context,
      onSuccess: (responseData) {
        setState(() {
          stickerListData = getItemValue(responseData, 'data.stickers');
        });
      },
    );
  }

  subscribeChannelForChat() {
    FBroadcast.instance().register('local.broadcast.user_channel',
        (eventResponseData, callback) {
      Map receivedData = jsonDecode(eventResponseData.data);
      if (receivedData['messageRequestStatus'] != null) {
        setState(() {
          userData['messageRequestStatus'] =
              receivedData['messageRequestStatus'];
        });
      }
      if ((eventResponseData.eventName == 'event.user.chat.messages') &&
          (receivedData['toUserUid'] == widget.sourceElement["user_uid"])) {
        setState(() {
          // insert message at latest
          chatMessages.insert(
            0,
            {
              'chat_id': receivedData['receiverChatUid'],
              'type': receivedData['type'],
              'message': receivedData['message'],
              'created_on': receivedData['createdOn'],
              'is_message_received':
                  (loggedInUserUid != receivedData['toUserUid']),
            },
          );
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _messageDraftController.dispose();
    FBroadcast.instance().unregister(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: isMessagesLoading
                    ? const Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppItemProgressIndicator(),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('loading messages ...'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _controller,
                        reverse: true,
                        itemCount: chatMessages.length,
                        itemBuilder: (BuildContext context, index) {
                          Map chatMessage = chatMessages[index];
                          chatMessage['user_id'] = targetUserId;
                          return messageCardWidget(
                            chatMessageItem: chatMessage,
                          );
                        },
                      ),
              ),
            ),
            if (!isMessagesLoading)
              SafeArea(
                child: (isRequestPending ||
                        didYouRequestDenied ||
                        (userData['messageRequestStatus'] ==
                            'MESSAGE_REQUEST_DECLINE_BY_USER')
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (userData['messageRequestStatus'] ==
                              'MESSAGE_REQUEST_DECLINE_BY_USER')
                            const Flexible(
                              child: MaterialBanner(
                                overflowAlignment: OverflowBarAlignment.end,
                                content: Text('Request Denied'),
                                leading: Icon(Icons.block),
                                backgroundColor: Colors.red,
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: null,
                                    child: Text(''),
                                  ),
                                ],
                              ),
                            ),
                          if (userData['messageRequestStatus'] !=
                              'MESSAGE_REQUEST_DECLINE_BY_USER')
                            Flexible(
                              child: MaterialBanner(
                                overflowAlignment: OverflowBarAlignment.end,
                                // padding: EdgeInsets.all(8),
                                content: didYouRequestDenied
                                    ? const Text(
                                        'You have already declined user message request',
                                      )
                                    : const Text(
                                        'You can accept or deny user message request.'),
                                leading: const Icon(Icons.block),
                                backgroundColor: Colors.red,
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: (() {
                                      data_transport.post(
                                          'messenger/$targetUserId/process-accept-decline-message-request',
                                          inputData: {
                                            'message_request_status': 1
                                          }, onSuccess: ((responseData) {
                                        setState(() {
                                          isRequestPending = false;
                                          didYouRequestDenied = false;
                                        });
                                      }));
                                    }),
                                    child: const Text(
                                      'Accept',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (userData['messageRequestStatus'] !=
                                      'MESSAGE_REQUEST_DECLINE_BY_USER')
                                    if (!didYouRequestDenied)
                                      TextButton(
                                        onPressed: (() {
                                          data_transport.post(
                                              'messenger/$targetUserId/process-accept-decline-message-request',
                                              inputData: {
                                                'message_request_status': 2
                                              }, onSuccess: ((responseData) {
                                            setState(() {
                                              didYouRequestDenied = true;
                                            });
                                          }));
                                        }),
                                        child: const Text(
                                          'Deny',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                ],
                              ),
                            ),
                        ],
                      )
                    : Column(children: [
                        Container(
                          margin: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      18,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                          icon: const Icon(
                                            Icons.face,
                                            color: Colors.blueAccent,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              emojiShowing = !emojiShowing;
                                            });
                                          }),
                                      Expanded(
                                        child: TextField(
                                          style: const TextStyle(
                                              color: Colors.black),
                                          keyboardType: TextInputType.multiline,
                                          focusNode: messageDraftFocusNode,
                                          controller: _messageDraftController,
                                          minLines: 1,
                                          maxLines: 5,
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            hintText: "Type ...",
                                            hintStyle: TextStyle(
                                              color: Colors.blueAccent,
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      StickerSelectionWidget(
                                        stickerListData: stickerListData,
                                        sendNewMessage: sendNewMessage,
                                        fetchAvailableStickers:
                                            fetchAvailableStickers,
                                      ),
                                      if (configItem('services.giphy.enable'))
                                        IconButton(
                                          padding: const EdgeInsets.all(2),
                                          icon: const Icon(
                                            Icons.gif_box,
                                            color: Colors.blueAccent,
                                          ),
                                          onPressed: () async {
                                            await GiphyGet.getGif(
                                              showEmojis: configItem(
                                                  'services.giphy.features.showEmojis'),
                                              showStickers: configItem(
                                                  'services.giphy.features.showStickers'),
                                              showGIFs: configItem(
                                                  'services.giphy.features.showGIFs'),
                                              context: context, //Required
                                              apiKey: configItem(
                                                'services.giphy.apiKey',
                                              ),
                                              lang: GiphyLanguage
                                                  .english, //Optional - Language for query.
                                              randomID:
                                                  "abcd", // Optional - An ID/proxy for a specific user.
                                              tabColor: Colors
                                                  .teal, // Optional- default accent color.
                                              debounceTimeInMilliseconds:
                                                  350, // Optional- time to pause between search keystrokes
                                            ).then((value) {
                                              sendNewMessage(
                                                  type: 8,
                                                  message: value
                                                      ?.images?.original?.url);
                                              return value;
                                            });
                                          },
                                        ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.attach_file,
                                          color: Colors.blueAccent,
                                        ),
                                        onPressed: () {
                                          pickAndUploadFile(context,
                                              'messenger/$targetUserId/send-message',
                                              allowMultiple: false,
                                              onStart: (imageSelected) {},
                                              onSuccess: (value, data) {},
                                              onError: (error) {
                                            pr(error);
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => sendNewMessage(type: 1),
                                child: Container(
                                  padding: const EdgeInsets.all(15.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        emojiContainerWidget(),
                      ])),
              )
          ],
        ));
  }

  Offstage emojiContainerWidget() {
    return Offstage(
      offstage: !emojiShowing,
      child: SizedBox(
          height: 250,
          child: EmojiPicker(
            textEditingController: _messageDraftController,
            config: Config(
              columns: 7,
              // Issue: https://github.com/flutter/flutter/issues/28894
              emojiSizeMax: 32 *
                  (foundation.defaultTargetPlatform == TargetPlatform.iOS
                      ? 1.30
                      : 1.0),
              verticalSpacing: 0,
              horizontalSpacing: 0,
              gridPadding: EdgeInsets.zero,
              initCategory: Category.RECENT,
              bgColor: const Color(0xFFF2F2F2),
              indicatorColor: Colors.blue,
              iconColor: Colors.grey,
              iconColorSelected: Colors.blue,
              backspaceColor: Colors.blue,
              skinToneDialogBgColor: Colors.white,
              skinToneIndicatorColor: Colors.grey,
              enableSkinTones: true,
              recentTabBehavior: RecentTabBehavior.RECENT,
              recentsLimit: 28,
              replaceEmojiOnLimitExceed: false,
              noRecents: const Text(
                'No Recent',
                style: TextStyle(fontSize: 20, color: Colors.black26),
                textAlign: TextAlign.center,
              ),
              loadingIndicator: const SizedBox.shrink(),
              tabIndicatorAnimDuration: kTabScrollDuration,
              categoryIcons: const CategoryIcons(),
              buttonMode: ButtonMode.MATERIAL,
              checkPlatformCompatibility: true,
            ),
          )),
    );
  }

  sendNewMessage({int type = 1, String? message}) {
    message ??= _messageDraftController.text.trim();
    if (message == '') {
      return false;
    }

    int randomNumber = Random().nextInt(9999999);
    // show the message
    setState(() {
      emojiShowing = false;
      chatMessages.insert(
        0,
        {
          'temp_id': randomNumber,
          'type': type,
          'message': message,
          'created_on': 'now',
          'is_message_received': false,
        },
      );
    });

    if (type == 1) {
      _messageDraftController.clear();
      messageDraftFocusNode.requestFocus();
    } else {
      messageDraftFocusNode.unfocus();
    }

    return data_transport.post(
      'messenger/$targetUserId/send-message',
      inputData: {
        'message': message,
        'type': type,
        'unique_id': '',
      },
      onSuccess: ((responseData) {
        Map foundChatItem = chatMessages.firstWhere((element) =>
            (element?['temp_id'] != null) &&
            (element['temp_id'] == randomNumber));
        setState(() {
          foundChatItem['temp_id'] = '';
          foundChatItem['chat_id'] =
              getItemValue(responseData, 'data.senderChatUid');
          foundChatItem['created_on'] =
              getItemValue(responseData, 'data.storedData.created_on');
        });
      }),
      onFailed: (responseData) {
        var errorMessage = getItemValue(responseData, 'data.message');
        if (errorMessage != null || errorMessage != '') {
          setState(() {
            showToastMessage(
                context, getItemValue(responseData, 'data.message'),
                type: 'error');
            chatMessages.removeWhere((element) =>
                (element?['temp_id'] != null) &&
                (element['temp_id'] == randomNumber));
          });
        }
      },
    );
  }

  Align messageCardWidget({required Map chatMessageItem}) {
    return Align(
      alignment: !chatMessageItem['is_message_received']
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          minWidth: 250,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: !chatMessageItem['is_message_received']
              ? const Color.fromARGB(255, 192, 120, 192)
              : null,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              ([2, 8, 12, '2', '8', '12'].contains(chatMessageItem['type']))
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                        bottom: 40,
                      ),
                      child: (chatMessageItem['message'] == '__loading__')
                          ? const SizedBox(
                              height: 250,
                              width: 250,
                              child: AppItemProgressIndicator(
                                size: 20,
                              ),
                            )
                          : GestureDetector(
                              onTap: () => navigatePage(
                                context,
                                ProfileImageView(
                                  title: Text(chatMessageItem['created_on']),
                                  imageUrl: chatMessageItem['message'],
                                ),
                              ),
                              child: AppCachedNetworkImage(
                                fit: BoxFit.contain,
                                width: 250,
                                height: 250,
                                imageUrl: chatMessageItem['message'],
                              ),
                            ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 40,
                        top: 10,
                        bottom: 40,
                      ),
                      child: Text(
                        chatMessageItem['message'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
              if (chatMessageItem['chat_id'] != null)
                Positioned(
                  top: -5,
                  // bottom: 8,
                  right: -5,
                  // alignment: Alignment.topRight,
                  child: IconButton(
                    iconSize: 18,
                    icon: const Icon(
                      Icons.delete_forever,
                      // color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        chatMessages.removeWhere((item) =>
                            item["chat_id"] == chatMessageItem["chat_id"]);
                      });

                      data_transport.post(
                        'messenger/${chatMessageItem["chat_id"]}/${chatMessageItem["user_id"]}/delete-message',
                      );
                    },
                  ),
                ),
              Positioned(
                bottom: 8,
                right: 10,
                child: Row(
                  children: [
                    Text(
                      chatMessageItem['created_on'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void pickAndUploadFile(context, url,
      {Function? onSuccess,
      Function? thenCallback,
      Function? onError,
      Function? onStart,
      FileType pickingType = FileType.image,
      bool allowMultiple = false,
      String? allowedExtensions = ''}) async {
    try {
      var paths = (await FilePicker.platform.pickFiles(
        type: pickingType,
        allowMultiple: allowMultiple,
        allowedExtensions: (allowedExtensions?.isNotEmpty ?? false)
            ? allowedExtensions?.replaceAll(' ', '').split(',')
            : null,
      ))
          ?.files;
      String uploadedImageName = paths?[0].path ?? '';
      if ((uploadedImageName == '')) {
        return;
      }
      if (onStart != null) {
        onStart(uploadedImageName);
      }
      // blank loader container
      var randomNumberId = Random().nextInt(99999);
      setState(() {
        chatMessages.insert(
          0,
          {
            'temp_id': randomNumberId,
            'type': 2,
            'message': '__loading__',
            'created_on': 'now',
            'is_message_received': false,
          },
        );
      });

      data_transport
          .uploadFile(uploadedImageName, url, context: context, inputData: {
        'type': '2',
        'unique_id': 'uni$randomNumberId',
      }, onError: (error) {
        if (onError != null) {
          onError(e);
        }
      }, thenCallback: (data) {
        if (thenCallback != null) {
          thenCallback(data);
        }
      }, onSuccess: (responseData) {
        Map foundChatItem = chatMessages.firstWhere((element) =>
            (element?['temp_id'] != null) &&
            (element['temp_id'] == randomNumberId));
        setState(() {
          foundChatItem['temp_id'] = '';
          foundChatItem['message'] =
              getItemValue(responseData, 'data.storedData.message');
          foundChatItem['chat_id'] =
              getItemValue(responseData, 'data.senderChatUid');
          foundChatItem['created_on'] =
              getItemValue(responseData, 'data.storedData.created_on');
        });
      });
    } on PlatformException catch (e) {
      if (onError != null) {
        onError(e);
      }
      pr('Unsupported operation ${e.toString()}');
      showToastMessage(context, 'Failed', type: 'error');
    } catch (e) {
      if (onError != null) {
        onError(e);
      }
      showToastMessage(context, 'Failed', type: 'error');
    }
  }
}

class StickerSelectionWidget extends StatelessWidget {
  const StickerSelectionWidget({
    foundation.Key? key,
    required this.stickerListData,
    required this.sendNewMessage,
    required this.fetchAvailableStickers,
  }) : super(key: key);

  final List stickerListData;
  final Function sendNewMessage;
  final Function fetchAvailableStickers;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(2),
      icon: const Icon(
        Icons.image,
        color: Colors.blueAccent,
      ),
      onPressed: () {
        showModalBottomSheet<void>(
            // context and builder are
            // required properties in this widget
            context: context,
            builder: (BuildContext context) {
              return Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  centerTitle: false,
                  title: const Text(
                    'Stickers',
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemCount: stickerListData.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map stickerData = stickerListData[index];
                        return GestureDetector(
                          onTap: () {
                            if (!stickerData['is_purchased'] &&
                                !stickerData['is_free']) {
                              showActionableDialog(context,
                                  title: 'Are you sure?',
                                  description: Text(
                                      'You want to purchase this sticker? It will cost you ${stickerData['formatted_price']}'),
                                  onConfirm: () {
                                data_transport.post(
                                  'messenger/buy-sticker',
                                  context: context,
                                  inputData: {'sticker_id': stickerData['id']},
                                  onSuccess: (responseData) {
                                    fetchAvailableStickers();
                                    sendNewMessage(
                                        type: 12,
                                        message: stickerData['image_url']);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                                  confirmActionText: 'Yes',
                                  cancelActionText: 'Cancel');
                            } else {
                              sendNewMessage(
                                  type: 12, message: stickerData['image_url']);
                              Navigator.pop(context);
                            }
                          },
                          child: Card(
                            // color: Colors.amber,
                            child: Column(
                              children: [
                                Text(
                                  stickerData['title'],
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: AppCachedNetworkImage(
                                      imageUrl: stickerData['image_url'],
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                ),
                                Center(
                                    child: Column(
                                  children: [
                                    if (stickerData['is_free'])
                                      const Text('Free'),
                                    if (!stickerData['is_purchased'] &&
                                        !stickerData['is_free'])
                                      Text(stickerData['formatted_price']),
                                    if (stickerData['is_purchased'])
                                      const Text('Purchased'),
                                  ],
                                )),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              );
            });
      },
    );
  }
}
