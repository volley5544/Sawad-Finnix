part of 'default.dart';

class GetActiveLoanVariablesBuilder {
  String userId;

  final FirebaseDataConnect _dataConnect;
  GetActiveLoanVariablesBuilder(this._dataConnect, {required  this.userId,});
  Deserializer<GetActiveLoanData> dataDeserializer = (dynamic json)  => GetActiveLoanData.fromJson(jsonDecode(json));
  Serializer<GetActiveLoanVariables> varsSerializer = (GetActiveLoanVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetActiveLoanData, GetActiveLoanVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetActiveLoanData, GetActiveLoanVariables> ref() {
    GetActiveLoanVariables vars= GetActiveLoanVariables(userId: userId,);
    return _dataConnect.query("GetActiveLoan", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetActiveLoanLoans {
  final String id;
  final double principal;
  final double annualInterestRate;
  final int termMonths;
  final double totalPayable;
  final double installmentAmount;
  final double paidAmount;
  final Timestamp startedAt;
  final String status;
  final Timestamp approvedAt;
  GetActiveLoanLoans.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  principal = nativeFromJson<double>(json['principal']),
  annualInterestRate = nativeFromJson<double>(json['annualInterestRate']),
  termMonths = nativeFromJson<int>(json['termMonths']),
  totalPayable = nativeFromJson<double>(json['totalPayable']),
  installmentAmount = nativeFromJson<double>(json['installmentAmount']),
  paidAmount = nativeFromJson<double>(json['paidAmount']),
  startedAt = Timestamp.fromJson(json['startedAt']),
  status = nativeFromJson<String>(json['status']),
  approvedAt = Timestamp.fromJson(json['approvedAt']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetActiveLoanLoans otherTyped = other as GetActiveLoanLoans;
    return id == otherTyped.id && 
    principal == otherTyped.principal && 
    annualInterestRate == otherTyped.annualInterestRate && 
    termMonths == otherTyped.termMonths && 
    totalPayable == otherTyped.totalPayable && 
    installmentAmount == otherTyped.installmentAmount && 
    paidAmount == otherTyped.paidAmount && 
    startedAt == otherTyped.startedAt && 
    status == otherTyped.status && 
    approvedAt == otherTyped.approvedAt;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, principal.hashCode, annualInterestRate.hashCode, termMonths.hashCode, totalPayable.hashCode, installmentAmount.hashCode, paidAmount.hashCode, startedAt.hashCode, status.hashCode, approvedAt.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['principal'] = nativeToJson<double>(principal);
    json['annualInterestRate'] = nativeToJson<double>(annualInterestRate);
    json['termMonths'] = nativeToJson<int>(termMonths);
    json['totalPayable'] = nativeToJson<double>(totalPayable);
    json['installmentAmount'] = nativeToJson<double>(installmentAmount);
    json['paidAmount'] = nativeToJson<double>(paidAmount);
    json['startedAt'] = startedAt.toJson();
    json['status'] = nativeToJson<String>(status);
    json['approvedAt'] = approvedAt.toJson();
    return json;
  }

  GetActiveLoanLoans({
    required this.id,
    required this.principal,
    required this.annualInterestRate,
    required this.termMonths,
    required this.totalPayable,
    required this.installmentAmount,
    required this.paidAmount,
    required this.startedAt,
    required this.status,
    required this.approvedAt,
  });
}

@immutable
class GetActiveLoanData {
  final List<GetActiveLoanLoans> loans;
  GetActiveLoanData.fromJson(dynamic json):
  
  loans = (json['loans'] as List<dynamic>)
        .map((e) => GetActiveLoanLoans.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetActiveLoanData otherTyped = other as GetActiveLoanData;
    return loans == otherTyped.loans;
    
  }
  @override
  int get hashCode => loans.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['loans'] = loans.map((e) => e.toJson()).toList();
    return json;
  }

  GetActiveLoanData({
    required this.loans,
  });
}

@immutable
class GetActiveLoanVariables {
  final String userId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetActiveLoanVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetActiveLoanVariables otherTyped = other as GetActiveLoanVariables;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  GetActiveLoanVariables({
    required this.userId,
  });
}

