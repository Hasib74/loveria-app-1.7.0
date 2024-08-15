/*
import 'package:flutter/material.dart';

import '../../widgets/custom_selector_widget.dart';

class Professional extends StatelessWidget {
  const Professional({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomSelectorWidget(
              label: "Job Nature",
              type: CustomSelectorType.multiple,
              values: ["Job", "Business", "Student"],
              onSelectedMultiple: (value) {
                print("Selected Job Nature: $value");
              },
            ),
            SizedBox(
              height: 32,
            ),
            CustomSelectorWidget(
              label: "Education",
              type: CustomSelectorType.multiple,
              values: [
                "Primary School",
                "Secondary School",
                "Diploma",
                "Bachelors Degree",
                "Masters Degree",
                "Doctorate Degree"
              ],
              onSelectedMultiple: (value) {
                print("Selected Job Nature: $value");
              },
            ),
            SizedBox(
              height: 32,
            ),
          ],
        ),
      ),
    );
  }
}
*/
