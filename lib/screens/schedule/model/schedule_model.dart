/// id : 5
/// datetime : "2024-02-28T22:56"
/// title : "Event Test"
/// address : "Hong Kong"
/// matched_user_name : "Gazi Amir"
/// matched_user_img : "social-65d1c11354aca.png"
///
///

class ScheduleList {
  List<ScheduleModel>? scheduleList = [];

  ScheduleList({this.scheduleList = const []});

  ScheduleList.fromJson(dynamic json) {
    if (json != null) {
      json.forEach((v) {
        scheduleList?.add(ScheduleModel.fromJson(v));
      });
    }
  }
}

class ScheduleModel {
  ScheduleModel({
    num? id,
    String? datetime,
    String? title,
    String? address,
    String? matchedUserName,
    String? matchedUserImg,
  }) {
    _id = id;
    _datetime = datetime;
    _title = title;
    _address = address;
    _matchedUserName = matchedUserName;
    _matchedUserImg = matchedUserImg;
  }

  ScheduleModel.fromJson(dynamic json) {
    _id = json['id'];
    _datetime = json['datetime'];
    _title = json['title'];
    _address = json['address'];
    _matchedUserName = json['matched_user_name'];
    _matchedUserImg = json['matched_user_img'];
  }

  num? _id;
  String? _datetime;
  String? _title;
  String? _address;
  String? _matchedUserName;
  String? _matchedUserImg;

  ScheduleModel copyWith({
    num? id,
    String? datetime,
    String? title,
    String? address,
    String? matchedUserName,
    String? matchedUserImg,
  }) =>
      ScheduleModel(
        id: id ?? _id,
        datetime: datetime ?? _datetime,
        title: title ?? _title,
        address: address ?? _address,
        matchedUserName: matchedUserName ?? _matchedUserName,
        matchedUserImg: matchedUserImg ?? _matchedUserImg,
      );

  num? get id => _id;

  String? get datetime => _datetime;

  String? get title => _title;

  String? get address => _address;

  String? get matchedUserName => _matchedUserName;

  String? get matchedUserImg => _matchedUserImg;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['datetime'] = _datetime;
    map['title'] = _title;
    map['address'] = _address;
    map['matched_user_name'] = _matchedUserName;
    map['matched_user_img'] = _matchedUserImg;
    return map;
  }
}
