import 'package:flutter/material.dart';
import 'package:loveria/common/language/language_extension.dart';
import 'package:loveria/screens/myInterest/model/category_wish_fields_response_model.dart';
import 'package:loveria/screens/myInterest/model/interest_category_model.dart';
import 'package:loveria/screens/myInterest/screen/section/basic_info.dart';
import 'package:loveria/screens/myInterest/screen/section/habit.dart';
import 'package:loveria/screens/myInterest/screen/section/location.dart';
import 'package:loveria/screens/myInterest/screen/section/my_interest_fileds.dart';
import 'package:loveria/screens/myInterest/screen/section/professional.dart';
import 'package:loveria/screens/myInterest/service/my_interest_service.dart';

class MyInterestScreen extends StatefulWidget {
  bool? hasAppBar;

  MyInterestScreen({super.key, this.hasAppBar = true});

  @override
  State<MyInterestScreen> createState() => _MyInterestScreenState();
}

class _MyInterestScreenState extends State<MyInterestScreen> {
  MyInterestService myInterestService = MyInterestService();
  InterestCategoryModel? interestCategoryModel;

  Map<int, CategoryWishFieldsResponseModel> categoryWishFieldsResponseModel =
      {};

  loadData() async {
    myInterestService.getAllCategory().then((value) {
      print("MyInterestScreen: loadData: $value");
      setState(() {
        interestCategoryModel = value!;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadData();
  }

  loadCategoryWishFieldsResponseModel({int? categoryId}) {}

  @override
  Widget build(BuildContext context) {
    return interestCategoryModel?.data == null
        ? const Center(
            child: SizedBox(
                height: 20, width: 20, child: CircularProgressIndicator()))
        : SafeArea(
            child: DefaultTabController(
              length: interestCategoryModel?.data?.length ?? 0,
              child: Scaffold(
                appBar: widget.hasAppBar == false
                    ? null
                    : AppBar(
                        title: Text("My Interest".toTranslated()),
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )),
                body: Column(
                  children: [
                    TabBar(
                        padding: EdgeInsets.zero,
                        isScrollable: true,
                        tabs: interestCategoryModel!.data!
                            .map((e) => Tab(text: e.value.toString().toTranslated()))
                            .toList()),
                    Expanded(
                      child: TabBarView(
                          children: interestCategoryModel!.data!
                              .map((e) => MyInterestFieldsScreen(
                                    categoryId: e.id.toString(),
                                  ))
                              .toList()),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
