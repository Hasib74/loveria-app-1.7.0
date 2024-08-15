/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../widgets/custom_selector_widget.dart';

class BasicInfo extends StatelessWidget {
  const BasicInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomSelectorWidget(
              label: "Age Range",
              type: CustomSelectorType.range,
              onSelectedAge: (value) {
                print("Selected Age: $value");
              },
            ),
            SizedBox(
              height: 32,
            ),
            CustomSelectorWidget(
              label: "Select Body",
              type: CustomSelectorType.multiple,
              onSelectedMultiple: (value) {
                print("Selected Body: $value");
              },
            ),
            SizedBox(
              height: 32,
            ),
            CustomSelectorWidget(
              label: "Salary Range",
              type: CustomSelectorType.range,
              onSelectedAge: (value) {
                print("Selected Age: $value");
              },
            ),
            SizedBox(
              height: 32,
            ),
            CustomSelectorWidget(
              label: "Job Nature",
              type: CustomSelectorType.multiple,
              values: ["Job", "Business", "Student"],
              onSelectedMultiple: (value) {
                print("Selected Job Nature: $value");
              },
            ),
          ],
        ),
      ),
    );
  }
}
*/
