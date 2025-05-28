import 'package:drift/drift.dart';

class HadithEntity {
  final int id;
  final int bookId;
  final String? bookName;
  final int chapterId;
  final int? sectionId;
  final String? hadithKey;
  final int? hadithId;
  final String? narrator;
  final String? bn;          
  final String? ar;         
  final String? arDiacless;  
  final String? note;
  final int? gradeId;
  final String? grade;
  final String? gradeColor;
  
  HadithEntity({
    required this.id,
    required this.bookId,
    this.bookName = '',
    required this.chapterId,
    this.sectionId = 0,
    this.hadithKey = '',
    this.hadithId = 0,
    this.narrator = '',
    this.bn = '',
    this.ar = '',
    this.arDiacless = '',
    this.note = '',
    this.gradeId = 0,
    this.grade = '',
    this.gradeColor = '',
  });
  
  factory HadithEntity.fromDb(Map<String, dynamic> data) {
    return HadithEntity(
      id: data['id'] as int,
      bookId: data['book_id'] as int,
      bookName: data['book_name'] as String? ?? '',
      chapterId: data['chapter_id'] as int,
      sectionId: data['section_id'] as int? ?? 0,
      hadithKey: data['hadith_key'] as String? ?? '',
      hadithId: data['hadith_id'] as int? ?? 0,
      narrator: data['narrator'] as String? ?? '',
      bn: data['bn'] as String? ?? '',
      ar: data['ar'] as String? ?? '',
      arDiacless: data['ar_diacless'] as String? ?? '',
      note: data['note'] as String? ?? '',
      gradeId: data['grade_id'] as int? ?? 0,
      grade: data['grade'] as String? ?? '',
      gradeColor: data['grade_color'] as String? ?? '',
    );
  }
}

// Drift table definition
class Hadiths extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().named('book_id')();
  TextColumn get bookName => text().named('book_name').nullable()();
  IntColumn get chapterId => integer().named('chapter_id')();
  IntColumn get sectionId => integer().named('section_id').nullable()();
  TextColumn get hadithKey => text().named('hadith_key').nullable()();
  IntColumn get hadithId => integer().named('hadith_id').nullable()(); 
  TextColumn get narrator => text().nullable()();
  TextColumn get bn => text().nullable()();
  TextColumn get ar => text().nullable()();
  TextColumn get arDiacless => text().named('ar_diacless').nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get gradeId => integer().named('grade_id').nullable()();
  TextColumn get grade => text().nullable()();
  TextColumn get gradeColor => text().named('grade_color').nullable()();
}