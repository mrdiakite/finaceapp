import 'package:flutter/material.dart';
import '../theme/theme.dart';

class BalanceCard extends StatelessWidget {
  final double balance;

  const BalanceCard({Key? key, required this.balance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Solde actuel',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${balance >= 0 ? '+' : ''}${balance.toStringAsFixed(2)} €',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: balance >= 0
                        ? AppTheme.incomeColor
                        : AppTheme.expenseColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
