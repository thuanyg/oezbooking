import 'package:flutter/material.dart';

class AppStyle {
  // Tiêu đề lớn
  static TextStyle heading1 = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Tiêu đề phụ
  static TextStyle heading2 = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Nội dung văn bản bình thường
  static TextStyle bodyText = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  // Văn bản chú thích
  static TextStyle caption = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  // Others
  static TextStyle titleItem = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    fontWeight: FontWeight.w300,
    color: Color(0xff313131),
  );

  static TextStyle subTitleItem = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    fontWeight: FontWeight.w300,
    color: Color(0xff828282),
  );

  static TextStyle appBarTitle = const TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 22,
    color: Color(0xff000000),
  );

  static TextStyle boxFieldLabel = const TextStyle(
    fontFamily: "Poppins",
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xff828282),
  );

  static TextStyle boxField = const TextStyle(
    fontFamily: "Poppins",
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xff828282),
    overflow: TextOverflow.ellipsis,
  );
}
