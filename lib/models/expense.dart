const List<String> kCategories = [
  'Food',
  'Travel',
  'Shopping',
  'Bills',
  'Education',
  'Health',
  'Entertainment',
  'Other',
];

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String note;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory Expense.fromMap(Map<String, dynamic> m) => Expense(
        id: m['id'] as String,
        title: m['title'] as String,
        amount: (m['amount'] as num).toDouble(),
        category: m['category'] as String,
        date: DateTime.parse(m['date'] as String),
        note: (m['note'] as String?) ?? '',
      );
}
