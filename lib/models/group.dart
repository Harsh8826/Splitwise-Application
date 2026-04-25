import 'package:flutter_application_4/core/log/log.dart';


class Group {
  final String id;
  final String name;
  final String? description;
  final int members;
  final DateTime creationDate;
  final DateTime updationDate;


  Group({
    required this.id,
    required this.name,
    this.description, 
    required  this.members,
    required this.creationDate,
    required this.updationDate,
  }) ;



  factory Group.fromJson(Map<String, dynamic> json) {
    Logger.logDeveloper("log data created group data $json");
    return Group(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      members: json['member_count'] ?? 0,
      creationDate: DateTime.parse(json['created_at']),
      updationDate: DateTime.parse(json['updated_at']),   
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'members': members,
      'creationDate': creationDate.toIso8601String(),
    };
  }
}
class fetchAllGroups{
  final String id;
  final String name;
  final String? description;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Creator creator;

  fetchAllGroups({
    required this.id,
    required this.name,
    this.description,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.creator
  });
  factory fetchAllGroups.fromJson(Map<String,dynamic> json){
   
        return fetchAllGroups(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']), 
      creator: Creator.fromJson(json['creator']?? {}),  
    );
    
  }
    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'creator': creator.toJson(),
    };
  }
}
class Creator{
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Creator({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });


  factory Creator.fromJson(Map<String,dynamic> json) {
    Logger.logDeveloper('log data created creator data $json');
    return Creator(
     id: json['id']?.toString() ?? '',
     email: json['email'] ?? '',
     name: json['name'].toString(),
     createdAt:DateTime.parse(json['created_at']),
     updatedAt:DateTime.parse(json['updated_at'])
      );
  }
    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }


}
