part of 'default.dart';

class AddLoanContactVariablesBuilder {
  String requestId;
  String relation;
  String firstName;
  String lastName;
  String phone;

  final FirebaseDataConnect _dataConnect;
  AddLoanContactVariablesBuilder(this._dataConnect, {required  this.requestId,required  this.relation,required  this.firstName,required  this.lastName,required  this.phone,});
  Deserializer<AddLoanContactData> dataDeserializer = (dynamic json)  => AddLoanContactData.fromJson(jsonDecode(json));
  Serializer<AddLoanContactVariables> varsSerializer = (AddLoanContactVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddLoanContactData, AddLoanContactVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AddLoanContactData, AddLoanContactVariables> ref() {
    AddLoanContactVariables vars= AddLoanContactVariables(requestId: requestId,relation: relation,firstName: firstName,lastName: lastName,phone: phone,);
    return _dataConnect.mutation("AddLoanContact", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AddLoanContactLoanContactInsert {
  final String id;
  AddLoanContactLoanContactInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddLoanContactLoanContactInsert otherTyped = other as AddLoanContactLoanContactInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AddLoanContactLoanContactInsert({
    required this.id,
  });
}

@immutable
class AddLoanContactData {
  final AddLoanContactLoanContactInsert loanContact_insert;
  AddLoanContactData.fromJson(dynamic json):
  
  loanContact_insert = AddLoanContactLoanContactInsert.fromJson(json['loanContact_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddLoanContactData otherTyped = other as AddLoanContactData;
    return loanContact_insert == otherTyped.loanContact_insert;
    
  }
  @override
  int get hashCode => loanContact_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['loanContact_insert'] = loanContact_insert.toJson();
    return json;
  }

  AddLoanContactData({
    required this.loanContact_insert,
  });
}

@immutable
class AddLoanContactVariables {
  final String requestId;
  final String relation;
  final String firstName;
  final String lastName;
  final String phone;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddLoanContactVariables.fromJson(Map<String, dynamic> json):
  
  requestId = nativeFromJson<String>(json['requestId']),
  relation = nativeFromJson<String>(json['relation']),
  firstName = nativeFromJson<String>(json['firstName']),
  lastName = nativeFromJson<String>(json['lastName']),
  phone = nativeFromJson<String>(json['phone']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddLoanContactVariables otherTyped = other as AddLoanContactVariables;
    return requestId == otherTyped.requestId && 
    relation == otherTyped.relation && 
    firstName == otherTyped.firstName && 
    lastName == otherTyped.lastName && 
    phone == otherTyped.phone;
    
  }
  @override
  int get hashCode => Object.hashAll([requestId.hashCode, relation.hashCode, firstName.hashCode, lastName.hashCode, phone.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['requestId'] = nativeToJson<String>(requestId);
    json['relation'] = nativeToJson<String>(relation);
    json['firstName'] = nativeToJson<String>(firstName);
    json['lastName'] = nativeToJson<String>(lastName);
    json['phone'] = nativeToJson<String>(phone);
    return json;
  }

  AddLoanContactVariables({
    required this.requestId,
    required this.relation,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });
}

