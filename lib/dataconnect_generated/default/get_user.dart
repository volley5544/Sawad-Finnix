part of 'default.dart';

class GetUserVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  GetUserVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<GetUserData> dataDeserializer = (dynamic json)  => GetUserData.fromJson(jsonDecode(json));
  Serializer<GetUserVariables> varsSerializer = (GetUserVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetUserData, GetUserVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetUserData, GetUserVariables> ref() {
    GetUserVariables vars= GetUserVariables(id: id,);
    return _dataConnect.query("GetUser", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetUserUser {
  final String id;
  final String uid;
  final String? phoneNumber;
  final String? thaiId;
  final String? nameTh;
  final String? nameEn;
  final String? gender;
  final String? address;
  final String? houseAddress;
  final DateTime? dateOfBirth;
  final bool hasPin;
  final Timestamp createdAt;
  GetUserUser.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  uid = nativeFromJson<String>(json['uid']),
  phoneNumber = json['phoneNumber'] == null ? null : nativeFromJson<String>(json['phoneNumber']),
  thaiId = json['thaiId'] == null ? null : nativeFromJson<String>(json['thaiId']),
  nameTh = json['nameTh'] == null ? null : nativeFromJson<String>(json['nameTh']),
  nameEn = json['nameEn'] == null ? null : nativeFromJson<String>(json['nameEn']),
  gender = json['gender'] == null ? null : nativeFromJson<String>(json['gender']),
  address = json['address'] == null ? null : nativeFromJson<String>(json['address']),
  houseAddress = json['houseAddress'] == null ? null : nativeFromJson<String>(json['houseAddress']),
  dateOfBirth = json['dateOfBirth'] == null ? null : nativeFromJson<DateTime>(json['dateOfBirth']),
  hasPin = nativeFromJson<bool>(json['hasPin']),
  createdAt = Timestamp.fromJson(json['createdAt']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserUser otherTyped = other as GetUserUser;
    return id == otherTyped.id && 
    uid == otherTyped.uid && 
    phoneNumber == otherTyped.phoneNumber && 
    thaiId == otherTyped.thaiId && 
    nameTh == otherTyped.nameTh && 
    nameEn == otherTyped.nameEn && 
    gender == otherTyped.gender && 
    address == otherTyped.address && 
    houseAddress == otherTyped.houseAddress && 
    dateOfBirth == otherTyped.dateOfBirth && 
    hasPin == otherTyped.hasPin && 
    createdAt == otherTyped.createdAt;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, uid.hashCode, phoneNumber.hashCode, thaiId.hashCode, nameTh.hashCode, nameEn.hashCode, gender.hashCode, address.hashCode, houseAddress.hashCode, dateOfBirth.hashCode, hasPin.hashCode, createdAt.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['uid'] = nativeToJson<String>(uid);
    if (phoneNumber != null) {
      json['phoneNumber'] = nativeToJson<String?>(phoneNumber);
    }
    if (thaiId != null) {
      json['thaiId'] = nativeToJson<String?>(thaiId);
    }
    if (nameTh != null) {
      json['nameTh'] = nativeToJson<String?>(nameTh);
    }
    if (nameEn != null) {
      json['nameEn'] = nativeToJson<String?>(nameEn);
    }
    if (gender != null) {
      json['gender'] = nativeToJson<String?>(gender);
    }
    if (address != null) {
      json['address'] = nativeToJson<String?>(address);
    }
    if (houseAddress != null) {
      json['houseAddress'] = nativeToJson<String?>(houseAddress);
    }
    if (dateOfBirth != null) {
      json['dateOfBirth'] = nativeToJson<DateTime?>(dateOfBirth);
    }
    json['hasPin'] = nativeToJson<bool>(hasPin);
    json['createdAt'] = createdAt.toJson();
    return json;
  }

  GetUserUser({
    required this.id,
    required this.uid,
    this.phoneNumber,
    this.thaiId,
    this.nameTh,
    this.nameEn,
    this.gender,
    this.address,
    this.houseAddress,
    this.dateOfBirth,
    required this.hasPin,
    required this.createdAt,
  });
}

@immutable
class GetUserData {
  final GetUserUser? user;
  GetUserData.fromJson(dynamic json):
  
  user = json['user'] == null ? null : GetUserUser.fromJson(json['user']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserData otherTyped = other as GetUserData;
    return user == otherTyped.user;
    
  }
  @override
  int get hashCode => user.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (user != null) {
      json['user'] = user!.toJson();
    }
    return json;
  }

  GetUserData({
    this.user,
  });
}

@immutable
class GetUserVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetUserVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserVariables otherTyped = other as GetUserVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  GetUserVariables({
    required this.id,
  });
}

