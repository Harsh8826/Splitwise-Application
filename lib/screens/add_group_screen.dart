import 'package:flutter/material.dart';
import 'package:flutter_application_4/core/log/log.dart';
import 'package:flutter_application_4/screens/groups_screen.dart';
import 'package:flutter_application_4/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../services/group_provider.dart';

class AddGroupScreen extends StatefulWidget {
  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();


  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;
  
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    await groupProvider.addGroup(
      _nameController.text.trim(),
      _descriptionController.text.trim(),
    );
        // final groupResponseData= Provider.of<GroupProvider>(context,listen:false).groups;
      // Logger.logDeveloper("response in add screen after creating group, ${groupResponseData.first.name}");
    if (groupProvider.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created successfully')),
      );
      Navigator.push(context,MaterialPageRoute(builder: (_)=>const HomeScreen(),
      settings: RouteSettings(arguments: {"selectedIndex":1})
      ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(groupProvider.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<GroupProvider>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          size: 28, color: AppColors.primaryGreen),
                    ),
                    const Text(
                      'Add Group',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: isLoading ? null : _createGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Create',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(
                    controller: _nameController,
                    label: "Group Name *",
                    validator: (v) => v == null || v.isEmpty
                        ? "Please enter a group name"
                        : null),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: "Description",
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
