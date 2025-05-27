class Income {
  final String id;
  final String label;
  final double amount;
  final DateTime incomeDate;
  final String? description;

  Income({
    required this.id,
    required this.label,
    required this.amount,
    required this.incomeDate,
    this.description,
  });

  factory Income.fromMap(String id, Map<String, dynamic> data) {
    return Income(
      id: id,
      label: data['label'],
      amount: (data['amount'] as num).toDouble(),
      incomeDate: data['income_date'].toDate(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'amount': amount,
      'income_date': incomeDate,
      'description': description,
    };
  }
}
