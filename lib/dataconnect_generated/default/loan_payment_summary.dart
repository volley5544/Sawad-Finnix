part of 'default.dart';

class LoanPaymentSummaryVariablesBuilder {
  String loanId;

  final FirebaseDataConnect _dataConnect;
  LoanPaymentSummaryVariablesBuilder(this._dataConnect, {required  this.loanId,});
  Deserializer<LoanPaymentSummaryData> dataDeserializer = (dynamic json)  => LoanPaymentSummaryData.fromJson(jsonDecode(json));
  Serializer<LoanPaymentSummaryVariables> varsSerializer = (LoanPaymentSummaryVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<LoanPaymentSummaryData, LoanPaymentSummaryVariables>> execute() {
    return ref().execute();
  }

  QueryRef<LoanPaymentSummaryData, LoanPaymentSummaryVariables> ref() {
    LoanPaymentSummaryVariables vars= LoanPaymentSummaryVariables(loanId: loanId,);
    return _dataConnect.query("LoanPaymentSummary", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class LoanPaymentSummaryPayments {
  final int count_;
  final double? totalCollected;
  final double? largestPayment;
  LoanPaymentSummaryPayments.fromJson(dynamic json):
  
  count_ = nativeFromJson<int>(json['_count']),
  totalCollected = json['totalCollected'] == null ? null : nativeFromJson<double>(json['totalCollected']),
  largestPayment = json['largestPayment'] == null ? null : nativeFromJson<double>(json['largestPayment']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final LoanPaymentSummaryPayments otherTyped = other as LoanPaymentSummaryPayments;
    return count_ == otherTyped.count_ && 
    totalCollected == otherTyped.totalCollected && 
    largestPayment == otherTyped.largestPayment;
    
  }
  @override
  int get hashCode => Object.hashAll([count_.hashCode, totalCollected.hashCode, largestPayment.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['_count'] = nativeToJson<int>(count_);
    if (totalCollected != null) {
      json['totalCollected'] = nativeToJson<double?>(totalCollected);
    }
    if (largestPayment != null) {
      json['largestPayment'] = nativeToJson<double?>(largestPayment);
    }
    return json;
  }

  LoanPaymentSummaryPayments({
    required this.count_,
    this.totalCollected,
    this.largestPayment,
  });
}

@immutable
class LoanPaymentSummaryData {
  final List<LoanPaymentSummaryPayments> payments;
  LoanPaymentSummaryData.fromJson(dynamic json):
  
  payments = (json['payments'] as List<dynamic>)
        .map((e) => LoanPaymentSummaryPayments.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final LoanPaymentSummaryData otherTyped = other as LoanPaymentSummaryData;
    return payments == otherTyped.payments;
    
  }
  @override
  int get hashCode => payments.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['payments'] = payments.map((e) => e.toJson()).toList();
    return json;
  }

  LoanPaymentSummaryData({
    required this.payments,
  });
}

@immutable
class LoanPaymentSummaryVariables {
  final String loanId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  LoanPaymentSummaryVariables.fromJson(Map<String, dynamic> json):
  
  loanId = nativeFromJson<String>(json['loanId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final LoanPaymentSummaryVariables otherTyped = other as LoanPaymentSummaryVariables;
    return loanId == otherTyped.loanId;
    
  }
  @override
  int get hashCode => loanId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['loanId'] = nativeToJson<String>(loanId);
    return json;
  }

  LoanPaymentSummaryVariables({
    required this.loanId,
  });
}

