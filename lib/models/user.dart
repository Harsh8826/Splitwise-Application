class User {
  final String id;
  final String name;
  final String email;
  final String? phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });
    factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['user_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

