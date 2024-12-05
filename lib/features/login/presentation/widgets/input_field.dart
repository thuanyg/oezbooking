import 'package:flutter/material.dart';
import 'package:oezbooking/core/apps/app_styles.dart';
import 'package:oezbooking/core/utils/image_helper.dart';

class CustomInputField extends StatefulWidget {
  CustomInputField(
      {super.key,
      required this.label,
      this.obscureText = false,
      this.prefixIconName,
      this.controller,
      this.validator});

  String? label;
  bool obscureText = false;
  String? prefixIconName;
  FormFieldValidator<String>? validator;
  TextEditingController? controller;

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool isPasswordShowed = false;
  late final bool obscureText;

  @override
  void initState() {
    super.initState();
    obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: widget.obscureText,
      cursorErrorColor: Colors.red,
      style: const TextStyle(color: Colors.white70),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        prefixIcon: widget.prefixIconName != null
            ? ImageHelper.loadAssetImage(
                "assets/images/${widget.prefixIconName!}",
                height: 14,
                tintColor: Colors.white54,
              )
            : null,
        suffixIcon: obscureText
            ? IconButton(
                icon: isPasswordShowed
                    ? const Icon(
                        Icons.visibility_off_outlined,
                        color: Colors.white54,
                      )
                    : const Icon(
                        Icons.visibility_outlined,
                        color: Colors.white54,
                      ),
                onPressed: () {
                  setState(() {
                    if (isPasswordShowed) {
                      isPasswordShowed = false;
                      widget.obscureText = true;
                    } else {
                      widget.obscureText = false;
                      isPasswordShowed = true;
                    }
                  });
                },
              )
            : const SizedBox.shrink(),
        label: Text(
          widget.label!,
          style: AppStyle.boxFieldLabel.copyWith(color: Colors.white70),
        ),
      ),
    );
  }
}
