import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class AppMultiSelectField<T> extends StatelessWidget {
  String? title;

  Function(List multiSelectedValue)? onSelectedMultiple;

  List<String> selectedItems = [];

  List menus = [];

  AppMultiSelectField(
      {super.key,
      this.onSelectedMultiple,
      required this.menus,
      required this.title,
      required this.selectedItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: MultiSelectDialogField(
        title: Text(title ?? ""),
        buttonText: Text(title ?? ""),
        itemsTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
        selectedColor: Theme.of(context).primaryColor,
        selectedItemsTextStyle:
            TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
        items: menus.map((e) => MultiSelectItem(e, e.toString())).toList(),
        chipDisplay: MultiSelectChipDisplay(),
        onConfirm: (results) {
          onSelectedMultiple?.call(results);
        },
        initialValue: selectedItems.map((e) => e).toList(),
      ),
    );
  }
}
