import 'package:flutter/material.dart';
import '../theme/theme.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet, size: 100, color: AppTheme.primary),
              const SizedBox(height: 32),
              Text(
                'Bienvenue sur FinanceApp',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Gérez vos revenus, vos dépenses et votre solde en toute simplicité.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: Icon(Icons.login),
                label: Text("Se connecter"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: Icon(Icons.person_add),
                label: Text("Créer un compte"),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  side: BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
