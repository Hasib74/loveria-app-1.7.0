/// id : 1
/// value : "Basic Info"
///
///

class InterestCategoryModel {
  List<Data>? data;

  InterestCategoryModel({
    this.data,
  });

  InterestCategoryModel.fromJson(dynamic json) {
    if (json != null) {
      data = [];
      json.forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
  }
}

class Data {
  Data({
    this.id,
    this.value,
  });

  Data.fromJson(dynamic json) {
    id = json['id'];
    value = json['value'];
  }

  num? id;
  String? value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['value'] = value;
    return map;
  }
}
