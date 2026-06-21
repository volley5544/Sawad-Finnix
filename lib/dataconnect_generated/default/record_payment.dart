part of 'default.dart';

class RecordPaymentVariablesBuilder {
  String loanId;
  double amount;
  double outstandingAfter;
  int installmentsPaid;
  double newPaidAmount;
  String status;

  final FirebaseDataConnect _dataConnect;
  RecordPaymentVariablesBuilder(this._dataConnect, {required  this.loanId,required  this.amount,required  this.outstandingAfter,required  this.installmentsPaid,required  this.newPaidAmount,required  this.status,});
  Deserializer<RecordPaymentData> dataDeserializer = (dynamic json)  => RecordPaymentData.fromJson(jsonDecode(json));
  Serializer<RecordPaymentVariables> varsSerializer = (RecordPaymentVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<RecordPaymentData, RecordPaymentVariables>> execute() {
    return ref().execute();
  }

  MutationRef<RecordPaymentData, RecordPaymentVariables> ref() {
    RecordPaymentVariables vars= RecordPaymentVariables(loanId: loanId,amount: amount,outstandingAfter: outstandingAfter,installmentsPaid: installmentsPaid,newPaidAmount: newPaidAmount,status: status,);
    return _dataConnect.mutation("RecordPayment", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class RecordPaymentPaymentInsert {
  final String id;
  RecordPaymentPaymentInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final RecordPaymentPaymentInsert otherTyped = other as RecordPaymentPaymentInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  RecordPaymentPaymentInsert({
    required this.id,
  });
}

@immutable
class RecordPaymentLoanUpdate {
  final String id;
  RecordPaymentLoanUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final RecordPaymentLoanUpdate otherTyped = other as RecordPaymentLoanUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  RecordPaymentLoanUpdate({
    required this.id,
  });
}

@immutable
class RecordPaymentData {
  final RecordPaymentPaymentInsert payment_insert;
  final RecordPaymentLoanUpdate? loan_update;
  RecordPaymentData.fromJson(dynamic json):
  
  payment_insert = RecordPaymentPaymentInsert.fromJson(json['payment_insert']),
  loan_update = json['loan_update'] == null ? null : RecordPaymentLoanUpdate.fromJson(json['loan_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final RecordPaymentData otherTyped = other as RecordPaymentData;
    return payment_insert == otherTyped.payment_insert && 
    loan_update == otherTyped.loan_update;
    
  }
  @override
  int get hashCode => Object.hashAll([payment_insert.hashCode, loan_update.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['payment_insert'] = payment_insert.toJson();
    if (loan_update != null) {
      json['loan_update'] = loan_update!.toJson();
    }
    return json;
  }

  RecordPaymentData({
    required this.payment_insert,
    this.loan_update,
  });
}

@immutable
class RecordPaymentVariables {
  final String loanId;
  final double amount;
  final double outstandingAfter;
  final int installmentsPaid;
  final double newPaidAmount;
  final String status;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  RecordPaymentVariables.fromJson(Map<String, dynamic> json):
  
  loanId = nativeFromJson<String>(json['loanId']),
  amount = nativeFromJson<double>(json['amount']),
  outstandingAfter = nativeFromJson<double>(json['outstandingAfter']),
  installmentsPaid = nativeFromJson<int>(json['installmentsPaid']),
  newPaidAmount = nativeFromJson<double>(json['newPaidAmount']),
  status = nativeFromJson<String>(json['status']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final RecordPaymentVariables otherTyped = other as RecordPaymentVariables;
    return loanId == otherTyped.loanId && 
    amount == otherTyped.amount && 
    outstandingAfter == otherTyped.outstandingAfter && 
    installmentsPaid == otherTyped.installmentsPaid && 
    newPaidAmount == otherTyped.newPaidAmount && 
    status == otherTyped.status;
    
  }
  @override
  int get hashCode => Object.hashAll([loanId.hashCode, amount.hashCode, outstandingAfter.hashCode, installmentsPaid.hashCode, newPaidAmount.hashCode, status.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['loanId'] = nativeToJson<String>(loanId);
    json['amount'] = nativeToJson<double>(amount);
    json['outstandingAfter'] = nativeToJson<double>(outstandingAfter);
    json['installmentsPaid'] = nativeToJson<int>(installmentsPaid);
    json['newPaidAmount'] = nativeToJson<double>(newPaidAmount);
    json['status'] = nativeToJson<String>(status);
    return json;
  }

  RecordPaymentVariables({
    required this.loanId,
    required this.amount,
    required this.outstandingAfter,
    required this.installmentsPaid,
    required this.newPaidAmount,
    required this.status,
  });
}

