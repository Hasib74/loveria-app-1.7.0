/// status : "success"
/// data : [{"_id":"19","_uid":"0cae9380-53d9-47b6-bb49-81e0e38f0046","created_at":"2024-02-18 17:55:19","updated_at":"2024-02-18 17:55:19","username":"biggorilla515","email":"meghashree.fernandes@example.com","password":"$2y$10$t7PR2CK5uPgItulLgES9tuiLDrmUhO.steYd1vVXdfEUxQ7txfVcq","status":"5","remember_token":null,"first_name":"Meghashree","last_name":"Fernandes","designation":null,"mobile_number":"7585121482","timezone":"Eastern Australia, Guam, Vladivostok","registered_via":null,"block_reason":null,"is_fake":"1","image":"http://dating.paksang.com/","location":"Hong Kong"},{"_id":"45","_uid":"38ca64e0-f6af-48f5-8a9f-1aeb54cca2a1","created_at":"2024-02-18 18:21:21","updated_at":"2024-02-18 18:21:21","username":"sadladybug762","email":"ziggy.leene@example.com","password":"$2y$10$.1jK862GsZcqxGmb5FmTmeKif7.XFLfgHcWPf8XF3gScSF21VVu16","status":"5","remember_token":null,"first_name":"Ziggy","last_name":"Leene","designation":null,"mobile_number":"(084) 7248837","timezone":"Kabul","registered_via":null,"block_reason":null,"is_fake":"1","image":"http://dating.paksang.com/","location":"Hong Kong"},{"_id":"66","_uid":"1f5e021e-e18c-461d-87f6-6ea84e78b16b","created_at":"2024-02-18 18:42:23","updated_at":"2024-02-18 18:42:23","username":"tinysnake364","email":"camille.faure@example.com","password":"$2y$10$tG8YKkdb6003MHZpD71puuxmlIKa0xpEYnLYYakxsfoG.clMc.9Ly","status":"5","remember_token":null,"first_name":"Camille","last_name":"Faure","designation":null,"mobile_number":"01-81-23-61-17","timezone":"Atlantic Time (Canada), Caracas, La Paz","registered_via":null,"block_reason":null,"is_fake":"1","image":"http://dating.paksang.com/","location":"Hong Kong"},{"_id":"72","_uid":"7af69bea-069c-4963-a653-c6bf86fc584c","created_at":"2024-02-18 18:48:24","updated_at":"2024-02-18 18:48:24","username":"redpanda891","email":"samuel.morris@example.com","password":"$2y$10$Ju7psLiTCDF5iRUAtyyaX.jlxFX5UpvQ1RtkdkIZa.qIceJ09EtfG","status":"5","remember_token":null,"first_name":"Samuel","last_name":"Morris","designation":null,"mobile_number":"021-506-6359","timezone":"Central Time (US & Canada), Mexico City","registered_via":null,"block_reason":null,"is_fake":"1","image":"http://dating.paksang.com/","location":"Hong Kong"},{"_id":"73","_uid":"24ea7182-8c7f-43f1-bc4c-6fb228405ed3","created_at":"2024-02-18 18:49:24","updated_at":"2024-02-18 18:49:24","username":"blacksnake582","email":"tobias.olsen@example.com","password":"$2y$10$V0OkL5A3AqC3nUGNsV3sQOSh6tynAesk7GfLFJ39/OhQ4dUMB3n/a","status":"5","remember_token":null,"first_name":"Tobias","last_name":"Olsen","designation":null,"mobile_number":"93881761","timezone":"Eastern Australia, Guam, Vladivostok","registered_via":null,"block_reason":null,"is_fake":"1","image":"http://dating.paksang.com/","location":"Hong Kong"}]

class SuggestionListResponseModel {
  SuggestionListResponseModel({
      this.status, 
      this.data,});

  SuggestionListResponseModel.fromJson(dynamic json) {
    status = json['status'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
  }
  String? status;
  List<Data>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// _id : "19"
/// _uid : "0cae9380-53d9-47b6-bb49-81e0e38f0046"
/// created_at : "2024-02-18 17:55:19"
/// updated_at : "2024-02-18 17:55:19"
/// username : "biggorilla515"
/// email : "meghashree.fernandes@example.com"
/// password : "$2y$10$t7PR2CK5uPgItulLgES9tuiLDrmUhO.steYd1vVXdfEUxQ7txfVcq"
/// status : "5"
/// remember_token : null
/// first_name : "Meghashree"
/// last_name : "Fernandes"
/// designation : null
/// mobile_number : "7585121482"
/// timezone : "Eastern Australia, Guam, Vladivostok"
/// registered_via : null
/// block_reason : null
/// is_fake : "1"
/// image : "http://dating.paksang.com/"
/// location : "Hong Kong"

class Data {
  Data({
      this.id, 
      this.uid, 
      this.createdAt, 
      this.updatedAt, 
      this.username, 
      this.email, 
      this.password, 
      this.status, 
      this.rememberToken, 
      this.firstName, 
      this.lastName, 
      this.designation, 
      this.mobileNumber, 
      this.timezone, 
      this.registeredVia, 
      this.blockReason, 
      this.isFake, 
      this.image, 
      this.location,});

  Data.fromJson(dynamic json) {
    id = json['_id'];
    uid = json['_uid'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    username = json['username'];
    email = json['email'];
    password = json['password'];
    status = json['status'];
    rememberToken = json['remember_token'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    designation = json['designation'];
    mobileNumber = json['mobile_number'];
    timezone = json['timezone'];
    registeredVia = json['registered_via'];
    blockReason = json['block_reason'];
    isFake = json['is_fake'];
    image = json['image'];
    location = json['location'];
  }
  String? id;
  String? uid;
  String? createdAt;
  String? updatedAt;
  String? username;
  String? email;
  String? password;
  String? status;
  dynamic rememberToken;
  String? firstName;
  String? lastName;
  dynamic designation;
  String? mobileNumber;
  String? timezone;
  dynamic registeredVia;
  dynamic blockReason;
  String? isFake;
  String? image;
  String? location;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['_uid'] = uid;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['username'] = username;
    map['email'] = email;
    map['password'] = password;
    map['status'] = status;
    map['remember_token'] = rememberToken;
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    map['designation'] = designation;
    map['mobile_number'] = mobileNumber;
    map['timezone'] = timezone;
    map['registered_via'] = registeredVia;
    map['block_reason'] = blockReason;
    map['is_fake'] = isFake;
    map['image'] = image;
    map['location'] = location;
    return map;
  }

}