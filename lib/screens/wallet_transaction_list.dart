import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import '../../screens/user_common.dart';
import '../common/services/utils.dart';
import '../common/widgets/common.dart';
import '../support/app_theme.dart' as app_theme;
import '../common/services/data_transport.dart' as data_transport;
import 'purchase.dart';

class WalletTransactionListPage extends StatefulWidget {
  const WalletTransactionListPage({Key? key}) : super(key: key);
  @override
  State<WalletTransactionListPage> createState() =>
      _WalletTransactionListPageState();
}

class _WalletTransactionListPageState extends State<WalletTransactionListPage>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int present = 0;
  int perPage = 0;
  String urlToCall = 'credit-wallet/transaction-list';
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

    data_transport.get(
      'credit-wallet/wallet-info-data',
      onSuccess: (walletResponseData) {
        setState(() {
          walletBalance =
              getItemValue(walletResponseData, 'data.creditBalance');
        });
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
          context: context,
          title: 'My Credit Wallet',
          actionWidgets: [
            if (isPurchaseSystemAvailable())
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Buy More Credits',
                onPressed: () {
                  navigatePage(context, const PurchasePage());
                },
              ),
          ]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Theme.of(context).secondaryHeaderColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.wallet),
                        ),
                        Text(
                          'Your Wallet Balance',
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      thickness: 2,
                    ),
                    walletBalance == null
                        ? const AppItemProgressIndicator()
                        : Text(
                            '$walletBalance Credits',
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    if (isPurchaseSystemAvailable())
                      ElevatedButton(
                        onPressed: (() {
                          navigatePage(context, const PurchasePage());
                        }),
                        child: const Text('Buy More Credits'),
                      )
                  ],
                ),
              ),
            ),
          ),
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
                      Map<String, dynamic> userItem = items[index];
                      return GestureDetector(
                        onTap: () {
                          if (userItem['financialTransactionDetail']
                              .isNotEmpty) {
                            showModalBottomSheet<void>(
                              // context and builder are
                              // required properties in this widget
                              context: context,
                              builder: (BuildContext context) {
                                Map financialTransactionDetail =
                                    userItem['financialTransactionDetail'];
                                return Scaffold(
                                  appBar: AppBar(
                                    automaticallyImplyLeading: false,
                                    centerTitle: false,
                                    title: const Text('Financial Transaction'),
                                  ),
                                  body: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Column(
                                          children: <Widget>[
                                            InfoItemWidget(
                                                label: 'Transaction',
                                                value: userItem[
                                                    'formattedTransactionType']),
                                            InfoItemWidget(
                                                label: 'on',
                                                value:
                                                    financialTransactionDetail[
                                                        'created_at']),
                                            InfoItemWidget(
                                                label: 'Payment Method',
                                                value:
                                                    financialTransactionDetail[
                                                            'method']
                                                        .toString()),
                                            InfoItemWidget(
                                                label: 'Amount',
                                                value:
                                                    financialTransactionDetail[
                                                            'amount']
                                                        .toString()),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: ListTile(
                          leading: Icon(
                            userItem['transactionType'] == 1
                                ? Icons.add
                                : Icons.remove,
                            color: userItem['transactionType'] == 1
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text(
                              userItem['formattedTransactionType'].toString()),
                          subtitle: Wrap(
                            children: [
                              Text(
                                userItem['created_at'].toString(),
                              ),
                            ],
                          ),
                          trailing: Text('${userItem['credits']} Credits'),
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

  /// purchase system available
  isPurchaseSystemAvailable() {
    return !isIOSPlatform() && configItem('creditPackages.enablePurchase');
  }
}
