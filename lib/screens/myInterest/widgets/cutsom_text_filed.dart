import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CutsomTextFiled extends StatelessWidget {
  String? hint;

  String? value;

  Function(String)? onSubmitted;

  TextEditingController controller = TextEditingController();

  CutsomTextFiled({this.hint, this.onSubmitted, this.value});

  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      controller.text = value!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          hint ?? "",
          style: TextStyle(color: Colors.pink, fontSize: 16),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          height: 120,
          child: TextField(
            focusNode: focusNode,
            expands: true,
            maxLines: null,
            minLines: null,
            controller: controller,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
            onSubmitted: (value) {
              onSubmitted?.call(value);
              focusNode.unfocus();
            },
            onEditingComplete: () {
              onSubmitted?.call(controller.text);

              focusNode.unfocus();
            },
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
