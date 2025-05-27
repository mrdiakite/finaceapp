import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'add_income_page.dart';

class ListIncomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final incomeStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('income')
        .orderBy('income_date', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des revenus'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: incomeStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Aucun revenu enregistré',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final date = (data['income_date'] as Timestamp).toDate();

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirmer la suppression"),
                        content: Text("Voulez-vous vraiment supprimer ce revenu ?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text("Annuler"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text("Supprimer", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  doc.reference.delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Revenu supprimé"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddIncomePage(
                            incomeToEdit: {
                              'id': doc.id,
                              'label': data['label'],
                              'amount': data['amount'],
                              'description': data['description'] ?? '',
                              'date': date,
                            },
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.green, size: 30),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['label'] ?? 'Sans titre',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(date),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                if (data['description']?.isNotEmpty ?? false)
                                  Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text(
                                      data['description'],
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '+${data['amount'].toStringAsFixed(2)} €',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                DateFormat('HH:mm').format(date),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddIncomePage()),
        ),
      ),
    );
  }
}