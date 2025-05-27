import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddExpensePage extends StatefulWidget {
  final Map<String, dynamic>? expenseToEdit;

  const AddExpensePage({Key? key, this.expenseToEdit}) : super(key: key);

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      _labelController.text = widget.expenseToEdit!['label'];
      _amountController.text = widget.expenseToEdit!['amount'].toString();
      _descriptionController.text = widget.expenseToEdit!['description'] ?? '';
      _selectedDate = widget.expenseToEdit!['date'];
    }
  }

  Future<void> _submitExpense() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _isLoading = true);

      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final expenseData = {
          'label': _labelController.text.trim(),
          'amount': double.parse(_amountController.text),
          'description': _descriptionController.text.trim(),
          'expense_date': Timestamp.fromDate(_selectedDate!),
          'updated_at': Timestamp.now(),
        };

        if (widget.expenseToEdit == null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('expense')
              .add(expenseData);
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('expense')
              .doc(widget.expenseToEdit!['id'])
              .update(expenseData);
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseToEdit == null ? 'Ajouter une dépense' : 'Modifier la dépense'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    labelText: 'Libellé*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (value) => value!.isEmpty ? 'Ce champ est obligatoire' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Montant (€)*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.euro),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value!.isEmpty) return 'Ce champ est obligatoire';
                    if (double.tryParse(value) == null) return 'Montant invalide';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (facultatif)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickDate,
                  icon: Icon(Icons.calendar_today),
                  label: Text(
                    _selectedDate == null
                        ? 'Sélectionner une date*'
                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
                if (_selectedDate == null)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '* Champ obligatoire',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitExpense,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.deepPurple[800],
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(widget.expenseToEdit == null ? 'AJOUTER' : 'MODIFIER'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}