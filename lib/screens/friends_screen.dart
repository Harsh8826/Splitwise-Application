import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/group_provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final provider = Provider.of<GroupProvider>(context, listen: false);
      final query = _searchController.text.trim();

      if (query.isNotEmpty) {
        provider.searchUsers(query);
      } else {
        provider.clearSearchResults();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    final provider = Provider.of<GroupProvider>(context, listen: false);

    setState(() {
      if (_isSearchActive) {
        _searchController.clear();
        provider.clearSearchResults();
      }
      _isSearchActive = !_isSearchActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive ? null : const Text('Friends'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(_isSearchActive ? Icons.close : Icons.search),
          onPressed: _toggleSearch,
        ),
        bottom: _isSearchActive
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Add Friend',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              )
            : null,
      ),

      body: provider.isSearching
          ? const Center(child: CircularProgressIndicator())
          : _searchController.text.isEmpty
          ? _buildFriendsList(provider) // show normal friends list
          : provider.searchResults.isEmpty
          ? const Center(
              child: Text("No users found"),
            ) // search active & no results
          : _buildSearchResults(provider), // show filtered results
    );
  }

  // ================= FRIEND LIST DISPLAY ================
  Widget _buildFriendsList(GroupProvider provider) {
    if (provider.friends.isEmpty) {
      return const Center(child: Text('No friends added yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.friends.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final friend = provider.friends[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade300,
              child: Text(
                friend.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              friend.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(friend.email),
            trailing: IconButton(
              onPressed: () {
                provider.removeFriend(friend);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${friend.name} removed"),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.person_remove,color: Colors.teal,),
            ),
          ),
        );
      },
    );
  }

  // ================= SEARCH RESULT LIST ================
  Widget _buildSearchResults(GroupProvider provider) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.searchResults.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final User user = provider.searchResults[index];
        final bool isFriend = provider.friends.any(
          (f) => f.email == user.email,
        );

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade300,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(user.email),
            trailing: IconButton(
              icon: const Icon(Icons.person_add, color: Colors.teal),
              onPressed: () {
                final provider = Provider.of<GroupProvider>(
                  context,
                  listen: false,
                );
                provider.addFriend(user);

                // Clear UI and refresh
                _searchController.clear();
                provider.clearSearchResults();
                setState(() {});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${user.name} added as friend"),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
