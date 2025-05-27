


import 'package:flutter/material.dart';

class BookEntity {
  final int id;
  final String? title;
  final String? titleAr;
  final int? numberOfHadis;
  final String? abvrCode;
  final String? bookName;
  final String? bookDescr;
  final String? colorCode;  
  
  BookEntity({
    required this.id,
    this.title = '',
    this.titleAr = '',
    this.numberOfHadis = 0,
    this.abvrCode = '',
    this.bookName = '',
    this.bookDescr = '',
    this.colorCode = '',  
  });
  
  factory BookEntity.fromDb(Map<String, dynamic> data) {
    return BookEntity(
      id: data['id'] as int,
      title: data['title'] as String? ?? '',
      titleAr: data['title_ar'] as String? ?? '',
      numberOfHadis: data['number_of_hadis'] as int? ?? 0,
      abvrCode: data['abvr_code'] as String? ?? '',
      bookName: data['book_name'] as String? ?? '',
      bookDescr: data['book_descr'] as String? ?? '',
      colorCode: data['color_code']?.toString() ?? '',  // Convert to String
    );
  }
  
  // Helper method to convert hex color to Color
  Color get color {
    try {
      if (colorCode == null || colorCode!.isEmpty) return Colors.teal;
      if (!colorCode!.startsWith('#')) return Colors.teal;
      
      return Color(int.parse('FF${colorCode!.substring(1)}', radix: 16));
    } catch (e) {
      return Colors.teal; // Default color
    }
  }
}

