import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gotime/main.dart';

void main() {
  setUpAll(() {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  });

  testWidgets('GoTimeApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GoTimeApp());
    expect(find.byType(GoTimeApp), findsOneWidget);
  });
}
