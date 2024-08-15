/// label : "Body Type"
/// name : "body_type"
/// type : "multiple"
/// options : ["Skinny","Slim","Fit","Chubby","Obese"]
/// selected_values : ["Skinny","Fit"]

class CategoryWishFieldsResponseModel {
  List<Data> data = [];

  CategoryWishFieldsResponseModel({
    required this.data,
  });

  CategoryWishFieldsResponseModel.fromJson(dynamic json) {
    if (json != null) {
      data = [];
      json.forEach((v) {
        data.add(Data.fromJson(v));
      });
    }
  }
}

class Data {
  Data({
    this.label,
    this.name,
    this.type,
    this.options,
    this.selectedValues,
  });

  Data.fromJson(dynamic json) {
    label = json['label'];
    name = json['name'];
    type = json['type'];
    min = json['min'];
    max = json['max'];
    unit = json['unit'];

    options = json['options'] != null ? json['options'].cast<String>() : [];
    selectedValues = json['selected_values'] != null
        ? json['selected_values'].cast<String>()
        : [];
  }

  String? label;
  String? name;
  String? type;
  String? min;

  String? max;

  String? unit;

  List<String>? options;
  List<String>? selectedValues;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['label'] = label;
    map['name'] = name;
    map['type'] = type;
    map['options'] = options;
    map['selected_values'] = selectedValues;

    return map;
  }
}
