import 'package:hadith/domain/entities/book_entity.dart';
import 'package:hadith/domain/entities/chapter_entity.dart';
import 'package:hadith/domain/entities/hadith_entity.dart';

abstract class HadithRepository {
  Future<List<BookEntity>> getAllBooks();
  
  Future<List<ChapterEntity>> getChaptersByBookId(int bookId);
  
  Future<List<HadithEntity>> getHadithsByChapterId(int chapterId);
  
  Future<HadithEntity?> getHadithById(int hadithId);
  
  Future<bool> verifyDatabaseConnection();
  
  Future<bool> bookExists(int bookId);
  
  Future<bool> chapterExists(int chapterId);
  
  Future<Map<String, dynamic>> getDatabaseStats();
  
  Future<bool> createSampleChapters(int bookId);
  
}


