import 'package:drift/drift.dart';

class ChapterEntity {
  final int id;
  final int chapterId;  
  final int bookId;
  final String? title;
  final int? number;    
  final String? hadisRange; 
  final String? bookName;   
  
  ChapterEntity({
    required this.id,
    required this.chapterId,
    required this.bookId,
    this.title = '',
    this.number = 0,
    this.hadisRange = '',
    this.bookName = '',
  });
  
  factory ChapterEntity.fromDb(Map<String, dynamic> data) {
    return ChapterEntity(
      id: data['id'] as int,
      chapterId: data['chapter_id'] as int,
      bookId: data['book_id'] as int,
      title: data['title'] as String? ?? '',
      number: data['number'] as int? ?? 0,
      hadisRange: data['hadis_range'] as String? ?? '',
      bookName: data['book_name'] as String? ?? '',
    );
  }
}

// Drift table definition
class Chapters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chapterId => integer().named('chapter_id')();
  IntColumn get bookId => integer().named('book_id')();
  TextColumn get title => text().nullable()();
  IntColumn get number => integer().named('number').nullable()();
  TextColumn get hadisRange => text().named('hadis_range').nullable()();
  TextColumn get bookName => text().named('book_name').nullable()();
}