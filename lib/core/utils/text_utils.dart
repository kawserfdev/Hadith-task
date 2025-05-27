
import 'package:flutter/material.dart';
class TextUtils {
  static String formatHadithNumber(int number) {
    return number.toString().padLeft(2, '0');
  }
  
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}



class ColorUtils {
  static Color getHadithGradeColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'sahih':
        return Colors.green;
      case 'hasan':
        return Colors.blue;
      case 'da\'if':
        return Colors.orange;
      case 'maudu':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  static Color getBookColor(int colorCode) {
    // Convert the color code from the database to a Flutter color
    return Color(colorCode);
  }
}