import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Widgets/balance_card.dart';
import '../theme/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'list_income_page.dart';
import 'list_expense_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardContent(),
    ListIncomePage(),
    ListExpensePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 
          ? AppBar(
              title: Text('Tableau de bord'),
              backgroundColor: AppTheme.primary,
              actions: [
                IconButton(
                  icon: Icon(Icons.logout),
                  tooltip: 'Déconnexion',
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Revenus'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_down), label: 'Dépenses'),
        ],
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  @override
  _DashboardContentState createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String _type = 'income';
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _addTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      setState(() {
        _errorMessage = "Veuillez choisir une date pour la transaction.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final uid = user!.uid;
    final label = _labelController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Veuillez saisir un montant valide (> 0).";
      });
      return;
    }

    try {
      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection(_type);

      final dateKey = '${_type}_date';

      await collection.add({
        'label': label,
        'amount': amount,
        dateKey: Timestamp.fromDate(_selectedDate!),
      });

      _labelController.clear();
      _amountController.clear();
      _dateController.clear();
      _selectedDate = null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction ajoutée avec succès')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors de l'ajout: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = user!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('income').snapshots(),
      builder: (context, incomeSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('expense').snapshots(),
          builder: (context, expenseSnapshot) {
            if (!incomeSnapshot.hasData || !expenseSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final incomeDocs = incomeSnapshot.data!.docs;
            final expenseDocs = expenseSnapshot.data!.docs;

            final totalIncome = incomeDocs.fold<double>(
              0.0,
              (sum, doc) => sum + (doc['amount'] as num).toDouble(),
            );

            final totalExpense = expenseDocs.fold<double>(
              0.0,
              (sum, doc) => sum + (doc['amount'] as num).toDouble(),
            );

            final solde = totalIncome - totalExpense;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BalanceCard(balance: solde),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTotalCard('Revenus', totalIncome, AppTheme.incomeColor),
                        _buildTotalCard('Dépenses', totalExpense, AppTheme.expenseColor),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Ajouter une transaction', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _labelController,
                            decoration: InputDecoration(
                              labelText: 'Libellé',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Veuillez saisir un libellé';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Montant (€)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Veuillez saisir un montant';
                              }
                              if (double.tryParse(value.trim()) == null) {
                                return 'Montant invalide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () => _selectDate(context),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez choisir une date';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: Text('Revenu'),
                                  value: 'income',
                                  groupValue: _type,
                                  activeColor: AppTheme.incomeColor,
                                  onChanged: (value) {
                                    setState(() {
                                      _type = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: Text('Dépense'),
                                  value: 'expense',
                                  groupValue: _type,
                                  activeColor: AppTheme.expenseColor,
                                  onChanged: (value) {
                                    setState(() {
                                      _type = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (_errorMessage != null) ...[
                            Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _addTransaction,
                              child: _isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text('Ajouter'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Répartition des transactions', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(8),
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              color: AppTheme.incomeColor,
                              value: totalIncome > 0 ? totalIncome : 1,
                              title: 'Revenus',
                              radius: 60,
                              titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: AppTheme.expenseColor,
                              value: totalExpense > 0 ? totalExpense : 1,
                              title: 'Dépenses',
                              radius: 60,
                              titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Dernières transactions', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ..._getRecentTransactions(incomeDocs, expenseDocs),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTotalCard(String label, double amount, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('${amount.toStringAsFixed(2)} €', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
      ),
    );
  }

  List<Widget> _getRecentTransactions(List<QueryDocumentSnapshot> incomeDocs, List<QueryDocumentSnapshot> expenseDocs) {
    final allDocs = [...incomeDocs, ...expenseDocs];

    allDocs.sort((a, b) {
      final aIsIncome = a.reference.path.contains('income');
      final bIsIncome = b.reference.path.contains('income');

      final aDate = (aIsIncome ? a['income_date'] : a['expense_date']) as Timestamp;
      final bDate = (bIsIncome ? b['income_date'] : b['expense_date']) as Timestamp;

      return bDate.toDate().compareTo(aDate.toDate());
    });

    final latest = allDocs.take(5);

    return latest.map((doc) {
      final isIncome = doc.reference.path.contains('income');
      final label = doc['label'];
      final amount = (doc['amount'] as num).toDouble();
      final date = ((isIncome ? doc['income_date'] : doc['expense_date']) as Timestamp).toDate();

      return ListTile(
        leading: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
        ),
        title: Text(label),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(date)),
        trailing: Text(
          '${isIncome ? '+' : '-'}${amount.toStringAsFixed(2)} €',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
          ),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}