import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';

class TransactionItem extends StatelessWidget {
  final String label;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionItem({
    Key? key,
    required this.label,
    required this.amount,
    required this.date,
    this.isIncome = true,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Section gauche : label + date
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),

            // Section droite : montant + actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${amount.toStringAsFixed(2)} €',
                  style: TextStyle(
                    color: isIncome
                        ? AppTheme.incomeColor
                        : AppTheme.expenseColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (onEdit != null || onDelete != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: onEdit,
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete,
                              size: 20, color: Colors.red),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
