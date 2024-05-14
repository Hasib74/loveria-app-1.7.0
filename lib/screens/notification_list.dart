import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import '../common/services/utils.dart';
import '../common/widgets/common.dart';
import '../support/app_theme.dart' as app_theme;
import '../common/services/data_transport.dart' as data_transport;

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({Key? key}) : super(key: key);
  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int present = 0;
  int perPage = 0;
  String urlToCall = 'notifications/notification-list';
  List items = [];
  int totalCount = 0;
  late Map dataResponse;
  final Map<String, dynamic> filterInputData = {};
  bool isRequestProcessing = false;
  bool isInitialRequestProcessed = false;
  String? userRequestType;
  int? walletBalance;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      initializeBasicDataRequest();
      FBroadcast.instance().register('local.broadcast.credits_update',
          (eventResponseData, callback) {
        initializeBasicDataRequest();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (mounted) {}

    /// remove all receivers from the environment
    FBroadcast.instance().unregister(this);
  }

  initializeBasicDataRequest() {
    setState(() {
      items = [];
      totalCount = 0;
      isRequestProcessing = true;
    });

    data_transport.post(
      'notifications/read-all-notification',
      thenCallback: (responseData) {
        FBroadcast.instance().broadcast(
          "local.broadcast.notification_count",
          value: 0,
        );
      },
    );

    data_transport
        .get(
      urlToCall,
      context: context,
    )
        .then((dataReceived) {
      setState(() {
        dataResponse = getItemValue(dataReceived, 'data');
        items = getItemValue(dataReceived, 'data.data');
        totalCount = getItemValue(dataReceived, 'data.paginationData.total');
        isRequestProcessing = false;
        isInitialRequestProcessed = true;
        userRequestType = getItemValue(dataReceived, 'data.userRequestType');
      });
    });
  }

  void _loadMore() {
    if ((urlToCall != dataResponse['paginationData']['nextPageURL']) &&
        (items.length < totalCount)) {
      isRequestProcessing = true;
      urlToCall = dataResponse['paginationData']['nextPageURL'];
      data_transport
          .get(
        urlToCall,
      )
          .then((dataReceived) {
        setState(() {
          dataResponse = getItemValue(dataReceived, 'data');
          items.addAll(getItemValue(dataResponse, 'data'));
          isRequestProcessing = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: mainAppBarWidget(
          context: context, title: 'Notifications', actionWidgets: []),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >=
                    (scrollInfo.metrics.maxScrollExtent - 300)) {
                  _loadMore();
                }
                return true;
              },
              child: LayoutBuilder(builder: (context, constraints) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      (present <= totalCount) ? items.length + 1 : items.length,
                  itemBuilder: (BuildContext context, index) {
                    if (items.isEmpty && !isRequestProcessing) {
                      return const ListTile(
                        title: Text(
                          'no result found',
                          textAlign: TextAlign.center,
                        ),
                        textColor: app_theme.error,
                      );
                    } else if ((index == items.length) &&
                        (totalCount != 0) &&
                        (items.length == totalCount) &&
                        !isRequestProcessing) {
                      return const ListTile(
                        title: Text(
                          'end of result',
                          textAlign: TextAlign.center,
                        ),
                        textColor: app_theme.error,
                      );
                    } else if ((index == items.length)) {
                      return const Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: AppItemProgressIndicator(
                            size: 20,
                          ),
                        ),
                      );
                    } else {
                      Map<String, dynamic> notificationItem = items[index];
                      return ListTile(
                        title: Text(notificationItem['message'].toString()),
                        subtitle: Row(
                          children: [
                            Text(
                              notificationItem['formattedCreatedAt'].toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
