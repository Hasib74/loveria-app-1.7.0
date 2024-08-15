import 'package:flutter/material.dart';
import 'package:loveria/screens/myInterest/model/inetrest_rquest_model.dart';
import 'package:loveria/screens/myInterest/service/my_interest_service.dart';

import '../../../../common/services/auth.dart';
import '../../model/category_wish_fields_response_model.dart';
import '../../widgets/custom_selector_widget.dart';
import '../../../../common/extensions/string_extensions.dart';
import 'package:loveria/common/language/language_extension.dart';

import '../../widgets/cutsom_text_filed.dart';

class MyInterestFieldsScreen extends StatefulWidget {
  String? categoryId;

  MyInterestFieldsScreen({Key? key, this.categoryId}) : super(key: key);

  @override
  State<MyInterestFieldsScreen> createState() => _MyInterestFieldsScreenState();
}

class _MyInterestFieldsScreenState extends State<MyInterestFieldsScreen> {
  CategoryWishFieldsResponseModel? categoryWishFieldsResponseModel;
  MyInterestService myInterestService = MyInterestService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
          itemBuilder: (context, int index) {
            var data = categoryWishFieldsResponseModel?.data[index];
            return data?.type == "text"
                ? CutsomTextFiled(
                    value: data?.selectedValues?.first,
                    hint:
                        data?.label != null ? data?.label?.toTranslated() : "",
                    onSubmitted: (controller) {
                      InterestRequestModel interestRequestModel =
                          InterestRequestModel(
                        userId: userInfo["_id"],
                        interests: [
                          Interests(inputKey: data?.name, value: [controller])
                        ],
                      );

                      myInterestService
                          .saveMyInterest(interestRequestModel)
                          .then((value) {
                        loadData();
                      });
                    },
                  )
                : CustomSelectorWidget(
                    min: data?.min,
                    max: data?.max,
                    unit: data?.unit,
                    label:
                        data?.label != null ? data?.label?.toTranslated() : "",
                    type: data?.type == "multiple"
                        ? CustomSelectorType.multiple
                        : CustomSelectorType.range,
                    onSelectedAge: (value) async {
                      print("Selected Age: $value");

                      InterestRequestModel interestRequestModel =
                          InterestRequestModel(
                        userId: userInfo["_id"],
                        interests: [
                          Interests(inputKey: data?.name, value: [
                            value.start.toString(),
                            value.end.toString()
                          ])
                        ],
                      );

                      await myInterestService
                          .saveMyInterest(interestRequestModel);
                      loadData();
                    },
                    onSelectedMultiple: (value) async {
                      print("Selected Job Nature: $value");

                      InterestRequestModel interestRequestModel =
                          InterestRequestModel(
                        userId: userInfo["_id"],
                        interests: [
                          Interests(
                              inputKey: data?.name,
                              value: value
                                  .map((e) => e.toString().toTranslated())
                                  .toList())
                        ],
                      );

                      await myInterestService
                          .saveMyInterest(interestRequestModel);

                      loadData();
                    },
                    values:
                        data?.options?.map((e) => e.toTranslated()).toList(),
                    selectedValues: data?.selectedValues
                            ?.map((e) => e.toTranslated())
                            .toList() ??
                        [],
                  );
          },
          separatorBuilder: (context, int index) {
            return const SizedBox(
              height: 16,
            );
          },
          itemCount: categoryWishFieldsResponseModel?.data.length ?? 0),
    );
  }

  void loadData() async {
    myInterestService.getFieldsByCategory(widget.categoryId).then((value) {
      print("MyInterestFieldsScreen: loadData: $value");
      setState(() {
        categoryWishFieldsResponseModel = value;
      });
    });
  }

  _textField() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Type here".toTranslated(),
        ),
      ),
    );
  }
}
