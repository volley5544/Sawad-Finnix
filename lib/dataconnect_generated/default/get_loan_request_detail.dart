part of 'default.dart';

class GetLoanRequestDetailVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  GetLoanRequestDetailVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<GetLoanRequestDetailData> dataDeserializer = (dynamic json)  => GetLoanRequestDetailData.fromJson(jsonDecode(json));
  Serializer<GetLoanRequestDetailVariables> varsSerializer = (GetLoanRequestDetailVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetLoanRequestDetailData, GetLoanRequestDetailVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetLoanRequestDetailData, GetLoanRequestDetailVariables> ref() {
    GetLoanRequestDetailVariables vars= GetLoanRequestDetailVariables(id: id,);
    return _dataConnect.query("GetLoanRequestDetail", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetLoanRequestDetailLoanRequest {
  final String id;
  final String nameTh;
  final String idCardAddress;
  final String currentAddress;
  final String email;
  final String education;
  final String payrollBank;
  final String status;
  final Timestamp createdAt;
  final List<GetLoanRequestDetailLoanRequestContactsOnRequest> contacts_on_request;
  final List<GetLoanRequestDetailLoanRequestStatementsOnRequest> statements_on_request;
  GetLoanRequestDetailLoanRequest.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  nameTh = nativeFromJson<String>(json['nameTh']),
  idCardAddress = nativeFromJson<String>(json['idCardAddress']),
  currentAddress = nativeFromJson<String>(json['currentAddress']),
  email = nativeFromJson<String>(json['email']),
  education = nativeFromJson<String>(json['education']),
  payrollBank = nativeFromJson<String>(json['payrollBank']),
  status = nativeFromJson<String>(json['status']),
  createdAt = Timestamp.fromJson(json['createdAt']),
  contacts_on_request = (json['contacts_on_request'] as List<dynamic>)
        .map((e) => GetLoanRequestDetailLoanRequestContactsOnRequest.fromJson(e))
        .toList(),
  statements_on_request = (json['statements_on_request'] as List<dynamic>)
        .map((e) => GetLoanRequestDetailLoanRequestStatementsOnRequest.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetLoanRequestDetailLoanRequest otherTyped = other as GetLoanRequestDetailLoanRequest;
    return id == otherTyped.id && 
    nameTh == otherTyped.nameTh && 
    idCardAddress == otherTyped.idCardAddress && 
    currentAddress == otherTyped.currentAddress && 
    email == otherTyped.email && 
    education == otherTyped.education && 
    payrollBank == otherTyped.payrollBank && 
    status == otherTyped.status && 
    createdAt == otherTyped.createdAt && 
    contacts_on_request == otherTyped.contacts_on_request && 
    statements_on_request == otherTyped.statements_on_request;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nameTh.hashCode, idCardAddress.hashCode, currentAddress.hashCode, email.hashCode, education.hashCode, payrollBank.hashCode, status.hashCode, createdAt.hashCode, contacts_on_request.hashCode, statements_on_request.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nameTh'] = nativeToJson<String>(nameTh);
    json['idCardAddress'] = nativeToJson<String>(idCardAddress);
    json['currentAddress'] = nativeToJson<String>(currentAddress);
    json['email'] = nativeToJson<String>(email);
    json['education'] = nativeToJson<String>(education);
    json['payrollBank'] = nativeToJson<String>(payrollBank);
    json['status'] = nativeToJson<String>(status);
    json['createdAt'] = createdAt.toJson();
    json['contacts_on_request'] = contacts_on_request.map((e) => e.toJson()).toList();
    json['statements_on_request'] = statements_on_request.map((e) => e.toJson()).toList();
    return json;
  }

  GetLoanRequestDetailLoanRequest({
    required this.id,
    required this.nameTh,
    required this.idCardAddress,
    required this.currentAddress,
    required this.email,
    required this.education,
    required this.payrollBank,
    required this.status,
    required this.createdAt,
    required this.contacts_on_request,
    required this.statements_on_request,
  });
}

@immutable
class GetLoanRequestDetailLoanRequestContactsOnRequest {
  final String relation;
  final String firstName;
  final String lastName;
  final String phone;
  GetLoanRequestDetailLoanRequestContactsOnRequest.fromJson(dynamic json):
  
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

    final GetLoanRequestDetailLoanRequestContactsOnRequest otherTyped = other as GetLoanRequestDetailLoanRequestContactsOnRequest;
    return relation == otherTyped.relation && 
    firstName == otherTyped.firstName && 
    lastName == otherTyped.lastName && 
    phone == otherTyped.phone;
    
  }
  @override
  int get hashCode => Object.hashAll([relation.hashCode, firstName.hashCode, lastName.hashCode, phone.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['relation'] = nativeToJson<String>(relation);
    json['firstName'] = nativeToJson<String>(firstName);
    json['lastName'] = nativeToJson<String>(lastName);
    json['phone'] = nativeToJson<String>(phone);
    return json;
  }

  GetLoanRequestDetailLoanRequestContactsOnRequest({
    required this.relation,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });
}

@immutable
class GetLoanRequestDetailLoanRequestStatementsOnRequest {
  final String name;
  final String url;
  final int size;
  final String? contentType;
  GetLoanRequestDetailLoanRequestStatementsOnRequest.fromJson(dynamic json):
  
  name = nativeFromJson<String>(json['name']),
  url = nativeFromJson<String>(json['url']),
  size = nativeFromJson<int>(json['size']),
  contentType = json['contentType'] == null ? null : nativeFromJson<String>(json['contentType']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetLoanRequestDetailLoanRequestStatementsOnRequest otherTyped = other as GetLoanRequestDetailLoanRequestStatementsOnRequest;
    return name == otherTyped.name && 
    url == otherTyped.url && 
    size == otherTyped.size && 
    contentType == otherTyped.contentType;
    
  }
  @override
  int get hashCode => Object.hashAll([name.hashCode, url.hashCode, size.hashCode, contentType.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    json['url'] = nativeToJson<String>(url);
    json['size'] = nativeToJson<int>(size);
    if (contentType != null) {
      json['contentType'] = nativeToJson<String?>(contentType);
    }
    return json;
  }

  GetLoanRequestDetailLoanRequestStatementsOnRequest({
    required this.name,
    required this.url,
    required this.size,
    this.contentType,
  });
}

@immutable
class GetLoanRequestDetailData {
  final GetLoanRequestDetailLoanRequest? loanRequest;
  GetLoanRequestDetailData.fromJson(dynamic json):
  
  loanRequest = json['loanRequest'] == null ? null : GetLoanRequestDetailLoanRequest.fromJson(json['loanRequest']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetLoanRequestDetailData otherTyped = other as GetLoanRequestDetailData;
    return loanRequest == otherTyped.loanRequest;
    
  }
  @override
  int get hashCode => loanRequest.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (loanRequest != null) {
      json['loanRequest'] = loanRequest!.toJson();
    }
    return json;
  }

  GetLoanRequestDetailData({
    this.loanRequest,
  });
}

@immutable
class GetLoanRequestDetailVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetLoanRequestDetailVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetLoanRequestDetailVariables otherTyped = other as GetLoanRequestDetailVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  GetLoanRequestDetailVariables({
    required this.id,
  });
}

