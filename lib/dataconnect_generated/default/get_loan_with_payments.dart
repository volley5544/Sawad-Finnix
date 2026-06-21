part of 'default.dart';

class GetLoanWithPaymentsVariablesBuilder {
  String loanId;

  final FirebaseDataConnect _dataConnect;
  GetLoanWithPaymentsVariablesBuilder(this._dataConnect, {required  this.loanId,});
  Deserializer<GetLoanWithPaymentsData> dataDeserializer = (dynamic json)  => GetLoanWithPaymentsData.fromJson(jsonDecode(json));
  Serializer<GetLoanWithPaymentsVariables> varsSerializer = (GetLoanWithPaymentsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetLoanWithPaymentsData, GetLoanWithPaymentsVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetLoanWithPaymentsData, GetLoanWithPaymentsVariables> ref() {
    GetLoanWithPaymentsVariables vars= GetLoanWithPaymentsVariables(loanId: loanId,);
    return _dataConnect.query("GetLoanWithPayments", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetLoanWithPaymentsLoan {
  final String id;
  final double principal;
  final double totalPayable;
  final double installmentAmount;
  final double paidAmount;
  final String status;
  final List<GetLoanWithPaymentsLoanPaymentsOnLoan> payments_on_loan;
  GetLoanWithPaymentsLoan.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  principal = nativeFromJson<double>(json['principal']),
  totalPayable = nativeFromJson<double>(json['totalPayable']),
  installmentAmount = nativeFromJson<double>(json['installmentAmount']),
  paidAmount = nativeFromJson<double>(json['paidAmount']),
  status = nativeFromJson<String>(json['status']),
  payments_on_loan = (json['payments_on_loan'] as List<dynamic>)
        .map((e) => GetLoanWithPaymentsLoanPaymentsOnLoan.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetLoanWithPaymentsLoan otherTyped = other as GetLoanWithPaymentsLoan;
    return id == otherTyped.id && 
    principal == otherTyped.principal && 
    totalPayable == otherTyped.totalPayable && 
    installmentAmount == otherTyped.installmentAmount && 
    paidAmount == otherTyped.paidAmount && 
    status == otherTyped.status && 
    payments_on_loan == otherTyped.payments_on_loan;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, principal.hashCode, totalPayable.hashCode, installmentAmount.hashCode, paidAmount.hashCode, status.hashCode, payments_on_loan.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['principal'] = nativeToJson<double>(principal);
    json['totalPayable'] = nativeToJson<double>(totalPayable);
    json['installmentAmount'] = nativeToJson<double>(installmentAmount);
    json['paidAmount'] = nativeToJson<double>(paidAmount);
    json['status'] = nativeToJson<String>(status);
    json['payments_on_loan'] = payments_on_loan.map((e) => e.toJson()).toList();
    return json;
  }

  GetLoanWithPaymentsLoan({
    required this.id,
    required this.principal,
    required this.totalPayable,
    required this.installmentAmount,
    required this.paidAmount,
    required this.status,
    required this.payments_on_loan,
  });
}

@immutable
class GetLoanWithPaymentsLoanPaymentsOnLoan {
  final double amount;
  final Timestamp paidAt;
  final double outstandingAfter;
  final int installmentsPaid;
  GetLoanWithPaymentsLoanPaymentsOnLoan.fromJson(dynamic json):
  
  amount = nativeFromJson<double>(json['amount']),
  paidAt = Timestamp.fromJson(json['paidAt']),
  outstandingAfter = nativeFromJson<double>(json['outstandingAfter']),
  installmentsPaid = nativeFromJson<int>(json['installmentsPaid']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetLoanWithPaymentsLoanPaymentsOnLoan otherTyped = other as GetLoanWithPaymentsLoanPaymentsOnLoan;
    return amount == otherTyped.amount && 
    paidAt == otherTyped.paidAt && 
    outstandingAfter == otherTyped.outstandingAfter && 
    installmentsPaid == otherTyped.installmentsPaid;
    
  }
  @override
  int get hashCode => Object.hashAll([amount.hashCode, paidAt.hashCode, outstandingAfter.hashCode, installmentsPaid.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['amount'] = nativeToJson<double>(amount);
    json['paidAt'] = paidAt.toJson();
    json['outstandingAfter'] = nativeToJson<double>(outstandingAfter);
    json['installmentsPaid'] = nativeToJson<int>(installmentsPaid);
    return json;
  }

  GetLoanWithPaymentsLoanPaymentsOnLoan({
    required this.amount,
    required this.paidAt,
    required this.outstandingAfter,
    required this.installmentsPaid,
  });
}

@immutable
class GetLoanWithPaymentsData {
  final GetLoanWithPaymentsLoan? loan;
  GetLoanWithPaymentsData.fromJson(dynamic json):
  
  loan = json['loan'] == null ? null : GetLoanWithPaymentsLoan.fromJson(json['loan']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetLoanWithPaymentsData otherTyped = other as GetLoanWithPaymentsData;
    return loan == otherTyped.loan;
    
  }
  @override
  int get hashCode => loan.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (loan != null) {
      json['loan'] = loan!.toJson();
    }
    return json;
  }

  GetLoanWithPaymentsData({
    this.loan,
  });
}

@immutable
class GetLoanWithPaymentsVariables {
  final String loanId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetLoanWithPaymentsVariables.fromJson(Map<String, dynamic> json):
  
  loanId = nativeFromJson<String>(json['loanId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetLoanWithPaymentsVariables otherTyped = other as GetLoanWithPaymentsVariables;
    return loanId == otherTyped.loanId;
    
  }
  @override
  int get hashCode => loanId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['loanId'] = nativeToJson<String>(loanId);
    return json;
  }

  GetLoanWithPaymentsVariables({
    required this.loanId,
  });
}

