import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/group_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final String groupId;
  final List<User> groupMembers;
  const AddExpenseScreen({Key? key, required this.groupId, required this.groupMembers}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  late String _splitType;
  final Map<String, TextEditingController> _splitControllers = {};

  @override
  void initState() {
    super.initState();
    _splitType = 'equal';
    for (var user in widget.groupMembers) {
      _splitControllers[user.id] = TextEditingController(text: '0');
    }
    _distributeEqual();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _splitControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _distributeEqual() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (widget.groupMembers.isEmpty) return;
    final equal = (amount / widget.groupMembers.length).toStringAsFixed(2);
    for (var controller in _splitControllers.values) {
      controller.text = equal;
    }
  }

  void _onSplitTypeChanged(String? val) {
    if (val == null) return;
    setState(() {
      _splitType = val;
      if (_splitType == 'equal') {
        _distributeEqual();
      } else {
        for (var controller in _splitControllers.values) {
          controller.text = '0';
        }
      }
    });
  }

  Future<void> _createExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    List<Map<String, dynamic>>? splits;

    if (_splitType == 'percentage') {
      // 📊 percentage split: calculate amounts from percentages
      double totalPerc = 0;
      splits = widget.groupMembers.map((user) {
        final perc = double.tryParse(_splitControllers[user.id]?.text ?? '') ?? 0;
        totalPerc += perc;
        final userAmount = (perc / 100) * amount;
        return {
          'user_id': user.id,
          'amount': double.parse(userAmount.toStringAsFixed(2)),
          'percentage': double.parse(perc.toStringAsFixed(2)),
        };
      }).toList();

      if ((totalPerc - 100).abs() > 0.5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Percentages must add up to 100%')),
        );
        return;
      }
    } else if (_splitType == 'custom') {
      // 💰 custom split: calculate percentages from amounts
      double totalAmt = 0;
      splits = widget.groupMembers.map((user) {
        final userAmount = double.tryParse(_splitControllers[user.id]?.text ?? '') ?? 0;
        totalAmt += userAmount;
        final perc = amount > 0 ? (userAmount / amount) * 100 : 0;
        return {
          'user_id': user.id,
          'amount': double.parse(userAmount.toStringAsFixed(2)),
          'percentage': double.parse(perc.toStringAsFixed(2)),
        };
      }).toList();

      if ((totalAmt - amount).abs() > 0.5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Custom amounts must add up to total amount')),
        );
        return;
      }
    }

    final provider = Provider.of<GroupProvider>(context, listen: false);
    const defaultPaidById = ''; // TODO: Replace with actual logged-in user ID

    final expense = await provider.createExpense(
      groupId: widget.groupId,
      title: title,
      description: description,
      amount: amount,
      splitType: _splitType,
      splits: splits,
      paidByUserId: defaultPaidById,
    );

    if (expense != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense created successfully')),
      );
      Navigator.of(context).pop(expense);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.expenseError ?? 'Failed to create expense')),
      );
    }
  }

  Widget _buildSpacing() => const SizedBox(height: 16);

  Widget _buildSplitInputs() {
    if (_splitType == 'equal') {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: const Text(
          'Splits will be divided equally.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _splitType == 'percentage'
                ? 'Enter split percentages (sum to 100%)'
                : 'Enter split amounts (sum must match total)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...widget.groupMembers.map((user) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('${user.name} (${user.email})')),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _splitControllers[user.id],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: _splitType == 'percentage' ? '%' : 'Amount',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        final numVal = double.tryParse(val);
                        if (numVal == null || numVal < 0) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMembers = widget.groupMembers.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Enter title' : null,
                    ),
                    _buildSpacing(),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    _buildSpacing(),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter amount';
                        if ((double.tryParse(val) ?? 0) <= 0) return 'Enter valid amount';
                        return null;
                      },
                      onChanged: (val) {
                        if (_splitType == 'equal') _distributeEqual();
                      },
                    ),
                    _buildSpacing(),
                    DropdownButtonFormField<String>(
                      value: _splitType,
                      decoration: const InputDecoration(
                        labelText: 'Split Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'equal', child: Text('Equal')),
                        DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                        DropdownMenuItem(value: 'custom', child: Text('Custom')),
                      ],
                      onChanged: _onSplitTypeChanged,
                    ),
                    if (_splitType != 'equal') _buildSplitInputs(),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _createExpense,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text(
                    'Create Expense',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}