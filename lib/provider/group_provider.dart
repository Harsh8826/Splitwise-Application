// import 'package:flutter/foundation.dart';
// import '../models/group.dart';
// import '../models/expense.dart';
// import '../models/user.dart';
// import 'package:flutter/material.dart';
// class GroupProvider with ChangeNotifier {
//   final List<Group>  _groups = [];
//   List<User>  _friends = [];

//   List<Group> get groups => _groups;
//   List<User> get friends => _friends;

//   void addGroup(Group group) {
//     _groups.add(group);
//     notifyListeners();
//   }



//   void deleteGroup(String groupId) {
//   _groups.removeWhere((group) => group.id == groupId);
//   notifyListeners();
// }

//   void addExpenseToGroup(String groupId, Expense expense) {
//     final group = _groups.firstWhere((g) => g.id == groupId);
//     group.expenses.add(expense);
//     notifyListeners();
//   }
//     void deleteExpenseFromGroup(String groupId, String expenseId) {
//     final group = _groups.firstWhere((g) => g.id == groupId);
//     group.expenses.removeWhere((e) => e.id == expenseId);
//     notifyListeners();
//   }

//  void addFriend(User friend) {
//   // Optional: prevent duplicates
//   for (var group in _groups) {
//     if (!group.members.any((member) => member.id == friend.id)) {
//       group.members.add(friend);
//     }
//   }
//   notifyListeners();
// }
//   void removeFriend(String friendId) {
//   for (var group in _groups) {
//     group.members.removeWhere((member) => member.id == friendId);
//   }
//   notifyListeners();
// }
//   double calculateUserBalance(User user) {
//     double totalOwed = 0.0;
//     double totalPaid = 0.0;

//     for (var group in _groups) {
//       for (var expense in group.expenses) {
//         if (expense.paidBy.id == user.id) {
//           totalPaid += expense.amount; // User paid this
//         }
//         if (expense.split.containsKey(user)) {
//           totalOwed += expense.split[user]!; // User's share to pay
//         }
//       }
//     }

//     return totalPaid - totalOwed; // Positive: User is owed; Negative: User owes
//   }

//   Group getGroupById(String id) {
//   return _groups.firstWhere((group) => group.id == id);
// }
// }
