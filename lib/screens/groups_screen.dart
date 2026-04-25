import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/group.dart';
import 'package:flutter_application_4/screens/group_detail_screen.dart';
import 'package:provider/provider.dart';
import '../services/group_provider.dart';
import 'add_group_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  List<fetchAllGroups> userGroupsForUi = [];

  @override
  void initState() {
    super.initState();
    // Fetch groups when the screen loads
    Future.microtask(() {
      Provider.of<GroupProvider>(context, listen: false).fetchUserGroups();
    });
    userGroupsForUi =
        Provider.of<GroupProvider>(context, listen: false).usergroups;
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        title: const Text(
          'My Groups',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => groupProvider.fetchUserGroups(),
        child: groupProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : groupProvider.errorMessage != null
                ? Center(child: Text(groupProvider.errorMessage!))
                : userGroupsForUi.isEmpty
                    ? const Center(
                        child: Text(
                          'No groups found',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: groupProvider.usergroups.length,
                        itemBuilder: (context, index) {
                          final group =
                              groupProvider.usergroups.reversed.toList()[index];

                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation:0,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal.shade100,
                                child: Text(
                                  group.name.isNotEmpty
                                      ? group.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal),
                                ),
                              ),
                              title: Text(
                                group.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                group.description ?? 'No description',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade600),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GroupDetailScreen(groupId: group.id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () async {
          final bool? created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddGroupScreen()),
          );
          if (created == true) {
            groupProvider.fetchUserGroups();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}