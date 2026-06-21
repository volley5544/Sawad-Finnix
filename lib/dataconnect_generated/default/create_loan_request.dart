part of 'default.dart';

class CreateLoanRequestVariablesBuilder {
  String userId;
  Optional<String> _thaiId = Optional.optional(nativeFromJson, nativeToJson);
  String nameTh;
  Optional<DateTime> _dateOfBirth = Optional.optional(nativeFromJson, nativeToJson);
  String idCardAddress;
  bool contactsGranted;
  bool deviceInfoGranted;
  bool locationGranted;
  bool smsGranted;
  String currentAddress;
  String area;
  String postcode;
  bool sameAsIdCard;
  String email;
  String education;
  String payrollBank;
  bool includeOtherBanks;
  bool agreeTerms;
  bool marketingConsent;
  bool creditModelConsent;
  bool productConsent;

  final FirebaseDataConnect _dataConnect;  CreateLoanRequestVariablesBuilder thaiId(String? t) {
   _thaiId.value = t;
   return this;
  }
  CreateLoanRequestVariablesBuilder dateOfBirth(DateTime? t) {
   _dateOfBirth.value = t;
   return this;
  }

  CreateLoanRequestVariablesBuilder(this._dataConnect, {required  this.userId,required  this.nameTh,required  this.idCardAddress,required  this.contactsGranted,required  this.deviceInfoGranted,required  this.locationGranted,required  this.smsGranted,required  this.currentAddress,required  this.area,required  this.postcode,required  this.sameAsIdCard,required  this.email,required  this.education,required  this.payrollBank,required  this.includeOtherBanks,required  this.agreeTerms,required  this.marketingConsent,required  this.creditModelConsent,required  this.productConsent,});
  Deserializer<CreateLoanRequestData> dataDeserializer = (dynamic json)  => CreateLoanRequestData.fromJson(jsonDecode(json));
  Serializer<CreateLoanRequestVariables> varsSerializer = (CreateLoanRequestVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateLoanRequestData, CreateLoanRequestVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateLoanRequestData, CreateLoanRequestVariables> ref() {
    CreateLoanRequestVariables vars= CreateLoanRequestVariables(userId: userId,thaiId: _thaiId,nameTh: nameTh,dateOfBirth: _dateOfBirth,idCardAddress: idCardAddress,contactsGranted: contactsGranted,deviceInfoGranted: deviceInfoGranted,locationGranted: locationGranted,smsGranted: smsGranted,currentAddress: currentAddress,area: area,postcode: postcode,sameAsIdCard: sameAsIdCard,email: email,education: education,payrollBank: payrollBank,includeOtherBanks: includeOtherBanks,agreeTerms: agreeTerms,marketingConsent: marketingConsent,creditModelConsent: creditModelConsent,productConsent: productConsent,);
    return _dataConnect.mutation("CreateLoanRequest", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateLoanRequestLoanRequestInsert {
  final String id;
  CreateLoanRequestLoanRequestInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateLoanRequestLoanRequestInsert otherTyped = other as CreateLoanRequestLoanRequestInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateLoanRequestLoanRequestInsert({
    required this.id,
  });
}

@immutable
class CreateLoanRequestData {
  final CreateLoanRequestLoanRequestInsert loanRequest_insert;
  CreateLoanRequestData.fromJson(dynamic json):
  
  loanRequest_insert = CreateLoanRequestLoanRequestInsert.fromJson(json['loanRequest_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateLoanRequestData otherTyped = other as CreateLoanRequestData;
    return loanRequest_insert == otherTyped.loanRequest_insert;
    
  }
  @override
  int get hashCode => loanRequest_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['loanRequest_insert'] = loanRequest_insert.toJson();
    return json;
  }

  CreateLoanRequestData({
    required this.loanRequest_insert,
  });
}

@immutable
class CreateLoanRequestVariables {
  final String userId;
  late final Optional<String>thaiId;
  final String nameTh;
  late final Optional<DateTime>dateOfBirth;
  final String idCardAddress;
  final bool contactsGranted;
  final bool deviceInfoGranted;
  final bool locationGranted;
  final bool smsGranted;
  final String currentAddress;
  final String area;
  final String postcode;
  final bool sameAsIdCard;
  final String email;
  final String education;
  final String payrollBank;
  final bool includeOtherBanks;
  final bool agreeTerms;
  final bool marketingConsent;
  final bool creditModelConsent;
  final bool productConsent;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateLoanRequestVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']),
  nameTh = nativeFromJson<String>(json['nameTh']),
  idCardAddress = nativeFromJson<String>(json['idCardAddress']),
  contactsGranted = nativeFromJson<bool>(json['contactsGranted']),
  deviceInfoGranted = nativeFromJson<bool>(json['deviceInfoGranted']),
  locationGranted = nativeFromJson<bool>(json['locationGranted']),
  smsGranted = nativeFromJson<bool>(json['smsGranted']),
  currentAddress = nativeFromJson<String>(json['currentAddress']),
  area = nativeFromJson<String>(json['area']),
  postcode = nativeFromJson<String>(json['postcode']),
  sameAsIdCard = nativeFromJson<bool>(json['sameAsIdCard']),
  email = nativeFromJson<String>(json['email']),
  education = nativeFromJson<String>(json['education']),
  payrollBank = nativeFromJson<String>(json['payrollBank']),
  includeOtherBanks = nativeFromJson<bool>(json['includeOtherBanks']),
  agreeTerms = nativeFromJson<bool>(json['agreeTerms']),
  marketingConsent = nativeFromJson<bool>(json['marketingConsent']),
  creditModelConsent = nativeFromJson<bool>(json['creditModelConsent']),
  productConsent = nativeFromJson<bool>(json['productConsent']) {
  
  
  
    thaiId = Optional.optional(nativeFromJson, nativeToJson);
    thaiId.value = json['thaiId'] == null ? null : nativeFromJson<String>(json['thaiId']);
  
  
  
    dateOfBirth = Optional.optional(nativeFromJson, nativeToJson);
    dateOfBirth.value = json['dateOfBirth'] == null ? null : nativeFromJson<DateTime>(json['dateOfBirth']);
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateLoanRequestVariables otherTyped = other as CreateLoanRequestVariables;
    return userId == otherTyped.userId && 
    thaiId == otherTyped.thaiId && 
    nameTh == otherTyped.nameTh && 
    dateOfBirth == otherTyped.dateOfBirth && 
    idCardAddress == otherTyped.idCardAddress && 
    contactsGranted == otherTyped.contactsGranted && 
    deviceInfoGranted == otherTyped.deviceInfoGranted && 
    locationGranted == otherTyped.locationGranted && 
    smsGranted == otherTyped.smsGranted && 
    currentAddress == otherTyped.currentAddress && 
    area == otherTyped.area && 
    postcode == otherTyped.postcode && 
    sameAsIdCard == otherTyped.sameAsIdCard && 
    email == otherTyped.email && 
    education == otherTyped.education && 
    payrollBank == otherTyped.payrollBank && 
    includeOtherBanks == otherTyped.includeOtherBanks && 
    agreeTerms == otherTyped.agreeTerms && 
    marketingConsent == otherTyped.marketingConsent && 
    creditModelConsent == otherTyped.creditModelConsent && 
    productConsent == otherTyped.productConsent;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, thaiId.hashCode, nameTh.hashCode, dateOfBirth.hashCode, idCardAddress.hashCode, contactsGranted.hashCode, deviceInfoGranted.hashCode, locationGranted.hashCode, smsGranted.hashCode, currentAddress.hashCode, area.hashCode, postcode.hashCode, sameAsIdCard.hashCode, email.hashCode, education.hashCode, payrollBank.hashCode, includeOtherBanks.hashCode, agreeTerms.hashCode, marketingConsent.hashCode, creditModelConsent.hashCode, productConsent.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    if(thaiId.state == OptionalState.set) {
      json['thaiId'] = thaiId.toJson();
    }
    json['nameTh'] = nativeToJson<String>(nameTh);
    if(dateOfBirth.state == OptionalState.set) {
      json['dateOfBirth'] = dateOfBirth.toJson();
    }
    json['idCardAddress'] = nativeToJson<String>(idCardAddress);
    json['contactsGranted'] = nativeToJson<bool>(contactsGranted);
    json['deviceInfoGranted'] = nativeToJson<bool>(deviceInfoGranted);
    json['locationGranted'] = nativeToJson<bool>(locationGranted);
    json['smsGranted'] = nativeToJson<bool>(smsGranted);
    json['currentAddress'] = nativeToJson<String>(currentAddress);
    json['area'] = nativeToJson<String>(area);
    json['postcode'] = nativeToJson<String>(postcode);
    json['sameAsIdCard'] = nativeToJson<bool>(sameAsIdCard);
    json['email'] = nativeToJson<String>(email);
    json['education'] = nativeToJson<String>(education);
    json['payrollBank'] = nativeToJson<String>(payrollBank);
    json['includeOtherBanks'] = nativeToJson<bool>(includeOtherBanks);
    json['agreeTerms'] = nativeToJson<bool>(agreeTerms);
    json['marketingConsent'] = nativeToJson<bool>(marketingConsent);
    json['creditModelConsent'] = nativeToJson<bool>(creditModelConsent);
    json['productConsent'] = nativeToJson<bool>(productConsent);
    return json;
  }

  CreateLoanRequestVariables({
    required this.userId,
    required this.thaiId,
    required this.nameTh,
    required this.dateOfBirth,
    required this.idCardAddress,
    required this.contactsGranted,
    required this.deviceInfoGranted,
    required this.locationGranted,
    required this.smsGranted,
    required this.currentAddress,
    required this.area,
    required this.postcode,
    required this.sameAsIdCard,
    required this.email,
    required this.education,
    required this.payrollBank,
    required this.includeOtherBanks,
    required this.agreeTerms,
    required this.marketingConsent,
    required this.creditModelConsent,
    required this.productConsent,
  });
}

