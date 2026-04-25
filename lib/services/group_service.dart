import 'dart:convert';

import 'package:flutter_application_4/models/expense.dart';

import 'auth_service.dart';
import 'package:flutter_application_4/core/log/log.dart';
import 'package:dio/dio.dart';
import '../models/group.dart';
import '../models/user.dart';
class GroupService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/v1'; // Emulator host
  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  final AuthService _authService = AuthService();

  Future<Group?> createGroup(String name, String description) async {
    final payload = {
      "name": name,
      "description": description,
    };

    try {
      final token = await _authService.getToken();
      Logger.logDeveloper('Creating group with payload: $payload');
      Logger.logDeveloper('Auth token: $token');
      final response = await _dio.post(
        '/groups/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
         data:payload,
      );

      Logger.logDeveloper('Create Group Response (${response.statusCode}): ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          Logger.logDeveloper("RESPONSE WHILE CREATING GROUP ${response.data['group']}");
          
          return Group.fromJson(response.data['group']);
        } else {
          Logger.logDeveloper(
              'Unexpected response format: ${response.data.runtimeType}');
          return null;
        }
      } else {
        Logger.logDeveloper(
          'Failed to create group. Status code: ${response.statusCode}, Response: ${response.data}',
        );
        return null;
      }
    } catch (e, stack) {
      Logger.logDeveloper('Error in creating group: $e\n$stack');
      return null;
    }
  }


  /// Get only the groups that the authenticated user is part of
Future<List<fetchAllGroups>> getUserGroups() async {
  try {
    final token = await _authService.getToken();
    final response = await _dio.get(
      '/users/groups',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    Logger.logDeveloper(
      'Get User Groups Response (${response.statusCode}): ${response.data}'
    );

    if (response.statusCode == 200) {
      if (response.data is Map<String, dynamic>) {
        // If response is { "groups": [ ... ] }
        final List<dynamic> groupList = response.data['groups'] ?? [];
        return groupList.map((groupJson) => fetchAllGroups.fromJson(groupJson)).toList();
      } else if (response.data is List) {
        // If API returns a raw array
        return response.data.map<Group>((json) => fetchAllGroups.fromJson(json)).toList();
      }
    }

    Logger.logDeveloper(
      'Failed to fetch user groups. Status code: ${response.statusCode}'
    );
    return [];
  } catch (e, stack) {
    Logger.logDeveloper('Error fetching user groups: $e\n$stack');
    return [];
  }
}



  Future<Group?> getGroupById(String groupid) async{
    Logger.logDeveloper('Group id for the respected group is $groupid');
    try{
      final token = await _authService.getToken();
      Logger.logDeveloper('Fetching group details for $groupid with token $token');
      final response = await _dio.get(
        '/groups/$groupid',
        options:Options(
          headers:{
            'Authorization':'Bearer $token',
            'Content-type':'appication/json',
          },
        ),
      );
      // Logger.logDeveloper('Get group details response (${response.statusCode}): Response:${response.data}');
      if(response.statusCode == 200){
        if(response.data is Map<String,dynamic>){
          if(response.data.containsKey('group')){
            // Logger.logDeveloper('Response while fetching details ${response.data['group']}');
            return Group.fromJson(response.data['group']);
          }else{
            return Group.fromJson(response.data);
          }
        }
      }else{
        Logger.logDeveloper('Failed to fetch group details. Status code: ${response.statusCode}, Response: ${response.data}');
            return null;
      }
  

    }catch(e,stack){
      Logger.logDeveloper('Error in fetching group : $e\n$stack');
    }
  }

  Future<bool> updateGroup({
     required String groupId,
     required String name,
     required String description,
  })async{
    try{
      final token = await _authService.getToken();
      Logger.logDeveloper('Token while Updating $token and group id is $groupId ');
      
      final response = await _dio.put('/groups/$groupId',
    
      data:{
        'name':name,
        'description':description
      },
      options: Options(
        headers:{
          'Authorization':'Bearer $token',
          'Content-Type':'application/json'
        }
      )
      );
      Logger.logDeveloper('Updated response is ${response.data}');
      return response.statusCode == 200;
    }
    catch(e){
      Logger.logDeveloper('Failed to update group $e');
      return false;
    }
  }


  Future<List<User>> searchUsersByEmail(String email,{int offset = 0, int limit = 10}) async{
    try{
      final token = await _authService.getToken();
      final response = await _dio.get(
        '/users/search',
        queryParameters: {
          'email':email,
          'offset':offset,
          'limit':limit,
        },
        options: Options(
          headers: {
            'Authorization':'Bearer $token'
          },
        )
      );
      if(response.statusCode == 200){
        final List<dynamic> data = response.data['users'] ?? [];
        return data.map((json)=> User.fromJson(json)).toList();
      }
      return [];
    }catch(e){
      Logger.logDeveloper('Error Searching users :$e');
      return [];
    }
  }



   Future<List<User>> getGroupMembers(String groupId) async {
  try {
    final token = await _authService.getToken();
    final response = await _dio.get(
      '/groups/$groupId/members',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;

      // Extract the list of members from 'members' key
      final List<dynamic> membersJson = data['members'] ?? [];

      // Map membersJson to list of User objects using the nested 'user' field
      return membersJson.map((memberMap) {
        final userJson = memberMap['user'] ?? {};
        return User.fromJson(userJson);
      }).toList();
    } else {
      return [];
    }
  } catch (e) {
    Logger.logDeveloper("Error while getting members $e");
    return [];
  }
}
 Future<bool> addMemberToGroup(String groupId, String email) async {
  final token = await _authService.getToken();
  Logger.logDeveloper('Token $token');
  Logger.logDeveloper('Adding member to group $groupId with email $email');
  try {
    final response = await _dio.post(
      '/groups/$groupId/members',
      data:{
        'email':email.trim(),
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
    Logger.logDeveloper('Add member response code: ${response.statusCode}');
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e, stack) {
    Logger.logDeveloper('Error adding member to group: $e\n$stack');
    return false;
  }
}

//Expenses 
Future<Expense?> createExpense({
  required String groupId,
  required String title,
  required String description,
  required double amount,
  required String splitType,
  required String paidByUserId,
  List<Map<String, dynamic>>? splits,
}) async {
  final Map<String, dynamic> payload = {
    "group_id": groupId,
    "title": title,
    "description": description,
    "amount": amount,
    "split_type": splitType,
  };

  // Only attach splits if splitType is 'percentage' or 'custom'
  if (splitType == 'percentage' || splitType == 'custom') {
    if (splits != null && splits.isNotEmpty) {
      payload['splits'] = splits;
    } else {
      // Handle missing splits if necessary
      return null;
    }
  }

  try {
    final token = await _authService.getToken();

    final response = await _dio.post(
      '/expenses/',
       data: payload,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
       
      ),
    );

    // Logger.logDeveloper('Expense creation response code: ${response.statusCode}, body: ${response.data}');

     if (response.statusCode == 200 || response.statusCode == 201) {
        final expenseData = response.data['expense'];
        return Expense.fromJson(expenseData);
      } else {
        return null;
      }
    } catch (e) {
      Logger.logDeveloper('Error creating expense: $e');
      return null;
    }
}

   Future<List<Expense>> getGroupExpenses(String groupId) async {
    try{
      final token = await _authService.getToken();
      final response = await _dio.get('/groups/$groupId/expenses',
      options: Options(
        headers: {
          'Authorization':'Bearer $token',
          'Content-type':'application/json',
        },
      ),
      );
      // final decodedData= jsonDecode(response.data);
      Logger.logDeveloper('Fetch Group expense response above :${response.statusCode}, ${response.data}');

      if(response.statusCode == 200){
        final List<dynamic> data = response.data['expenses'] ?? [];
      Logger.logDeveloper('Fetch Group expense response :${response.statusCode}, ${data}');

        return data.map((json)=> Expense.fromJson(json)).toList() ;
      }
      return [];
    }catch(e,stack){
      Logger.logDeveloper('Error fetching expense $e\n$stack');
      return [];
    }
   } 

     Future<bool> updateExpense({
    required String expenseId,
    required String title,
    required double  amount,
    required String description,
    required String splitType,
  })async {
    try{
      final token = await _authService.getToken();
        Logger.logDeveloper("updating response with $expenseId and with token $token");
      final response = await _dio.put('/expenses/$expenseId',
      data:{
           'title': title,
          'description': description,
          'amount': amount,
          'split_type': splitType,
      },
      options: Options(
        headers:{
          'Authorization':'Bearer $token',
          'Content-type':'Application/json',
        },
      ),
      );
    
      return response.statusCode == 200;
    }catch(e){
      Logger.logDeveloper('Failed to update Expense: $e');
      return false;
    }

  }



}
