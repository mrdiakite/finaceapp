import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/welcome_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/add_income_page.dart';
import 'screens/add_expense_page.dart';
import 'screens/list_income_page.dart';
import 'screens/list_expense_page.dart';
import 'firebase_options.dart';
import 'Widgets/balance_card.dart';
import 'Widgets/transaction_item.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinanceApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
      ],
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/dashboard': (context) => DashboardPage(),
        '/add-income': (context) => AddIncomePage(),
        '/add-expense': (context) => AddExpensePage(),
        '/list-income': (context) => ListIncomePage(),
        '/list-expense': (context) => ListExpensePage(),
      },
    );
  }
}