part of 'default.dart';

class ListLoanRequestsVariablesBuilder {
  String userId;

  final FirebaseDataConnect _dataConnect;
  ListLoanRequestsVariablesBuilder(this._dataConnect, {required  this.userId,});
  Deserializer<ListLoanRequestsData> dataDeserializer = (dynamic json)  => ListLoanRequestsData.fromJson(jsonDecode(json));
  Serializer<ListLoanRequestsVariables> varsSerializer = (ListLoanRequestsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListLoanRequestsData, ListLoanRequestsVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListLoanRequestsData, ListLoanRequestsVariables> ref() {
    ListLoanRequestsVariables vars= ListLoanRequestsVariables(userId: userId,);
    return _dataConnect.query("ListLoanRequests", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListLoanRequestsLoanRequests {
  final String id;
  final String status;
  final String nameTh;
  final String email;
  final String payrollBank;
  final Timestamp createdAt;
  ListLoanRequestsLoanRequests.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  status = nativeFromJson<String>(json['status']),
  nameTh = nativeFromJson<String>(json['nameTh']),
  email = nativeFromJson<String>(json['email']),
  payrollBank = nativeFromJson<String>(json['payrollBank']),
  createdAt = Timestamp.fromJson(json['createdAt']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListLoanRequestsLoanRequests otherTyped = other as ListLoanRequestsLoanRequests;
    return id == otherTyped.id && 
    status == otherTyped.status && 
    nameTh == otherTyped.nameTh && 
    email == otherTyped.email && 
    payrollBank == otherTyped.payrollBank && 
    createdAt == otherTyped.createdAt;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, status.hashCode, nameTh.hashCode, email.hashCode, payrollBank.hashCode, createdAt.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['status'] = nativeToJson<String>(status);
    json['nameTh'] = nativeToJson<String>(nameTh);
    json['email'] = nativeToJson<String>(email);
    json['payrollBank'] = nativeToJson<String>(payrollBank);
    json['createdAt'] = createdAt.toJson();
    return json;
  }

  ListLoanRequestsLoanRequests({
    required this.id,
    required this.status,
    required this.nameTh,
    required this.email,
    required this.payrollBank,
    required this.createdAt,
  });
}

@immutable
class ListLoanRequestsData {
  final List<ListLoanRequestsLoanRequests> loanRequests;
  ListLoanRequestsData.fromJson(dynamic json):
  
  loanRequests = (json['loanRequests'] as List<dynamic>)
        .map((e) => ListLoanRequestsLoanRequests.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListLoanRequestsData otherTyped = other as ListLoanRequestsData;
    return loanRequests == otherTyped.loanRequests;
    
  }
  @override
  int get hashCode => loanRequests.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['loanRequests'] = loanRequests.map((e) => e.toJson()).toList();
    return json;
  }

  ListLoanRequestsData({
    required this.loanRequests,
  });
}

@immutable
class ListLoanRequestsVariables {
  final String userId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListLoanRequestsVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListLoanRequestsVariables otherTyped = other as ListLoanRequestsVariables;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  ListLoanRequestsVariables({
    required this.userId,
  });
}

