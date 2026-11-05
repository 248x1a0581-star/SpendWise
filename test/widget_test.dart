import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/models/expense.dart';

void main() {
  test('Expense survives a toMap/fromMap round trip', () {
    final original = Expense(
      id: '1',
      title: 'Lunch',
      amount: 120.5,
      category: 'Food',
      date: DateTime(2026, 11, 5),
      note: 'Canteen',
    );

    final copy = Expense.fromMap(original.toMap());

    expect(copy.id, original.id);
    expect(copy.title, original.title);
    expect(copy.amount, original.amount);
    expect(copy.category, original.category);
    expect(copy.date, original.date);
    expect(copy.note, original.note);
  });
}
