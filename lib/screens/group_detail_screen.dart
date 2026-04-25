import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/expense.dart';
import '../services/group_provider.dart';
import 'add_expense_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _actionKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late GroupProvider _provider;
  bool _autoSearch = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
     if(_autoSearch){
      Future.delayed(Duration(milliseconds: 300),(){
        FocusScope.of(context).requestFocus((FocusNode()));
      });
    }

    Future.microtask(() {
      _provider = Provider.of<GroupProvider>(context, listen: false);
      _provider.fetchGroupById(widget.groupId);
      _provider.fetchGroupMembers(widget.groupId);
      _provider.fetchGroupExpenses(widget.groupId);
    });
   
  }


  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        _provider.searchUsers(query);
      } else {
        _provider.clearSearchResults();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggleMenu() {
    if (_overlayEntry == null) {
      _showMenu();
    } else {
      _removeOverlay();
    }
  }

  void _showMenu() {
    final renderBox = _actionKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;

    double left = offset.dx + size.width - 170;
    if (left < 10) left = 10;
    if (left + 170 > screenWidth) left = screenWidth - 180;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: _removeOverlay,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            left: left,
            top: offset.dy + size.height,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 170,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        _removeOverlay();
                        final createdExpense = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddExpenseScreen(
                              groupId: widget.groupId,
                              groupMembers: _provider.groupMembers,
                            ),
                          ),
                        );
                        if (createdExpense != null && context.mounted) {
                          await _provider.fetchGroupExpenses(widget.groupId);

                          // ✅ Log activity
                          final groupName = _provider.selectedGroup?.name ?? "this group";
                          _provider.logExpenseAdded(
                            createdExpense.paidBy.name,
                            createdExpense.title,
                            groupName,
                          );

                          setState(() {});
                        }
                      },
                     
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline, color: Colors.teal),
                            SizedBox(width: 12),
                            Flexible(
                              child: Text('Add Expense',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    InkWell(
                      onTap: () {
                        _removeOverlay();
                        if (_provider.selectedGroup != null) {
                          _showEditGroupForm(
                            _provider.selectedGroup!.name,
                            _provider.selectedGroup!.description ?? '',
                          );
                        }
                      },
                      
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.teal),
                            SizedBox(width: 12),
                            Flexible(
                              child: Text('Edit Group',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1,),
                    InkWell(
                      onTap: (){
                        _removeOverlay();
                        setState(() {
                          _autoSearch=true;
                        });
                        Future.delayed(const Duration(milliseconds: 200),(){
                          FocusScope.of(context).requestFocus(FocusNode());
                        });
                      },
                     child: const Padding(padding: EdgeInsets.symmetric(horizontal: 15,vertical: 12),
                     child: Row(
                      children: [
                        Icon(Icons.person_3,color: Colors.teal,),
                        SizedBox(width: 12,),
                        Flexible(child: Text('Add Members',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis, ))
                      ],
                     ),
                     ), 
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showEditGroupForm(String name, String description) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: name);
    final descriptionController = TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Group', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Group Name')),
              const SizedBox(height: 16),
              TextFormField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final success = await _provider.updateGroup(
                groupId: widget.groupId,
                name: nameController.text.trim(),
                description: descriptionController.text.trim(),
              );
              if (!mounted) return;
              Navigator.pop(context);
              if (success){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Group Updated successfully")),
                );
                await _provider.fetchGroupById(widget.groupId);
              } else{
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to update Group")),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditExpenseForm(BuildContext context, Expense expense) {
    final titleController = TextEditingController(text: expense.title);
    final descController = TextEditingController(text: expense.description);
    final amountController = TextEditingController(text: expense.amount.toString());
    String splitType = expense.category;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
            const SizedBox(height: 12),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
            const SizedBox(height: 12),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount")),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: splitType,
              items: ["equal", "percentage", "custom"].map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
              onChanged: (val) => splitType = val!,
              decoration: const InputDecoration(labelText: "Split Type"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              final success = await _provider.updateExpense(
                groupId: widget.groupId,
                expenseId: expense.id,
                title: titleController.text,
                description: descController.text,
                amount: double.tryParse(amountController.text) ?? expense.amount,
                splitType: splitType,
              );
              if (!mounted) return;
              if (success) {
                await _provider.fetchGroupExpenses(widget.groupId);

                // ✅ Log activity
                final groupName = _provider.selectedGroup?.name ?? "this group";
                _provider.logExpenseUpdated(expense.paidBy.name, expense.title, groupName);

                Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupProvider>(context);
    final group = provider.selectedGroup;
    final expenses = provider.expenses;

    final isLoading = provider.isLoading || provider.isSearching || provider.isLoadingExpense || provider.isLoadingMembers || provider.isLoadingGroupDetails;

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? "Group Detail"),
        backgroundColor: Colors.teal,
        actions: [
          InkWell(
            key: _actionKey,
            onTap: _toggleMenu,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.more_vert),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              autofocus: _autoSearch,
              decoration: InputDecoration(
                hintText: 'Search users by email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.clearSearchResults();
                            },
                          )
                        : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : group == null
              ? const Center(child: Text("No group found"))
              : RefreshIndicator(
                  onRefresh: () async {
                    await provider.fetchGroupById(group.id);
                    await provider.fetchGroupMembers(group.id);
                    await provider.fetchGroupExpenses(group.id);
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Group Info
                      Card(
                        color: Colors.teal.shade50,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(group.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(group.description ?? 'No description'),
                            const SizedBox(height: 12),
                            Text('Created: ${group.creationDate}'),
                            Text('Updated: ${group.updationDate}'),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Members
                      const Text("Members", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ...provider.groupMembers.map((u) => ListTile(
                            leading: CircleAvatar(child: Text(u.name.isNotEmpty ? u.name[0] : '?')),
                            title: Text(u.name),
                            subtitle: Text(u.email),
                          )),
                      const SizedBox(height: 16),

                      // Expenses with old split details
                      const Text("Expenses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      if (expenses.isEmpty)
                        const Text("No expenses found")
                      else
                        ...expenses.map((expense) {
                          return Card(
                            color: Colors.purple.shade50,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Title:  ${expense.title}" ,
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.teal),
                                        onPressed: () => _showEditExpenseForm(context, expense),
                                      ),
                                    ],
                                  ),
                                  Text("Description: ${expense.description}"),
                                  const SizedBox(height: 6),
                                  Text("Amount: \u{20B9}${expense.amount.toStringAsFixed(2)}"),
                                
                                  const SizedBox(height: 8),
                                  if (expense.splits.isNotEmpty) ...[
                                    const Text("Split Details:", style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: expense.splits.map((split) {
                                        String details;
                                        if (expense.category == "percentage") {
                                          details =
                                              "${split.user.name} owes ${split.percentage.toStringAsFixed(2)}% "
                                              "(\u{20B9}${split.amount.toStringAsFixed(2)})";
                                        } else {
                                          details = "${split.user.name} owes \u{20B9}${split.amount.toStringAsFixed(2)}";
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Text(details),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text("Created: ${expense.createdAt.toString().substring(0, 16)}",
                                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}