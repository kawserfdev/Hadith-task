

import 'package:drift/drift.dart';

class BookEntity {
  final int id;
  final String? title;
  final String? titleAr;
  final int? numberOfHadis;
  final String? abvrCode;
  final String? bookName;
  final String? bookDescr;
  final int? colorCode;
  
  BookEntity({
    required this.id,
    this.title = '',
    this.titleAr = '',
    this.numberOfHadis = 0,
    this.abvrCode = '',
    this.bookName = '',
    this.bookDescr = '',
    this.colorCode = 0,
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
      colorCode: data['color_code'] as int? ?? 0,
    );
  }
}


class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().nullable()();
  TextColumn get titleAr => text().named('title_ar').nullable()();
  IntColumn get numberOfHadis => integer().named('number_of_hadis').nullable()();
  TextColumn get abvrCode => text().named('abvr_code').nullable()();
  TextColumn get bookName => text().named('book_name').nullable()();
  TextColumn get bookDescr => text().named('book_descr').nullable()();
  IntColumn get colorCode => integer().named('color_code').nullable()();
}