part of 'default.dart';

class AddStatementFileVariablesBuilder {
  String requestId;
  String name;
  String path;
  String url;
  int size;
  Optional<String> _contentType = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  AddStatementFileVariablesBuilder contentType(String? t) {
   _contentType.value = t;
   return this;
  }

  AddStatementFileVariablesBuilder(this._dataConnect, {required  this.requestId,required  this.name,required  this.path,required  this.url,required  this.size,});
  Deserializer<AddStatementFileData> dataDeserializer = (dynamic json)  => AddStatementFileData.fromJson(jsonDecode(json));
  Serializer<AddStatementFileVariables> varsSerializer = (AddStatementFileVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddStatementFileData, AddStatementFileVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AddStatementFileData, AddStatementFileVariables> ref() {
    AddStatementFileVariables vars= AddStatementFileVariables(requestId: requestId,name: name,path: path,url: url,size: size,contentType: _contentType,);
    return _dataConnect.mutation("AddStatementFile", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AddStatementFileStatementFileInsert {
  final String id;
  AddStatementFileStatementFileInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddStatementFileStatementFileInsert otherTyped = other as AddStatementFileStatementFileInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AddStatementFileStatementFileInsert({
    required this.id,
  });
}

@immutable
class AddStatementFileData {
  final AddStatementFileStatementFileInsert statementFile_insert;
  AddStatementFileData.fromJson(dynamic json):
  
  statementFile_insert = AddStatementFileStatementFileInsert.fromJson(json['statementFile_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddStatementFileData otherTyped = other as AddStatementFileData;
    return statementFile_insert == otherTyped.statementFile_insert;
    
  }
  @override
  int get hashCode => statementFile_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['statementFile_insert'] = statementFile_insert.toJson();
    return json;
  }

  AddStatementFileData({
    required this.statementFile_insert,
  });
}

@immutable
class AddStatementFileVariables {
  final String requestId;
  final String name;
  final String path;
  final String url;
  final int size;
  late final Optional<String>contentType;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddStatementFileVariables.fromJson(Map<String, dynamic> json):
  
  requestId = nativeFromJson<String>(json['requestId']),
  name = nativeFromJson<String>(json['name']),
  path = nativeFromJson<String>(json['path']),
  url = nativeFromJson<String>(json['url']),
  size = nativeFromJson<int>(json['size']) {
  
  
  
  
  
  
  
    contentType = Optional.optional(nativeFromJson, nativeToJson);
    contentType.value = json['contentType'] == null ? null : nativeFromJson<String>(json['contentType']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddStatementFileVariables otherTyped = other as AddStatementFileVariables;
    return requestId == otherTyped.requestId && 
    name == otherTyped.name && 
    path == otherTyped.path && 
    url == otherTyped.url && 
    size == otherTyped.size && 
    contentType == otherTyped.contentType;
    
  }
  @override
  int get hashCode => Object.hashAll([requestId.hashCode, name.hashCode, path.hashCode, url.hashCode, size.hashCode, contentType.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['requestId'] = nativeToJson<String>(requestId);
    json['name'] = nativeToJson<String>(name);
    json['path'] = nativeToJson<String>(path);
    json['url'] = nativeToJson<String>(url);
    json['size'] = nativeToJson<int>(size);
    if(contentType.state == OptionalState.set) {
      json['contentType'] = contentType.toJson();
    }
    return json;
  }

  AddStatementFileVariables({
    required this.requestId,
    required this.name,
    required this.path,
    required this.url,
    required this.size,
    required this.contentType,
  });
}

