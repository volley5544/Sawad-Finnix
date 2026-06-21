# default_connector SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
DefaultConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### GetUser
#### Required Arguments
```dart
String id = ...;
DefaultConnector.instance.getUser(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetUserData, GetUserVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await DefaultConnector.instance.getUser(
  id: id,
);
GetUserData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = DefaultConnector.instance.getUser(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListLoanRequests
#### Required Arguments
```dart
String userId = ...;
DefaultConnector.instance.listLoanRequests(
  userId: userId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListLoanRequestsData, ListLoanRequestsVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await DefaultConnector.instance.listLoanRequests(
  userId: userId,
);
ListLoanRequestsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;

final ref = DefaultConnector.instance.listLoanRequests(
  userId: userId,
).ref();
ref.execute();

ref.subscribe(...);
```


### GetLoanRequestDetail
#### Required Arguments
```dart
String id = ...;
DefaultConnector.instance.getLoanRequestDetail(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetLoanRequestDetailData, GetLoanRequestDetailVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await DefaultConnector.instance.getLoanRequestDetail(
  id: id,
);
GetLoanRequestDetailData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = DefaultConnector.instance.getLoanRequestDetail(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```


### GetActiveLoan
#### Required Arguments
```dart
String userId = ...;
DefaultConnector.instance.getActiveLoan(
  userId: userId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetActiveLoanData, GetActiveLoanVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await DefaultConnector.instance.getActiveLoan(
  userId: userId,
);
GetActiveLoanData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;

final ref = DefaultConnector.instance.getActiveLoan(
  userId: userId,
).ref();
ref.execute();

ref.subscribe(...);
```


### GetLoanWithPayments
#### Required Arguments
```dart
String loanId = ...;
DefaultConnector.instance.getLoanWithPayments(
  loanId: loanId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetLoanWithPaymentsData, GetLoanWithPaymentsVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await DefaultConnector.instance.getLoanWithPayments(
  loanId: loanId,
);
GetLoanWithPaymentsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String loanId = ...;

final ref = DefaultConnector.instance.getLoanWithPayments(
  loanId: loanId,
).ref();
ref.execute();

ref.subscribe(...);
```


### LoanPaymentSummary
#### Required Arguments
```dart
String loanId = ...;
DefaultConnector.instance.loanPaymentSummary(
  loanId: loanId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<LoanPaymentSummaryData, LoanPaymentSummaryVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await DefaultConnector.instance.loanPaymentSummary(
  loanId: loanId,
);
LoanPaymentSummaryData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String loanId = ...;

final ref = DefaultConnector.instance.loanPaymentSummary(
  loanId: loanId,
).ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### UpsertUser
#### Required Arguments
```dart
String id = ...;
String uid = ...;
DefaultConnector.instance.upsertUser(
  id: id,
  uid: uid,
).execute();
```

#### Optional Arguments
We return a builder for each query. For UpsertUser, we created `UpsertUserBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class UpsertUserVariablesBuilder {
  ...
   UpsertUserVariablesBuilder phoneNumber(String? t) {
   _phoneNumber.value = t;
   return this;
  }
  UpsertUserVariablesBuilder thaiId(String? t) {
   _thaiId.value = t;
   return this;
  }
  UpsertUserVariablesBuilder nameTh(String? t) {
   _nameTh.value = t;
   return this;
  }
  UpsertUserVariablesBuilder nameEn(String? t) {
   _nameEn.value = t;
   return this;
  }
  UpsertUserVariablesBuilder gender(String? t) {
   _gender.value = t;
   return this;
  }
  UpsertUserVariablesBuilder address(String? t) {
   _address.value = t;
   return this;
  }
  UpsertUserVariablesBuilder houseAddress(String? t) {
   _houseAddress.value = t;
   return this;
  }
  UpsertUserVariablesBuilder dateOfBirth(DateTime? t) {
   _dateOfBirth.value = t;
   return this;
  }
  UpsertUserVariablesBuilder tokenIssuedAt(int? t) {
   _tokenIssuedAt.value = t;
   return this;
  }
  UpsertUserVariablesBuilder tokenExpiresAt(int? t) {
   _tokenExpiresAt.value = t;
   return this;
  }
  UpsertUserVariablesBuilder authTime(int? t) {
   _authTime.value = t;
   return this;
  }

  ...
}
DefaultConnector.instance.upsertUser(
  id: id,
  uid: uid,
)
.phoneNumber(phoneNumber)
.thaiId(thaiId)
.nameTh(nameTh)
.nameEn(nameEn)
.gender(gender)
.address(address)
.houseAddress(houseAddress)
.dateOfBirth(dateOfBirth)
.tokenIssuedAt(tokenIssuedAt)
.tokenExpiresAt(tokenExpiresAt)
.authTime(authTime)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<UpsertUserData, UpsertUserVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.upsertUser(
  id: id,
  uid: uid,
);
UpsertUserData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String uid = ...;

final ref = DefaultConnector.instance.upsertUser(
  id: id,
  uid: uid,
).ref();
ref.execute();
```


### CreateLoanRequest
#### Required Arguments
```dart
String userId = ...;
String nameTh = ...;
String idCardAddress = ...;
bool contactsGranted = ...;
bool deviceInfoGranted = ...;
bool locationGranted = ...;
bool smsGranted = ...;
String currentAddress = ...;
String area = ...;
String postcode = ...;
bool sameAsIdCard = ...;
String email = ...;
String education = ...;
String payrollBank = ...;
bool includeOtherBanks = ...;
bool agreeTerms = ...;
bool marketingConsent = ...;
bool creditModelConsent = ...;
bool productConsent = ...;
DefaultConnector.instance.createLoanRequest(
  userId: userId,
  nameTh: nameTh,
  idCardAddress: idCardAddress,
  contactsGranted: contactsGranted,
  deviceInfoGranted: deviceInfoGranted,
  locationGranted: locationGranted,
  smsGranted: smsGranted,
  currentAddress: currentAddress,
  area: area,
  postcode: postcode,
  sameAsIdCard: sameAsIdCard,
  email: email,
  education: education,
  payrollBank: payrollBank,
  includeOtherBanks: includeOtherBanks,
  agreeTerms: agreeTerms,
  marketingConsent: marketingConsent,
  creditModelConsent: creditModelConsent,
  productConsent: productConsent,
).execute();
```

#### Optional Arguments
We return a builder for each query. For CreateLoanRequest, we created `CreateLoanRequestBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CreateLoanRequestVariablesBuilder {
  ...
   CreateLoanRequestVariablesBuilder thaiId(String? t) {
   _thaiId.value = t;
   return this;
  }
  CreateLoanRequestVariablesBuilder dateOfBirth(DateTime? t) {
   _dateOfBirth.value = t;
   return this;
  }

  ...
}
DefaultConnector.instance.createLoanRequest(
  userId: userId,
  nameTh: nameTh,
  idCardAddress: idCardAddress,
  contactsGranted: contactsGranted,
  deviceInfoGranted: deviceInfoGranted,
  locationGranted: locationGranted,
  smsGranted: smsGranted,
  currentAddress: currentAddress,
  area: area,
  postcode: postcode,
  sameAsIdCard: sameAsIdCard,
  email: email,
  education: education,
  payrollBank: payrollBank,
  includeOtherBanks: includeOtherBanks,
  agreeTerms: agreeTerms,
  marketingConsent: marketingConsent,
  creditModelConsent: creditModelConsent,
  productConsent: productConsent,
)
.thaiId(thaiId)
.dateOfBirth(dateOfBirth)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<CreateLoanRequestData, CreateLoanRequestVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.createLoanRequest(
  userId: userId,
  nameTh: nameTh,
  idCardAddress: idCardAddress,
  contactsGranted: contactsGranted,
  deviceInfoGranted: deviceInfoGranted,
  locationGranted: locationGranted,
  smsGranted: smsGranted,
  currentAddress: currentAddress,
  area: area,
  postcode: postcode,
  sameAsIdCard: sameAsIdCard,
  email: email,
  education: education,
  payrollBank: payrollBank,
  includeOtherBanks: includeOtherBanks,
  agreeTerms: agreeTerms,
  marketingConsent: marketingConsent,
  creditModelConsent: creditModelConsent,
  productConsent: productConsent,
);
CreateLoanRequestData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;
String nameTh = ...;
String idCardAddress = ...;
bool contactsGranted = ...;
bool deviceInfoGranted = ...;
bool locationGranted = ...;
bool smsGranted = ...;
String currentAddress = ...;
String area = ...;
String postcode = ...;
bool sameAsIdCard = ...;
String email = ...;
String education = ...;
String payrollBank = ...;
bool includeOtherBanks = ...;
bool agreeTerms = ...;
bool marketingConsent = ...;
bool creditModelConsent = ...;
bool productConsent = ...;

final ref = DefaultConnector.instance.createLoanRequest(
  userId: userId,
  nameTh: nameTh,
  idCardAddress: idCardAddress,
  contactsGranted: contactsGranted,
  deviceInfoGranted: deviceInfoGranted,
  locationGranted: locationGranted,
  smsGranted: smsGranted,
  currentAddress: currentAddress,
  area: area,
  postcode: postcode,
  sameAsIdCard: sameAsIdCard,
  email: email,
  education: education,
  payrollBank: payrollBank,
  includeOtherBanks: includeOtherBanks,
  agreeTerms: agreeTerms,
  marketingConsent: marketingConsent,
  creditModelConsent: creditModelConsent,
  productConsent: productConsent,
).ref();
ref.execute();
```


### AddLoanContact
#### Required Arguments
```dart
String requestId = ...;
String relation = ...;
String firstName = ...;
String lastName = ...;
String phone = ...;
DefaultConnector.instance.addLoanContact(
  requestId: requestId,
  relation: relation,
  firstName: firstName,
  lastName: lastName,
  phone: phone,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<AddLoanContactData, AddLoanContactVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.addLoanContact(
  requestId: requestId,
  relation: relation,
  firstName: firstName,
  lastName: lastName,
  phone: phone,
);
AddLoanContactData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String requestId = ...;
String relation = ...;
String firstName = ...;
String lastName = ...;
String phone = ...;

final ref = DefaultConnector.instance.addLoanContact(
  requestId: requestId,
  relation: relation,
  firstName: firstName,
  lastName: lastName,
  phone: phone,
).ref();
ref.execute();
```


### AddStatementFile
#### Required Arguments
```dart
String requestId = ...;
String name = ...;
String path = ...;
String url = ...;
int size = ...;
DefaultConnector.instance.addStatementFile(
  requestId: requestId,
  name: name,
  path: path,
  url: url,
  size: size,
).execute();
```

#### Optional Arguments
We return a builder for each query. For AddStatementFile, we created `AddStatementFileBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class AddStatementFileVariablesBuilder {
  ...
   AddStatementFileVariablesBuilder contentType(String? t) {
   _contentType.value = t;
   return this;
  }

  ...
}
DefaultConnector.instance.addStatementFile(
  requestId: requestId,
  name: name,
  path: path,
  url: url,
  size: size,
)
.contentType(contentType)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<AddStatementFileData, AddStatementFileVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.addStatementFile(
  requestId: requestId,
  name: name,
  path: path,
  url: url,
  size: size,
);
AddStatementFileData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String requestId = ...;
String name = ...;
String path = ...;
String url = ...;
int size = ...;

final ref = DefaultConnector.instance.addStatementFile(
  requestId: requestId,
  name: name,
  path: path,
  url: url,
  size: size,
).ref();
ref.execute();
```


### ApproveLoan
#### Required Arguments
```dart
String id = ...;
String userId = ...;
double principal = ...;
double annualInterestRate = ...;
int termMonths = ...;
double totalPayable = ...;
double installmentAmount = ...;
Timestamp startedAt = ...;
DefaultConnector.instance.approveLoan(
  id: id,
  userId: userId,
  principal: principal,
  annualInterestRate: annualInterestRate,
  termMonths: termMonths,
  totalPayable: totalPayable,
  installmentAmount: installmentAmount,
  startedAt: startedAt,
).execute();
```

#### Optional Arguments
We return a builder for each query. For ApproveLoan, we created `ApproveLoanBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class ApproveLoanVariablesBuilder {
  ...
   ApproveLoanVariablesBuilder thaiId(String? t) {
   _thaiId.value = t;
   return this;
  }

  ...
}
DefaultConnector.instance.approveLoan(
  id: id,
  userId: userId,
  principal: principal,
  annualInterestRate: annualInterestRate,
  termMonths: termMonths,
  totalPayable: totalPayable,
  installmentAmount: installmentAmount,
  startedAt: startedAt,
)
.thaiId(thaiId)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<ApproveLoanData, ApproveLoanVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.approveLoan(
  id: id,
  userId: userId,
  principal: principal,
  annualInterestRate: annualInterestRate,
  termMonths: termMonths,
  totalPayable: totalPayable,
  installmentAmount: installmentAmount,
  startedAt: startedAt,
);
ApproveLoanData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String userId = ...;
double principal = ...;
double annualInterestRate = ...;
int termMonths = ...;
double totalPayable = ...;
double installmentAmount = ...;
Timestamp startedAt = ...;

final ref = DefaultConnector.instance.approveLoan(
  id: id,
  userId: userId,
  principal: principal,
  annualInterestRate: annualInterestRate,
  termMonths: termMonths,
  totalPayable: totalPayable,
  installmentAmount: installmentAmount,
  startedAt: startedAt,
).ref();
ref.execute();
```


### RecordPayment
#### Required Arguments
```dart
String loanId = ...;
double amount = ...;
double outstandingAfter = ...;
int installmentsPaid = ...;
double newPaidAmount = ...;
String status = ...;
DefaultConnector.instance.recordPayment(
  loanId: loanId,
  amount: amount,
  outstandingAfter: outstandingAfter,
  installmentsPaid: installmentsPaid,
  newPaidAmount: newPaidAmount,
  status: status,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<RecordPaymentData, RecordPaymentVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.recordPayment(
  loanId: loanId,
  amount: amount,
  outstandingAfter: outstandingAfter,
  installmentsPaid: installmentsPaid,
  newPaidAmount: newPaidAmount,
  status: status,
);
RecordPaymentData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String loanId = ...;
double amount = ...;
double outstandingAfter = ...;
int installmentsPaid = ...;
double newPaidAmount = ...;
String status = ...;

final ref = DefaultConnector.instance.recordPayment(
  loanId: loanId,
  amount: amount,
  outstandingAfter: outstandingAfter,
  installmentsPaid: installmentsPaid,
  newPaidAmount: newPaidAmount,
  status: status,
).ref();
ref.execute();
```

