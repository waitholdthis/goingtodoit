import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:goingtodoit_app/main.dart';

void main() {
  testWidgets('Task list shows empty state and add button', (tester) async {
    await tester.pumpWidget(const GoingToDoItApp());

    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('No tasks yet. Tap + to add one.'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Tapping add opens the task creation screen', (tester) async {
    await tester.pumpWidget(const GoingToDoItApp());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('Save Task'), findsOneWidget);
  });
}
