import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momo_baby_healthcare_flutter/screens/information/widget/baby_info/newborn_profile_card.dart';

void main() {
  testWidgets('hồ sơ bé để trống và báo đúng giá trị mẹ nhập', (tester) async {
    String? name;
    double? weight;
    double? height;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NewbornProfileCard(
              onProfileChanged: (n, w, h, _) {
                name = n;
                weight = w;
                height = h;
              },
            ),
          ),
        ),
      ),
    );

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields, hasLength(3));
    for (final field in fields) {
      expect(field.controller!.text, isEmpty);
    }

    await tester.enterText(find.byType(TextField).at(0), ' Bé Na ');
    await tester.enterText(find.byType(TextField).at(1), '3,2');
    await tester.enterText(find.byType(TextField).at(2), '49');

    expect(name, 'Bé Na');
    expect(weight, 3.2);
    expect(height, 49);
  });
}
