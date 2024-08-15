import 'package:flutter/material.dart';
import '../../common/services/data_transport.dart' as data_transport;
import '../../common/services/utils.dart';
import '../../common/widgets/common.dart';
import 'messenger_chat_list.dart';

class MessengerPage extends StatefulWidget {
  const MessengerPage({Key? key}) : super(key: key);

  @override
  State<MessengerPage> createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {
  int present = 0;
  int totalCount = 0;
  String uploadedImageName = '';
  bool isLoading = false;
  List<Widget> photosItems = [];
  List photosItemIds = [];
  List messengerUsers = [];
  bool isListLoading = true;
  @override
  void initState() {
    if (mounted) {
      data_transport
          .get('messenger/get-user-conversations', context: context)
          .then((dataReceived) {
        setState(() {
          isListLoading = false;
          messengerUsers = getItemValue(dataReceived, 'data.messengerUsers');
        });
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isListLoading
          ? const Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppItemProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('loading ...'),
                  ),
                ],
              ),
            )
          : (messengerUsers.isNotEmpty
              ? LayoutBuilder(builder: (context, constraints) {
                  return ListView.builder(
                    itemCount: messengerUsers.length,
                    itemBuilder: (BuildContext context, index) {
                      Map<String, dynamic> element = messengerUsers[index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: (() {
                              return navigatePage(
                                  context,
                                  MessengerChatListPage(
                                    sourceElement: element,
                                  ));
                            }),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text(
                                  element['user_full_name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    element['is_online'] == 1
                                        ? 'Online'
                                        : (element['is_online'] == 2
                                            ? 'Idle'
                                            : (element['is_online'] == 3
                                                ? 'Offline'
                                                : '')),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          appCachedNetworkImageProvider(
                                              imageUrl:
                                                  element['profile_picture']
                                                      .toString()),
                                      radius: 30,
                                    ),
                                    Positioned(
                                      top: 2,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        // ignore: prefer_const_constructors
                                        decoration: BoxDecoration(
                                          color: ((element['is_online'] == 1)
                                              ? Colors.green
                                              : (element['is_online'] == 2
                                                  ? Colors.orange
                                                  : Colors.red)),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                trailing: Text(
                                  element['last_seen_at_time_ago_format'],
                                  // info[index]['time'].toString(),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                })
              : const Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('There are no results to show.'),
                    ],
                  ),
                )),
    );
  }
}
