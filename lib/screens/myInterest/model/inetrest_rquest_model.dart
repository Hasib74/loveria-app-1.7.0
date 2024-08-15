/// user_id : 1
/// interests : [{"input_key":"body_type","value":["Skinny","Fit"]},{"input_key":"outlook","value":["Wear glasses","Long Hair"]},{"input_key":"pets","value":["Love pets"]},{"input_key":"emigration","value":["Looking for emigration"]}]

class InterestRequestModel {
  InterestRequestModel({
    this.userId,
    this.interests,
  });

  num? userId;
  List<Interests>? interests;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['user_id'] = userId;
    if (interests != null) {
      map['interests'] = interests?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// input_key : "body_type"
/// value : ["Skinny","Fit"]

class Interests {
  Interests({
    this.inputKey,
    this.value,
  });

  Interests.fromJson(dynamic json) {
    inputKey = json['input_key'];
    value = json['value'] != null ? json['value'].cast<String>() : [];
  }

  String? inputKey;
  List<String>? value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['input_key'] = inputKey;
    map['value'] = value;
    return map;
  }
}
