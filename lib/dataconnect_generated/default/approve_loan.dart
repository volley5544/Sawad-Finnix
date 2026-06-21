part of 'default.dart';

class ApproveLoanVariablesBuilder {
  String id;
  String userId;
  Optional<String> _thaiId = Optional.optional(nativeFromJson, nativeToJson);
  double principal;
  double annualInterestRate;
  int termMonths;
  double totalPayable;
  double installmentAmount;
  Timestamp startedAt;

  final FirebaseDataConnect _dataConnect;  ApproveLoanVariablesBuilder thaiId(String? t) {
   _thaiId.value = t;
   return this;
  }

  ApproveLoanVariablesBuilder(this._dataConnect, {required  this.id,required  this.userId,required  this.principal,required  this.annualInterestRate,required  this.termMonths,required  this.totalPayable,required  this.installmentAmount,required  this.startedAt,});
  Deserializer<ApproveLoanData> dataDeserializer = (dynamic json)  => ApproveLoanData.fromJson(jsonDecode(json));
  Serializer<ApproveLoanVariables> varsSerializer = (ApproveLoanVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<ApproveLoanData, ApproveLoanVariables>> execute() {
    return ref().execute();
  }

  MutationRef<ApproveLoanData, ApproveLoanVariables> ref() {
    ApproveLoanVariables vars= ApproveLoanVariables(id: id,userId: userId,thaiId: _thaiId,principal: principal,annualInterestRate: annualInterestRate,termMonths: termMonths,totalPayable: totalPayable,installmentAmount: installmentAmount,startedAt: startedAt,);
    return _dataConnect.mutation("ApproveLoan", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ApproveLoanLoanInsert {
  final String id;
  ApproveLoanLoanInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ApproveLoanLoanInsert otherTyped = other as ApproveLoanLoanInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  ApproveLoanLoanInsert({
    required this.id,
  });
}

@immutable
class ApproveLoanData {
  final ApproveLoanLoanInsert loan_insert;
  ApproveLoanData.fromJson(dynamic json):
  
  loan_insert = ApproveLoanLoanInsert.fromJson(json['loan_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ApproveLoanData otherTyped = other as ApproveLoanData;
    return loan_insert == otherTyped.loan_insert;
    
  }
  @override
  int get hashCode => loan_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['loan_insert'] = loan_insert.toJson();
    return json;
  }

  ApproveLoanData({
    required this.loan_insert,
  });
}

@immutable
class ApproveLoanVariables {
  final String id;
  final String userId;
  late final Optional<String>thaiId;
  final double principal;
  final double annualInterestRate;
  final int termMonths;
  final double totalPayable;
  final double installmentAmount;
  final Timestamp startedAt;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ApproveLoanVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  userId = nativeFromJson<String>(json['userId']),
  principal = nativeFromJson<double>(json['principal']),
  annualInterestRate = nativeFromJson<double>(json['annualInterestRate']),
  termMonths = nativeFromJson<int>(json['termMonths']),
  totalPayable = nativeFromJson<double>(json['totalPayable']),
  installmentAmount = nativeFromJson<double>(json['installmentAmount']),
  startedAt = Timestamp.fromJson(json['startedAt']) {
  
  
  
  
    thaiId = Optional.optional(nativeFromJson, nativeToJson);
    thaiId.value = json['thaiId'] == null ? null : nativeFromJson<String>(json['thaiId']);
  
  
  
  
  
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ApproveLoanVariables otherTyped = other as ApproveLoanVariables;
    return id == otherTyped.id && 
    userId == otherTyped.userId && 
    thaiId == otherTyped.thaiId && 
    principal == otherTyped.principal && 
    annualInterestRate == otherTyped.annualInterestRate && 
    termMonths == otherTyped.termMonths && 
    totalPayable == otherTyped.totalPayable && 
    installmentAmount == otherTyped.installmentAmount && 
    startedAt == otherTyped.startedAt;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, userId.hashCode, thaiId.hashCode, principal.hashCode, annualInterestRate.hashCode, termMonths.hashCode, totalPayable.hashCode, installmentAmount.hashCode, startedAt.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['userId'] = nativeToJson<String>(userId);
    if(thaiId.state == OptionalState.set) {
      json['thaiId'] = thaiId.toJson();
    }
    json['principal'] = nativeToJson<double>(principal);
    json['annualInterestRate'] = nativeToJson<double>(annualInterestRate);
    json['termMonths'] = nativeToJson<int>(termMonths);
    json['totalPayable'] = nativeToJson<double>(totalPayable);
    json['installmentAmount'] = nativeToJson<double>(installmentAmount);
    json['startedAt'] = startedAt.toJson();
    return json;
  }

  ApproveLoanVariables({
    required this.id,
    required this.userId,
    required this.thaiId,
    required this.principal,
    required this.annualInterestRate,
    required this.termMonths,
    required this.totalPayable,
    required this.installmentAmount,
    required this.startedAt,
  });
}

