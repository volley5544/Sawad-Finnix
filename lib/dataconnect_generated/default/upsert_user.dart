part of 'default.dart';

class UpsertUserVariablesBuilder {
  String id;
  String uid;
  Optional<String> _phoneNumber = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _thaiId = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _nameTh = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _nameEn = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _gender = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _address = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _houseAddress = Optional.optional(nativeFromJson, nativeToJson);
  Optional<DateTime> _dateOfBirth = Optional.optional(nativeFromJson, nativeToJson);
  Optional<int> _tokenIssuedAt = Optional.optional(nativeFromJson, nativeToJson);
  Optional<int> _tokenExpiresAt = Optional.optional(nativeFromJson, nativeToJson);
  Optional<int> _authTime = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  UpsertUserVariablesBuilder phoneNumber(String? t) {
   _phoneNumber.value = t;
   return this;
  }
  UpsertUserVariablesBuilder thaiId(String? t) {
   _thaiId.value = t;
   return this;
  }
  UpsertUserVariablesBuilder nameTh(String? t) {
   _nameTh.value = t;
   return this;
  }
  UpsertUserVariablesBuilder nameEn(String? t) {
   _nameEn.value = t;
   return this;
  }
  UpsertUserVariablesBuilder gender(String? t) {
   _gender.value = t;
   return this;
  }
  UpsertUserVariablesBuilder address(String? t) {
   _address.value = t;
   return this;
  }
  UpsertUserVariablesBuilder houseAddress(String? t) {
   _houseAddress.value = t;
   return this;
  }
  UpsertUserVariablesBuilder dateOfBirth(DateTime? t) {
   _dateOfBirth.value = t;
   return this;
  }
  UpsertUserVariablesBuilder tokenIssuedAt(int? t) {
   _tokenIssuedAt.value = t;
   return this;
  }
  UpsertUserVariablesBuilder tokenExpiresAt(int? t) {
   _tokenExpiresAt.value = t;
   return this;
  }
  UpsertUserVariablesBuilder authTime(int? t) {
   _authTime.value = t;
   return this;
  }

  UpsertUserVariablesBuilder(this._dataConnect, {required  this.id,required  this.uid,});
  Deserializer<UpsertUserData> dataDeserializer = (dynamic json)  => UpsertUserData.fromJson(jsonDecode(json));
  Serializer<UpsertUserVariables> varsSerializer = (UpsertUserVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpsertUserData, UpsertUserVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpsertUserData, UpsertUserVariables> ref() {
    UpsertUserVariables vars= UpsertUserVariables(id: id,uid: uid,phoneNumber: _phoneNumber,thaiId: _thaiId,nameTh: _nameTh,nameEn: _nameEn,gender: _gender,address: _address,houseAddress: _houseAddress,dateOfBirth: _dateOfBirth,tokenIssuedAt: _tokenIssuedAt,tokenExpiresAt: _tokenExpiresAt,authTime: _authTime,);
    return _dataConnect.mutation("UpsertUser", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpsertUserUserUpsert {
  final String id;
  UpsertUserUserUpsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertUserUserUpsert otherTyped = other as UpsertUserUserUpsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpsertUserUserUpsert({
    required this.id,
  });
}

@immutable
class UpsertUserData {
  final UpsertUserUserUpsert user_upsert;
  UpsertUserData.fromJson(dynamic json):
  
  user_upsert = UpsertUserUserUpsert.fromJson(json['user_upsert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertUserData otherTyped = other as UpsertUserData;
    return user_upsert == otherTyped.user_upsert;
    
  }
  @override
  int get hashCode => user_upsert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['user_upsert'] = user_upsert.toJson();
    return json;
  }

  UpsertUserData({
    required this.user_upsert,
  });
}

@immutable
class UpsertUserVariables {
  final String id;
  final String uid;
  late final Optional<String>phoneNumber;
  late final Optional<String>thaiId;
  late final Optional<String>nameTh;
  late final Optional<String>nameEn;
  late final Optional<String>gender;
  late final Optional<String>address;
  late final Optional<String>houseAddress;
  late final Optional<DateTime>dateOfBirth;
  late final Optional<int>tokenIssuedAt;
  late final Optional<int>tokenExpiresAt;
  late final Optional<int>authTime;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpsertUserVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  uid = nativeFromJson<String>(json['uid']) {
  
  
  
  
    phoneNumber = Optional.optional(nativeFromJson, nativeToJson);
    phoneNumber.value = json['phoneNumber'] == null ? null : nativeFromJson<String>(json['phoneNumber']);
  
  
    thaiId = Optional.optional(nativeFromJson, nativeToJson);
    thaiId.value = json['thaiId'] == null ? null : nativeFromJson<String>(json['thaiId']);
  
  
    nameTh = Optional.optional(nativeFromJson, nativeToJson);
    nameTh.value = json['nameTh'] == null ? null : nativeFromJson<String>(json['nameTh']);
  
  
    nameEn = Optional.optional(nativeFromJson, nativeToJson);
    nameEn.value = json['nameEn'] == null ? null : nativeFromJson<String>(json['nameEn']);
  
  
    gender = Optional.optional(nativeFromJson, nativeToJson);
    gender.value = json['gender'] == null ? null : nativeFromJson<String>(json['gender']);
  
  
    address = Optional.optional(nativeFromJson, nativeToJson);
    address.value = json['address'] == null ? null : nativeFromJson<String>(json['address']);
  
  
    houseAddress = Optional.optional(nativeFromJson, nativeToJson);
    houseAddress.value = json['houseAddress'] == null ? null : nativeFromJson<String>(json['houseAddress']);
  
  
    dateOfBirth = Optional.optional(nativeFromJson, nativeToJson);
    dateOfBirth.value = json['dateOfBirth'] == null ? null : nativeFromJson<DateTime>(json['dateOfBirth']);
  
  
    tokenIssuedAt = Optional.optional(nativeFromJson, nativeToJson);
    tokenIssuedAt.value = json['tokenIssuedAt'] == null ? null : nativeFromJson<int>(json['tokenIssuedAt']);
  
  
    tokenExpiresAt = Optional.optional(nativeFromJson, nativeToJson);
    tokenExpiresAt.value = json['tokenExpiresAt'] == null ? null : nativeFromJson<int>(json['tokenExpiresAt']);
  
  
    authTime = Optional.optional(nativeFromJson, nativeToJson);
    authTime.value = json['authTime'] == null ? null : nativeFromJson<int>(json['authTime']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertUserVariables otherTyped = other as UpsertUserVariables;
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
    tokenIssuedAt == otherTyped.tokenIssuedAt && 
    tokenExpiresAt == otherTyped.tokenExpiresAt && 
    authTime == otherTyped.authTime;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, uid.hashCode, phoneNumber.hashCode, thaiId.hashCode, nameTh.hashCode, nameEn.hashCode, gender.hashCode, address.hashCode, houseAddress.hashCode, dateOfBirth.hashCode, tokenIssuedAt.hashCode, tokenExpiresAt.hashCode, authTime.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['uid'] = nativeToJson<String>(uid);
    if(phoneNumber.state == OptionalState.set) {
      json['phoneNumber'] = phoneNumber.toJson();
    }
    if(thaiId.state == OptionalState.set) {
      json['thaiId'] = thaiId.toJson();
    }
    if(nameTh.state == OptionalState.set) {
      json['nameTh'] = nameTh.toJson();
    }
    if(nameEn.state == OptionalState.set) {
      json['nameEn'] = nameEn.toJson();
    }
    if(gender.state == OptionalState.set) {
      json['gender'] = gender.toJson();
    }
    if(address.state == OptionalState.set) {
      json['address'] = address.toJson();
    }
    if(houseAddress.state == OptionalState.set) {
      json['houseAddress'] = houseAddress.toJson();
    }
    if(dateOfBirth.state == OptionalState.set) {
      json['dateOfBirth'] = dateOfBirth.toJson();
    }
    if(tokenIssuedAt.state == OptionalState.set) {
      json['tokenIssuedAt'] = tokenIssuedAt.toJson();
    }
    if(tokenExpiresAt.state == OptionalState.set) {
      json['tokenExpiresAt'] = tokenExpiresAt.toJson();
    }
    if(authTime.state == OptionalState.set) {
      json['authTime'] = authTime.toJson();
    }
    return json;
  }

  UpsertUserVariables({
    required this.id,
    required this.uid,
    required this.phoneNumber,
    required this.thaiId,
    required this.nameTh,
    required this.nameEn,
    required this.gender,
    required this.address,
    required this.houseAddress,
    required this.dateOfBirth,
    required this.tokenIssuedAt,
    required this.tokenExpiresAt,
    required this.authTime,
  });
}

