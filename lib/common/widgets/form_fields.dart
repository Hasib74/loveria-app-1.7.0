import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loveria/common/language/language_extension.dart';
import '../services/utils.dart';

class InputField extends StatelessWidget {
  final String? placeholder;
  final String? labelText;
  final String? helperText;
  final String? initialValue;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final void Function()? onTap;
  final void Function(String? text)? onChanged;
  final TextEditingController? controller;
  final bool autofocus;
  final bool password;
  final bool readOnly;
  final void Function(String? text)? onSaved;
  final String? Function(String? value)? validation;

  // final Function? onChanged;
  final Color? borderColor;
  final TextInputType? inputType;
  final int? maxLines;

  const InputField(
      {Key? key,
      this.placeholder = '',
      this.labelText = '',
      this.helperText = '',
      this.suffixIcon,
      this.initialValue,
      this.prefixIcon,
      this.onSaved,
      this.onTap,
      this.inputType = TextInputType.text,
      // required this.onTap,
      this.onChanged,
      this.validation,
      this.maxLines,
      this.autofocus = false,
      this.password = false,
      this.readOnly = false,
      this.borderColor, // = app_theme.border,
      this.controller,
      obscureText = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 0),
      child: TextFormField(
        readOnly: readOnly,
        initialValue: controller == null ? initialValue : null,
        // The validator receives the text that the user has entered.
        validator: validation,
        keyboardType: inputType,
        maxLines: password ? 1 : maxLines,
        // is masked as password
        obscureText: password,
        // cursorColor: app_theme.muted,
        onSaved: onSaved,
        onTap: onTap,
        onChanged: onChanged,
        controller: controller,
        autofocus: autofocus,
        style: const TextStyle(
          height: 1.4,
          fontSize: 18.0,
        ),
        textAlignVertical: const TextAlignVertical(y: 0.6),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            height: 1,
            fontSize: 18.0,
          ),
          helperText: helperText,
          hintStyle: const TextStyle(
              // color: app_theme.muted,
              ),
          errorStyle: const TextStyle(
            fontSize: 14,
          ),
          suffixIcon: (suffixIcon != null)
              ? Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20),
                  child: suffixIcon,
                )
              : null,
          prefixIcon: (prefixIcon != null)
              ? Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20),
                  child: prefixIcon,
                )
              : null,
          hintText: helperText,
        ),
      ),
    );
  }
}

class SelectField extends StatelessWidget {
  final String labelText;
  final void Function(String? text)? onChanged;
  final void Function(String? text)? onSaved;
  final dynamic listItems;
  final bool autofocus;
  final bool showOptionKeyInBracket;
  final String optionKeyName;
  final String optionLabelName;
  String? value;
  final String? Function(String? value)? validation;

  SelectField({
    Key? key,
    this.labelText = '',
    this.onChanged,
    this.onSaved,
    this.listItems,
    this.validation,
    this.autofocus = false,
    this.value,
    this.optionKeyName = 'id',
    this.optionLabelName = 'value',
    this.showOptionKeyInBracket = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if ((value == '') || (value == 'null')) {
      value = null;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DropdownButtonFormField<String>(
        // key: dropdownState,
        decoration: InputDecoration(
          labelText: labelText,
        ),
        isExpanded: true,
        value: value,
        icon: const Icon(
          CupertinoIcons.chevron_down,
          size: 18,
        ),
        onChanged: (selectedValue) {
          value = selectedValue;
          if (onChanged != null) {
            onChanged!(selectedValue);
          }
        },
        onSaved: (selectedValue) {
          value = selectedValue;
          if (onSaved != null) {
            onSaved!(selectedValue);
          }
        },
        items: _buildSelectOptions(
          listItems,
          title: labelText,
          keyName: optionKeyName,
          valueName: optionLabelName,
          showKeyInBracket: showOptionKeyInBracket,
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildSelectOptions(
    selectOptions, {
    title = '',
    keyName = 'id',
    valueName = 'value',
    showKeyInBracket = false,
  }) {
    Map processedOptions = {};
    if (selectOptions is List) {
      processedOptions = {
        for (var selectOption in selectOptions)
          if (selectOption is Map)
            selectOption[keyName].toString():
                selectOption[valueName].toString() +
                    ((showKeyInBracket == true &&
                            selectOption[keyName].toString() != '')
                        ? " (${selectOption[keyName].toString()})"
                        : '')
          else
            selectOption.toString(): selectOption.toString()
      };
    } else {
      processedOptions = selectOptions;
    }
    List<DropdownMenuItem<String>>? newItems = [
      DropdownMenuItem(
        enabled: false,
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            color: Color.fromARGB(255, 165, 165, 165),
            fontSize: 20,
          ),
        ),
      ),
      const DropdownMenuItem(
        enabled: false,
        child: Divider(
          thickness: 0.4,
          color: Color.fromARGB(255, 165, 165, 165),
        ),
      )
    ];
    processedOptions.forEach((index, value) {
      newItems.add(DropdownMenuItem(
        value: index.toString(),
        child: Text(value.toString().toTranslated()),
      ));
    });
    return newItems;
  }
}

class DateTimeInputPicker extends StatefulWidget {
  final String? placeholder;
  final String? labelText;
  final String? helperText;
  final String initialValue;
  final String minimumDate;
  final String maximumDate;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final void Function()? onTap;
  final void Function(String? text)? onChanged;
  final void Function(String? text)? onSaved;
  final String? Function(String? value)? validation;

  const DateTimeInputPicker({
    Key? key,
    this.placeholder = '',
    this.labelText = '',
    this.helperText = '',
    this.suffixIcon,
    this.initialValue = '',
    this.minimumDate = '',
    this.maximumDate = '',
    this.prefixIcon,
    this.onSaved,
    this.onTap,
    this.onChanged,
    this.validation,
  }) : super(key: key);

  @override
  State<DateTimeInputPicker> createState() => _DateTimeInputPickerState();
}

class _DateTimeInputPickerState extends State<DateTimeInputPicker> {
  TextEditingController dateInput = TextEditingController();

  DateTime minimumAllowedDOB = DateTime.now();
  DateTime maximumAllowedDOB = DateTime.now();
  DateTime userInputDOB = DateTime.now().subtract(const Duration(days: 1));

  @override
  void initState() {
    dateInput.text = widget.initialValue; //set the initial value of text field
    super.initState();
    minimumAllowedDOB = DateTime.tryParse(widget.minimumDate.toString()) ??
        DateTime.now().subtract(
          const Duration(days: 1),
        );
    maximumAllowedDOB = DateTime.tryParse(widget.maximumDate.toString()) ??
        DateTime.now().add(const Duration(days: 1));

    userInputDOB = DateTime.tryParse(dateInput.text) ?? maximumAllowedDOB;

    if ((minimumAllowedDOB.compareTo(userInputDOB) > 0) ||
        (maximumAllowedDOB.compareTo(userInputDOB) < 0)) {
      userInputDOB = maximumAllowedDOB;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputField(
        controller: dateInput,
        readOnly: true,
        labelText: widget.labelText,
        onSaved: widget.onSaved,
        onChanged: widget.onChanged,
        onTap: () async {
          if (isIOSPlatform()) {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext builder) {
                  return SizedBox(
                    height: MediaQuery.of(context).copyWith().size.height / 3,
                    // color: Colors.white,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      onDateTimeChanged: (picked) {
                        if (_formatDate(picked) !=
                            _formatDate(dateInput.text)) {
                          setState(() {
                            dateInput.text = picked.toString();
                            dateInput.text = _formatDate(
                                picked); //set output date to TextField value.
                          });
                        }
                      },
                      initialDateTime: userInputDOB,
                      minimumDate: minimumAllowedDOB,
                      maximumDate: maximumAllowedDOB,
                    ),
                  );
                });
          } else {
            //when click we have to show the datepicker
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: userInputDOB,
              firstDate: minimumAllowedDOB,
              lastDate: maximumAllowedDOB,
            );
            if (_formatDate(pickedDate) != _formatDate(dateInput.text)) {
              setState(() {
                dateInput.text = _formatDate(
                    pickedDate); //set output date to TextField value.
              });
            }
          }

          if (widget.onChanged != null) {
            widget.onChanged!(dateInput.text);
          }
        });
  }

  _formatDate(date) {
    return DateFormat('yyyy-MM-dd')
        .format((date is DateTime ? date : DateTime.tryParse(date)) ??
            DateTime.now())
        .toString();
  }
}
