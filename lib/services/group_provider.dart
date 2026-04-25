import 'package:flutter/material.dart';
import 'package:flutter_application_4/core/log/log.dart';
import 'package:flutter_application_4/models/activity.dart';
import '../models/group.dart';
import '../models/expense.dart';
import '../models/user.dart';

import '../services/group_service.dart';

class GroupProvider with ChangeNotifier{
  GroupProvider(){
    fetchUserGroups();
  }
  final GroupService _groupService = GroupService();
  bool isAddingMember = false;
  
  
  final List<Group> _groups = [];
  final List<User> _friends = [];
  final List<Group> _allGroups = [];
   List<fetchAllGroups> _userGroups = [];
   List <User> _searchResults = [];
  List <Expense> _expenses = [];
  final List<Activity> _activities = [];

  bool _isLoading = false;
  String? _errorMessage;
  Group? _selectedGroup;
  bool _isLoadingGroupDetails = false;
  String? _groupDetailsError;
  bool _isSearching = false;
  bool _isCreatingExpense = false;
  String? _expenseError;
  bool _isLoadingExpense = false;


  List<Group> get groups => _groups;
  List<User> get friends => _friends;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Group> get allgroups => _allGroups;
  List<fetchAllGroups> get usergroups => _userGroups;
  Group? get selectedGroup => _selectedGroup;
  bool get isLoadingGroupDetails => _isLoadingGroupDetails;
  String? get groupDetailsError => _groupDetailsError;
  List<User> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get isCreatingExpense => _isCreatingExpense;
  String? get expenseError => _expenseError;
  bool get isLoadingExpense => _isLoadingExpense;
  List<Expense> get expenses => _expenses;
   List<Activity> get activities => _activities;


  Future<void> addGroup(String name, String description) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newGroup = await _groupService.createGroup(name, description);
      if (newGroup != null) {
        _groups.add(newGroup);
      } else {
        _errorMessage = "Failed to create group.";
      }
    } catch (e) {
      _errorMessage = "Error creating group: $e";
    }

    _isLoading = false;
    notifyListeners();
  }


 Future<void> fetchUserGroups() async{
  _setLoading(true);
  try{
     _userGroups = await _groupService.getUserGroups();
     Logger.logDeveloper("get user groups in provider file: $_userGroups");
    _errorMessage = null;
  }
  catch(e){
    _errorMessage = "Failed to load user groups";
   
  }
  finally{
    _setLoading(false);
  }
 }
Future<void> fetchGroupById(String groupId) async {
  _isLoadingGroupDetails = true;
  _groupDetailsError = null;
  notifyListeners();

  try {
    final group = await _groupService.getGroupById(groupId);
    if (group != null) {
      _selectedGroup = group;
    } else {
      _groupDetailsError = "Group not found";
    }
  } catch (e) {
    _selectedGroup = null;
    _groupDetailsError = "Failed to load group details: $e";
  }

  _isLoadingGroupDetails = false;
  notifyListeners();
}



Future<bool> updateGroup({
  required String groupId,
  required String name,
  required String description
}
) async{
  _isLoading = true;
  notifyListeners();
  final success = await _groupService.updateGroup(
    groupId:groupId,
    name:name,
    description:description,
  );
  _isLoading = false;
  notifyListeners();
  return success;
}

Future<void> searchUsers(String email) async{
  if (email.isEmpty){
    clearSearchResults();
    return;
  }
  _isSearching = true;
  notifyListeners();
  _searchResults = await _groupService.searchUsersByEmail(email);
  _isSearching = false;
  notifyListeners();
}

List<User> _groupMembers = [];
bool _isLoadingMembers = false;

List<User> get groupMembers  => _groupMembers;
bool get isLoadingMembers => _isLoadingMembers;

Future<void> fetchGroupMembers(String groupId) async{
  _isLoadingMembers = true;
  notifyListeners();
  try{
    _groupMembers = await _groupService.getGroupMembers(groupId);
  }
  catch(e){
    _groupMembers = [];
  }
  _isLoadingMembers = false;
  notifyListeners();
}

Future<bool> addMemberToGroup(
  String groupId,
  String email,
) async{
    final success = await _groupService.addMemberToGroup(groupId, email);
    if(success){
      await fetchGroupMembers(groupId);
    }
    return success;
}


Future<Expense?> createExpense({
  required String groupId,
  required String title,
  required String description,
  required double amount,
  required String splitType,
  List<Map<String, dynamic>>? splits,
  required String paidByUserId,
}) async {
  try {
    final  response = await _groupService.createExpense(
      groupId: groupId,
      title: title,
      description: description,
      amount: amount,
      splitType: splitType,
      splits: splits,
      paidByUserId: paidByUserId,
    );
     if (response == null) {
        _expenseError = 'Failed to create expense';
      }

      _isCreatingExpense = false;
      notifyListeners();
      return response;
  }catch (e) {
      _expenseError = 'Exception: $e';
      _isCreatingExpense = false;
      notifyListeners();
      return null;
    }
}

 Future<void> fetchGroupExpenses(String groupId) async{
  _isLoadingExpense = true;
  _expenseError = null;
  notifyListeners();
  try{
    final expenseList = await _groupService.getGroupExpenses(groupId);
    _expenses = expenseList;
  }catch(e){
    _expenseError = 'Error fetching expense $e';
  }
  _isLoadingExpense = false;
  notifyListeners();


 }
 Future<bool> updateExpense({
  required String groupId,
    required String expenseId,
    required String title,
    required String description,
    required double amount,
    required String splitType,
 }) async{
  final success = await _groupService.updateExpense(expenseId: expenseId, title: title, amount: amount, description: description, splitType: splitType);
  if(success){
    await fetchGroupExpenses(groupId);
  }
  return success;
 }

  void logExpenseAdded(String userName,String expenseTitle,String groupName){
    _activities.insert(0, 
    Activity(message:"$userName added \"$expenseTitle\" $groupName", createdAt: DateTime.now(),
    ),
    );
    notifyListeners();
  }


  
    void logExpenseUpdated(String userName, String expenseTitle, String groupName) {
    _activities.insert(
      0,
      Activity(
        message: "$userName updated \"$expenseTitle\" in $groupName",
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void clearSearchResults() {
    _searchResults.clear();
    setSearching(false);  // use setter method here
  }
 void setSearching(bool value) {
    _isSearching = value;
    notifyListeners();
  }

 void _setLoading(bool value){
  _isLoading = value;
  notifyListeners();

 }
  void removeGroup(String groupId) {
    _groups.removeWhere((g) => g.id == groupId);
    notifyListeners();
  }

  void clearGroups() {
    _groups.clear();
    notifyListeners();
  }

  void addGroupLocal(Group group) {
    _groups.add(group);
    notifyListeners();
  }

  void addFriend(User user){
    if(!friends.any((u)=>u.email == user.email)){
      friends.add(user);
      notifyListeners();
    }

  }

  void removeFriend(User user){
    friends.removeWhere((u)=>u.email == user.email);
    notifyListeners();
  }
  // void addExpenseToGroup(String groupId, Expense expense) {
  //   final group = _groups.firstWhere((g) => g.id == groupId);
  //   group.expenses.add(expense);
  //   notifyListeners();
  // }

  // void deleteExpenseFromGroup(String groupId, String expenseId) {
  //   final group = _groups.firstWhere((g) => g.id == groupId);
  //   group.expenses.removeWhere((e) => e.id == expenseId);
  //   notifyListeners();
  // }

  // void addFriend(User friend) {
  //   for (var group in _groups) {
  //     if (!group.members.any((member) => member.id == friend.id)) {
  //       group.members.add(friend);
  //     }
  //   }
  //   notifyListeners();
  // }

  // void removeFriend(String friendId) {
  //   for (var group in _groups) {
  //     group.members.removeWhere((member) => member.id == friendId);
  //   }
  //   notifyListeners();
  // }

  // double calculateUserBalance(User user) {
  //   double totalOwed = 0.0;
  //   double totalPaid = 0.0;
  //   for (var group in _groups) {
  //     for (var expense in group.expenses) {
  //       if (expense.paidBy.id == user.id) {
  //         totalPaid += expense.amount;
  //       }
  //       if (expense.split.containsKey(user)) {
  //         totalOwed += expense.split[user]!;
  //       }
  //     }
  //   }
  //   return totalPaid - totalOwed;
  // }

  // Group getGroupById(String id) {
  //   return _groups.firstWhere((group) => group.id == id);
  // }
}

