import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/group_provider.dart';
import '../models/activity.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupProvider>(context);
    final List<Activity> activities = provider.activities;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        backgroundColor: Colors.teal,
      ),
      body: activities.isEmpty
          ? const Center(child: Text('No activity yet'))
          : ListView.separated(
              itemCount: activities.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ListTile(
                  leading: const Icon(Icons.receipt_long, color: Colors.teal),
                  title: Text(activity.message),
                  subtitle: Text(
                    activity.createdAt.toString().substring(0, 16),
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
    );
  }
}