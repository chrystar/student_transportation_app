import 'package:flutter/material.dart';
import 'app_colors.dart';

Widget appTextField({
  TextEditingController? controller,
  String iconName = "",
  String hintText = "type in your info",
  bool obscureText = false,
  void Function(String value)? func,
  FormFieldValidator? validate,
  IconButton? suffixIcon,
}) {
  return TextFormField(
    onChanged: func,
    controller: controller,
    decoration: InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      hintStyle: const TextStyle(
        fontSize: 14,
        color: AppColor.primarySecondaryElementText,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.grey, width: 1.5,),
      ),
      focusColor: Color(0xffEC441E),
      filled: false,
    ),

    validator: validate,
    autocorrect: false,
    maxLines: 1,
    obscureText: obscureText,
  );
}
