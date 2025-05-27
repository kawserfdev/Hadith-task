import 'package:hadith/domain/entities/book_entity.dart';
import 'package:hadith/domain/entities/chapter_entity.dart';
import 'package:hadith/domain/entities/hadith_entity.dart';

abstract class HadithRepository {
  /// Get all books from the database
  Future<List<BookEntity>> getAllBooks();
  
  /// Get chapters for a specific book
  Future<List<ChapterEntity>> getChaptersByBookId(int bookId);
  
  /// Get hadiths for a specific chapter
  Future<List<HadithEntity>> getHadithsByChapterId(int chapterId);
  
  /// Get a specific hadith by ID
  Future<HadithEntity?> getHadithById(int hadithId);
  
  /// Verify if the database connection is working properly
  Future<bool> verifyDatabaseConnection();
  
  /// Check if a book exists with the given ID
  Future<bool> bookExists(int bookId);
  
  /// Check if a chapter exists with the given ID
  Future<bool> chapterExists(int chapterId);
  
  /// Get database statistics for debugging
  Future<Map<String, dynamic>> getDatabaseStats();
  
  /// Get sample data for diagnostics
  Future<Map<String, dynamic>> getSampleData();
  
  /// Check database schema and structure
  Future<bool> checkDatabaseSchema();
  
  /// Create sample chapters for a specific book
  Future<bool> createSampleChapters(int bookId);
  
  /// Debug chapters for a specific book
  Future<void> debugChapters(int bookId);
  
  /// Verify chapters table structure
  Future<void> verifyChaptersTable();
  
  /// Explore all tables in the database
  Future<void> exploreAllTables();
}





// import 'package:hadith/domain/entities/book_entity.dart';
// import 'package:hadith/domain/entities/chapter_entity.dart';
// import 'package:hadith/domain/entities/hadith_entity.dart';

// abstract class HadithRepository {
//   /// Get all books from the database
//   Future<List<BookEntity>> getAllBooks();
  
//   /// Get chapters for a specific book
//   Future<List<ChapterEntity>> getChaptersByBookId(int bookId);
  
//   /// Get hadiths for a specific chapter
//   Future<List<HadithEntity>> getHadithsByChapterId(int chapterId);
  
//   /// Get a specific hadith by ID
//   Future<HadithEntity?> getHadithById(int hadithId);
  
//   /// Check if a book exists with the given ID
//   Future<bool> bookExists(int bookId);
  
//   /// Check if a chapter exists with the given ID
//   Future<bool> chapterExists(int chapterId);
// }