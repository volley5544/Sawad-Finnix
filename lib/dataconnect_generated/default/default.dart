library default_connector;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'upsert_user.dart';

part 'create_loan_request.dart';

part 'add_loan_contact.dart';

part 'add_statement_file.dart';

part 'approve_loan.dart';

part 'record_payment.dart';

part 'get_user.dart';

part 'list_loan_requests.dart';

part 'get_loan_request_detail.dart';

part 'get_active_loan.dart';

part 'get_loan_with_payments.dart';

part 'loan_payment_summary.dart';







class DefaultConnector {
  
  
  UpsertUserVariablesBuilder upsertUser ({required String id, required String uid, }) {
    return UpsertUserVariablesBuilder(dataConnect, id: id,uid: uid,);
  }
  
  
  CreateLoanRequestVariablesBuilder createLoanRequest ({required String userId, required String nameTh, required String idCardAddress, required bool contactsGranted, required bool deviceInfoGranted, required bool locationGranted, required bool smsGranted, required String currentAddress, required String area, required String postcode, required bool sameAsIdCard, required String email, required String education, required String payrollBank, required bool includeOtherBanks, required bool agreeTerms, required bool marketingConsent, required bool creditModelConsent, required bool productConsent, }) {
    return CreateLoanRequestVariablesBuilder(dataConnect, userId: userId,nameTh: nameTh,idCardAddress: idCardAddress,contactsGranted: contactsGranted,deviceInfoGranted: deviceInfoGranted,locationGranted: locationGranted,smsGranted: smsGranted,currentAddress: currentAddress,area: area,postcode: postcode,sameAsIdCard: sameAsIdCard,email: email,education: education,payrollBank: payrollBank,includeOtherBanks: includeOtherBanks,agreeTerms: agreeTerms,marketingConsent: marketingConsent,creditModelConsent: creditModelConsent,productConsent: productConsent,);
  }
  
  
  AddLoanContactVariablesBuilder addLoanContact ({required String requestId, required String relation, required String firstName, required String lastName, required String phone, }) {
    return AddLoanContactVariablesBuilder(dataConnect, requestId: requestId,relation: relation,firstName: firstName,lastName: lastName,phone: phone,);
  }
  
  
  AddStatementFileVariablesBuilder addStatementFile ({required String requestId, required String name, required String path, required String url, required int size, }) {
    return AddStatementFileVariablesBuilder(dataConnect, requestId: requestId,name: name,path: path,url: url,size: size,);
  }
  
  
  ApproveLoanVariablesBuilder approveLoan ({required String id, required String userId, required double principal, required double annualInterestRate, required int termMonths, required double totalPayable, required double installmentAmount, required Timestamp startedAt, }) {
    return ApproveLoanVariablesBuilder(dataConnect, id: id,userId: userId,principal: principal,annualInterestRate: annualInterestRate,termMonths: termMonths,totalPayable: totalPayable,installmentAmount: installmentAmount,startedAt: startedAt,);
  }
  
  
  RecordPaymentVariablesBuilder recordPayment ({required String loanId, required double amount, required double outstandingAfter, required int installmentsPaid, required double newPaidAmount, required String status, }) {
    return RecordPaymentVariablesBuilder(dataConnect, loanId: loanId,amount: amount,outstandingAfter: outstandingAfter,installmentsPaid: installmentsPaid,newPaidAmount: newPaidAmount,status: status,);
  }
  
  
  GetUserVariablesBuilder getUser ({required String id, }) {
    return GetUserVariablesBuilder(dataConnect, id: id,);
  }
  
  
  ListLoanRequestsVariablesBuilder listLoanRequests ({required String userId, }) {
    return ListLoanRequestsVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  GetLoanRequestDetailVariablesBuilder getLoanRequestDetail ({required String id, }) {
    return GetLoanRequestDetailVariablesBuilder(dataConnect, id: id,);
  }
  
  
  GetActiveLoanVariablesBuilder getActiveLoan ({required String userId, }) {
    return GetActiveLoanVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  GetLoanWithPaymentsVariablesBuilder getLoanWithPayments ({required String loanId, }) {
    return GetLoanWithPaymentsVariablesBuilder(dataConnect, loanId: loanId,);
  }
  
  
  LoanPaymentSummaryVariablesBuilder loanPaymentSummary ({required String loanId, }) {
    return LoanPaymentSummaryVariablesBuilder(dataConnect, loanId: loanId,);
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'asia-southeast1',
    'default',
    'sawad-finnix-uat-service',
  );

  DefaultConnector({required this.dataConnect});
  static DefaultConnector get instance {
    return DefaultConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
