import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditIncomePage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  EditIncomePage({required this.docId, required this.initialData});

  @override
  _EditIncomePageState createState() => _EditIncomePageState();
}

class _EditIncomePageState extends State<EditIncomePage> {
  late TextEditingController _labelController;
  late TextEditingController _amountController;
  late TextEditingController _descController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.initialData['label']);
    _amountController = TextEditingController(text: widget.initialData['amount'].toString());
    _descController = TextEditingController(text: widget.initialData['description']);
    _selectedDate = widget.initialData['income_date'].toDate();
  }

  void _updateIncome() async {
    await FirebaseFirestore.instance.collectionGroup('income').where(FieldPath.documentId, isEqualTo: widget.docId).get().then((snap) async {
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.update({
          'label': _labelController.text,
          'amount': double.parse(_amountController.text),
          'income_date': _selectedDate,
          'description': _descController.text,
        });
        Navigator.pop(context);
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime.now());
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Modifier le revenu")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _labelController, decoration: InputDecoration(labelText: 'Nom')),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Montant')),
            TextField(controller: _descController, decoration: InputDecoration(labelText: 'Description')),
            TextButton(onPressed: _pickDate, child: Text('Choisir la date: ${_selectedDate.toLocal()}'.split(' ')[0])),
            ElevatedButton(onPressed: _updateIncome, child: Text('Mettre à jour')),
          ],
        ),
      ),
    );
  }
}
