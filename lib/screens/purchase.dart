import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fbroadcast/fbroadcast.dart';
import '../common/services/data_transport.dart' as data_transport;
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import '../common/services/utils.dart';
import '../common/widgets/common.dart';

// Auto-consume must be true on iOS.
// To try without auto-consume on another platform, change `true` to `false` here.
final bool _kAutoConsume = Platform.isIOS || true;
List<String> _kConsumableIds = configItem('creditPackages.productIds');
List<String> _kProductIds = _kConsumableIds;

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => PurchasePageState();
}

class PurchasePageState extends State<PurchasePage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;
  List creditPackages = [];
  bool isLoaded = false;
  bool isCountUpdating = false;

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
      pr(error);
    });
    initStoreInfo();
    getCreditWalletData();
    super.initState();
  }

  getCreditWalletData() async {
    setState(() {
      isCountUpdating = true;
    });
    return data_transport.get(
      'credit-wallet/credit-wallet-data',
      context: context,
      onSuccess: (responseData) {
        setState(() {
          creditPackages = getItemValue(
              responseData, 'data.creditWalletData.creditPackages');
          isLoaded = true;
        });
      },
    );
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = <ProductDetails>[];
        _purchases = <PurchaseDetails>[];
        _notFoundIds = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    // final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    if (mounted) {
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        iosPlatformAddition.setDelegate(null);
      }
      _subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> stack = <Widget>[];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: <Widget>[
            _buildConnectionCheckTile(),
            _buildProductList(),
            _buildConsumableBox(),
            // _buildRestoreButton(),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_queryProductError!),
      ));
    }
    if (_purchasePending) {
      stack.add(
        const Stack(
          children: <Widget>[
            Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: mainAppBarWidget(
          context: context, title: 'Purchase Credits', actionWidgets: []),
      body: Stack(
        children: stack,
      ),
    );
  }

  Card _buildConnectionCheckTile() {
    if (_loading) {
      return const Card(child: ListTile(title: Text('Trying to connect...')));
    }
    final List<Widget> children = <Widget>[/* storeHeader */];

    if (!_isAvailable) {
      children.addAll(<Widget>[
        const Divider(),
        ListTile(
          title: Text('Not connected',
              style: TextStyle(color: ThemeData.light().colorScheme.error)),
          subtitle: const Text(
              'Unable to connect to the payments processor. Has this app been configured correctly? See the example https://github.com/flutter/plugins/blob/main/packages/in_app_purchase/in_app_purchase/README.md for instructions.'),
        ),
      ]);
    }
    return Card(
      child: Column(
        children: children,
      ),
    );
  }

  Card _buildProductList() {
    if (_loading) {
      return const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Fetching products...'),
        ),
      );
    }
    if (!_isAvailable) {
      return const Card();
    }
    const ListTile productHeader = ListTile(
      title: Text(
        textAlign: TextAlign.center,
        'Credit Packages',
        style: TextStyle(
          fontSize: 22,
        ),
      ),
    );
    final List<ListTile> productList = <ListTile>[];
    if (_notFoundIds.isNotEmpty && configItem('debug')) {
      productList.add(
        ListTile(
          title: Text(
            '[${_notFoundIds.join(", ")}] not found',
            style: TextStyle(
              color: ThemeData.light().colorScheme.error,
            ),
          ),
          subtitle: const Text(
              'This app needs special configuration to run. Please see https://github.com/flutter/plugins/blob/main/packages/in_app_purchase/in_app_purchase/README.md for instructions.'),
        ),
      );
    }

    // This loading previous purchases code is just a demo. Please do not use this as it is.
    // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
    // We recommend that you use your own server to verify the purchase data.
    final Map<String, PurchaseDetails> purchases =
        Map<String, PurchaseDetails>.fromEntries(
            _purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        final PurchaseDetails? previousPurchase = purchases[productDetails.id];

        Map creditPackage = {};
        final Iterable creditPackageRaw = creditPackages.where((element) {
          if (element['package_uid'] == productDetails.id) {
            return true;
          } else {
            return false;
          }
        });
        if (creditPackageRaw.isNotEmpty) {
          creditPackage = creditPackageRaw.first;
        }
        if (creditPackage.isEmpty) {
          return const ListTile(
            title: Text('Package not found'),
          );
        }

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(25), // Image border
            child: AppCachedNetworkImage(
              height: 40,
              width: 40,
              imageUrl: getItemValue(creditPackage, 'packageImageUrl'),
            ),
          ),
          title: Text(
              // enable below title if you want to have title from play/app store
              // productDetails.title,
              getItemValue(creditPackage, 'package_name', fallbackValue: '')),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (creditPackage.isNotEmpty)
                Text(
                  '${getItemValue(creditPackage, 'credit', fallbackValue: '')} credits',
                ),
              Text(
                productDetails.description,
              )
            ],
          ),
          trailing: previousPurchase != null && Platform.isIOS
              ? IconButton(
                  onPressed: () => confirmPriceChange(context),
                  icon: const Icon(Icons.upgrade))
              : TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    late PurchaseParam purchaseParam;

                    if (Platform.isAndroid) {
                      // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
                      // verify the latest status of you your subscription by using server side receipt validation
                      // and update the UI accordingly. The subscription purchase status shown
                      // inside the app may not be accurate.
                      final GooglePlayPurchaseDetails? oldSubscription =
                          _getOldSubscription(productDetails, purchases);

                      purchaseParam = GooglePlayPurchaseParam(
                        productDetails: productDetails,
                        changeSubscriptionParam: (oldSubscription != null)
                            ? ChangeSubscriptionParam(
                                oldPurchaseDetails: oldSubscription,
                                prorationMode:
                                    ProrationMode.immediateWithTimeProration,
                              )
                            : null,
                      );
                    } else {
                      purchaseParam = PurchaseParam(
                        productDetails: productDetails,
                      );
                    }

                    if (_kConsumableIds.contains(productDetails.id)) {
                      _inAppPurchase.buyConsumable(
                        purchaseParam: purchaseParam,
                        autoConsume: _kAutoConsume,
                      );
                    } else {
                      _inAppPurchase.buyNonConsumable(
                        purchaseParam: purchaseParam,
                      );
                    }
                  },
                  child: Text(productDetails.price),
                ),
        );
      },
    ));

    return Card(
      child: Column(
        children: <Widget>[
              productHeader,
              const Divider(),
            ] +
            productList,
      ),
    );
  }

  Card _buildConsumableBox() {
    if (_loading) {
      return const Card(
          child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Fetching consumables...')));
    }
    // if (!_isAvailable || _notFoundIds.contains(_kConsumableId)) {
    if (!_isAvailable) {
      return const Card();
    }
    return const Card();
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    data_transport.post(
      'credit-wallet/process-in-app-purchase/google',
      context: context,
      inputData:
          jsonDecode(purchaseDetails.verificationData.localVerificationData),
      // thenCallback: (responseData) {},
      onSuccess: (responseData) {
        FBroadcast.instance().broadcast(
          "local.broadcast.credits_update",
          value: {},
        );
        Navigator.pop(context);
      },
    );

    if (_kConsumableIds.contains(purchaseDetails.productID)) {
      setState(() {
        _purchasePending = false;
      });
    } else {
      setState(() {
        _purchases.add(purchaseDetails);
        _purchasePending = false;
      });
    }
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume &&
              _kConsumableIds.contains(purchaseDetails.productID)) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> confirmPriceChange(BuildContext context) async {
    // Price changes for Android are not handled by the application, but are
    // instead handled by the Play Store. See
    // https://developer.android.com/google/play/billing/price-changes for more
    // information on price changes on Android.
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }

  GooglePlayPurchaseDetails? _getOldSubscription(
      ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    // This is just to demonstrate a subscription upgrade or downgrade.
    // This method assumes that you have only 2 subscriptions under a group, 'subscription_silver' & 'subscription_gold'.
    // The 'subscription_silver' subscription can be upgraded to 'subscription_gold' and
    // the 'subscription_gold' subscription can be downgraded to 'subscription_silver'.
    // Please remember to replace the logic of finding the old subscription Id as per your app.
    // The old subscription is only required on Android since Apple handles this internally
    // by using the subscription group feature in iTunesConnect.
    GooglePlayPurchaseDetails? oldSubscription;
    return oldSubscription;
  }
}

/// Example implementation of the
/// [`SKPaymentQueueDelegate`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate?language=objc).
///
/// The payment queue delegate can be implemented to provide information
/// needed to complete transactions.
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
