import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddIncomePage extends StatefulWidget {
  final Map<String, dynamic>? incomeToEdit;

  const AddIncomePage({Key? key, this.incomeToEdit}) : super(key: key);

  @override
  _AddIncomePageState createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.incomeToEdit != null) {
      _labelController.text = widget.incomeToEdit!['label'];
      _amountController.text = widget.incomeToEdit!['amount'].toString();
      _descriptionController.text = widget.incomeToEdit!['description'] ?? '';
      _selectedDate = widget.incomeToEdit!['date'];
    }
  }

  Future<void> _submitIncome() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _isLoading = true);

      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final incomeData = {
          'label': _labelController.text.trim(),
          'amount': double.parse(_amountController.text),
          'description': _descriptionController.text.trim(),
          'income_date': Timestamp.fromDate(_selectedDate!),
          'updated_at': Timestamp.now(),
        };

        if (widget.incomeToEdit == null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('income')
              .add(incomeData);
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('income')
              .doc(widget.incomeToEdit!['id'])
              .update(incomeData);
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
      lastDate: DateTime(now.year + 1),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[700]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[700]!,
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
        title: Text(widget.incomeToEdit == null ? 'Ajouter un revenu' : 'Modifier le revenu'),
        backgroundColor: Colors.green[700],
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
                    labelText: 'Intitulé*',
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
                    final amount = double.tryParse(value);
                    if (amount == null) return 'Montant invalide';
                    if (amount <= 0) return 'Le montant doit être positif';
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
                    backgroundColor: Colors.green[700],
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
                    onPressed: _isLoading ? null : _submitIncome,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.green[800],
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(widget.incomeToEdit == null ? 'AJOUTER' : 'MODIFIER'),
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