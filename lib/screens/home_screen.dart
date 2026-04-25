import 'package:flutter/material.dart';
import 'package:flutter_application_4/core/log/log.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../widgets/settled_up_illustration.dart';
import '../constants/colors.dart';
import '../models/user.dart';
import 'friends_screen.dart';
import 'groups_screen.dart';
import 'activity_screen.dart';
import 'account_screen.dart';
import 'add_group_screen.dart';
import 'add_expense_screen.dart'; // Import AddExpenseScreen
import '../services/group_provider.dart';

class HomeScreen extends StatefulWidget {
  final int? currentIndex;
  const HomeScreen({super.key, this.currentIndex});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<User> _settledFriends = [];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve index passed via route arguments (if any)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _currentIndex = args["selectedIndex"];
     
    }
    Logger.logDeveloper("current index is $_currentIndex");
  }

  void _loadSampleData() {
    _settledFriends = [
      User(id: '1', name: 'John Smith', email: 'John@gmail.com'),
      User(id: '2', name: 'Sarah Wilson', email: 'Sarah@gmail.com'),
      User(id: '3', name: 'Mike Johnson', email: 'Mike@gmail.com'),
      User(id: '4', name: 'Emma Davis', email: 'Emma@gmail.com'),
      User(id: '5', name: 'David Brown', email: 'David@gmail.com'),
      User(id: '6', name: 'Lisa Taylor', email: 'Lisa@gmail.com'),
      User(id: '7', name: 'Chris Anderson', email: 'Chris@gmail.com'),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onAddPressed() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.group_add, color: AppColors.primaryGreen),
              title: Text('Add Group'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddGroupScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add, color: AppColors.primaryGreen),
              title: Text('Add Friend'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  
                  _currentIndex =0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return FriendsScreen();
      case 1:
        return GroupsScreen();
      case 2:
        return ActivityScreen();
      case 3:
        return AccountScreen();
      default:
        return _buildSettledUpScreen();
    }
  }

  Widget _buildSettledUpScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Icon(Icons.search, color: Colors.grey),
            title: Text(''),
            actions: [
              TextButton(
                onPressed: () {},
                child: Text(
                  'Add friends',
                  style: TextStyle(color: AppColors.primaryGreen),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'You are all settled up!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 40),
                SettledUpIllustration(),
                SizedBox(height: 30),
                Text(
                  'Hiding friends you settled up with over 7\ndays ago',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    _showSettledFriends();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryGreen),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    'Show ${_settledFriends.length} settled-up friends',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSettledFriends() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settled-up friends',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _settledFriends.length,
                itemBuilder: (context, index) {
                  final friend = _settledFriends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.lightGreen,
                      child: Text(
                        friend.name[0],
                        style: TextStyle(color: AppColors.darkGreen),
                      ),
                    ),
                    title: Text(friend.name),
                    subtitle: Text('Settled up'),
                    trailing: Text(
                      '\$0.00',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildCurrentScreen()),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        onAddPressed: _onAddPressed,
      ),
    );
  }
}
