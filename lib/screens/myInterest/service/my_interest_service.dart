import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../common/services/auth.dart';
import '../model/category_wish_fields_response_model.dart';
import '../model/inetrest_rquest_model.dart';
import '../model/interest_category_model.dart';

class MyInterestService {
  Future<InterestCategoryModel?> getAllCategory() async {
    var url = Uri.parse('https://dating.paksang.com/category');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = InterestCategoryModel.fromJson(jsonDecode(response.body));
      print(data.data?.length);
      return data;
    }
  }

  Future<CategoryWishFieldsResponseModel?> getFieldsByCategory(
      String? categoryId) async {
    var url = Uri.parse(
        'https://dating.paksang.com/category_wise_input_fields/$categoryId/${userInfo["_id"]}');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data =
          CategoryWishFieldsResponseModel.fromJson(jsonDecode(response.body));
      //    print(data.data?.length);
      return data;
    }
    return null;
  }

  Future saveMyInterest(InterestRequestModel interestRequestModel) async {
    var url = Uri.parse('https://dating.paksang.com/interest_store');
    var response = await http.post(url,
        body: jsonEncode(interestRequestModel.toJson()),
        headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);
      return data;
    }
  }
}
