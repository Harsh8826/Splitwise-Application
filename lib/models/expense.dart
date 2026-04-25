import 'user.dart';
import 'package:flutter_application_4/core/log/log.dart';

class ExpenseSplit {
  final String id;
  final String expenseId;
  final String userId;
  final User user;
  final double amount;
  final double percentage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ExpenseSplit({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.user,
    required this.amount,
    required this.percentage,
    required this.createdAt,
    this.updatedAt,
  });

  factory ExpenseSplit.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    final user = json['user'] is Map
        ? User.fromJson(Map<String, dynamic>.from(json['user']))
        : User.fromJson({'id': json['user_id']?.toString() ?? ''});

    return ExpenseSplit(
      id: json['id']?.toString() ?? '',
      expenseId: json['expense_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? user.id,
      user: user,
      amount: _toDouble(json['amount']),
      percentage: _toDouble(json['percentage']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: json['updated_at'] != null
          ? _parseDate(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense_id': expenseId,
      'user_id': userId,
      'amount': amount,
      'percentage': percentage,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'user': user.toJson(),
    };
  }

  /// Minimal payload form for sending to backend (used when creating/updating)
  Map<String, dynamic> toCreateJson() {
    return {
      'user_id': userId,
      'amount': amount,
      'percentage': percentage,
    };
  }
}

class Expense {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String category; // equal, percentage, custom
  final User paidBy;
  final List<ExpenseSplit> splits;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Expense({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.paidBy,
    required this.createdAt,
    List<ExpenseSplit>? splits,
    this.updatedAt,
  }) : splits = splits ?? [];

  // ✅ fromJson constructor
  factory Expense.fromJson(Map<String, dynamic> json) {
    Logger.logDeveloper("for deserializing Expense $json");

    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    // Parse paidBy (can be object or just id)
    final paidBy = json['paid_by'] is Map
        ? User.fromJson(Map<String, dynamic>.from(json['paid_by']))
        : User.fromJson({'id': json['paid_by']?.toString() ?? ''});

    // Parse splits list safely
    final List<ExpenseSplit> splitList = [];
    if (json['splits'] is List) {
      for (var item in (json['splits'] as List)) {
        if (item is Map) {
          splitList.add(ExpenseSplit.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return Expense(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      category: (json['split_type'] ?? json['category'])?.toString() ?? '',
      paidBy: paidBy,
      splits: splitList,
      createdAt: _parseDate(
          json['created_at'] ?? json['createdAt'] ?? json['date']),
      updatedAt: json['updated_at'] != null
          ? _parseDate(json['updated_at'])
          : null,
    );
  }

  // ✅ toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'paidBy': paidBy.toJson(),
      'splits': splits.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson({String? paidByIdOverride}) {
    return {
      'title': title,
      'description': description,
      'amount': amount,
      'split_type': category,
      'paid_by_id': paidByIdOverride ?? paidBy.id,
      'splits': splits.map((s) => s.toCreateJson()).toList(),
    };
  }

  // ------ Helpful getters ------
  /// returns a map userId -> amount
  Map<String, double> get amountsByUserId {
    final map = <String, double>{};
    for (var s in splits) map[s.userId] = s.amount;
    return map;
  }

  /// returns a map userId -> percentage
  Map<String, double> get percentagesByUserId {
    final map = <String, double>{};
    for (var s in splits) map[s.userId] = s.percentage;
    return map;
  }

  double amountForUser(String userId) => amountsByUserId[userId] ?? 0.0;
  double percentageForUser(String userId) => percentagesByUserId[userId] ?? 0.0;
}