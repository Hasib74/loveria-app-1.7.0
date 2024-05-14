import 'package:flutter/material.dart';
import 'package:loveria/screens/myInterest/widgets/multi_selected_field.dart';

import 'custom_age_ranger_widget.dart';

enum CustomSelectorType { range, single, multiple }

class CustomSelectorWidget extends StatelessWidget {
  String? label;
  String? min;

  String? max;

  String? unit;

  CustomSelectorType? type;
  Function(RangeValues range)? onSelectedAge;
  Function(List<dynamic> multiSelectedValue)? onSelectedMultiple;

  List<String>? selectedValues = [];

  List<String>? values = [];

  CustomSelectorWidget(
      {super.key,
      this.label,
      this.type,
      this.onSelectedAge,
      this.values,
      this.onSelectedMultiple,
      this.selectedValues,
      this.min,
      this.max,
      this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _view(),
      ],
    );
  }

  _view() {
    print("Selected Values: $selectedValues");
    switch (type) {
      case CustomSelectorType.range:
        return AppRangeSlider(
            label:
                "${label}  ${unit != null && unit!.isNotEmpty ? "($unit)" : ""}",
            minAge: int.parse(min ?? "0"),
            maxAge: int.parse(max ?? "100"),
            onChanged: (value) {
              onSelectedAge?.call(value);
            },
            ageRange: rangeValues(selectedValues, int.parse(min ?? "10"),
                int.parse(max ?? "100")));
      case CustomSelectorType.single:
        return Container();
      case CustomSelectorType.multiple:
        return AppMultiSelectField<String>(
          menus: values ?? [],
          onSelectedMultiple: (value) {
            onSelectedMultiple?.call(value);
          },
          title: label ?? "",
          selectedItems: selectedValues ?? [],
        );
      default:
        return Container();
    }
  }

  RangeValues rangeValues(List<String>? selectedValues, int min, int max) {
    print("Selected Values: $selectedValues");
    print("Min: $min");
    print("Max: $max");
    return RangeValues(
        selectedValues?.length == 2
            ? (double.parse(selectedValues![0]) >= min.toDouble()
                ? double.parse(selectedValues![0])
                : min.toDouble())
            : 60,
        selectedValues?.length == 2
            ? (max.toDouble() >= double.parse(selectedValues![1])
                ? double.parse(selectedValues![1])
                : max.toDouble())
            : 60);
  }
}
