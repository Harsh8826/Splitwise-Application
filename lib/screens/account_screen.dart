import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/colors.dart';
import 'dart:convert';


class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    // Try reading the username directly from storage
    String? storedUsername = await secureStorage.read(key: 'username');

    // If not found, try reading from authUser JSON
    if (storedUsername == null) {
      String? userJson = await secureStorage.read(key: 'authUser');
      if (userJson != null) {
        try {
          final Map<String, dynamic> userMap = Map<String, dynamic>.from(
            await Future.value(jsonDecode(userJson)),
          );
          storedUsername = userMap['name'];
        } catch (e) {
          storedUsername = "Unknown User";
        }
      }
    }

    setState(() {
      username = storedUsername ?? "Unknown User";
    });
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.primaryGreen)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await secureStorage.delete(key: 'auth_token');
      await secureStorage.delete(key: 'authUser');
      await secureStorage.delete(key: 'username');

      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.lightGreen,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        username ?? "Loading...",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.notifications, color: AppColors.primaryGreen),
                  title: Text('Notifications'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help, color: AppColors.primaryGreen),
                  title: Text('Help & Support'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {},
                ),   
                ListTile(
                  leading: Icon(Icons.settings, color: AppColors.primaryGreen),
                  title: Text('Settings'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _logout(context),
              child: Text(
                'Logout',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}