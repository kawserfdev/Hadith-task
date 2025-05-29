import 'package:hadith/domain/entities/book_entity.dart';
import 'package:hadith/domain/entities/chapter_entity.dart';
import 'package:hadith/domain/entities/hadith_entity.dart';
import 'package:hadith/domain/hadith_repository.dart';

class EmptyHadithRepository implements HadithRepository {
  @override
  Future<List<BookEntity>> getAllBooks() async {
    print(' Empty repository: getAllBooks called');
    return [];
  }
  
  @override
  Future<List<ChapterEntity>> getChaptersByBookId(int bookId) async {
    print(' Empty repository: getChaptersByBookId called with bookId=$bookId');
    return [];
  }
  
  @override
  Future<List<HadithEntity>> getHadithsByChapterId(int chapterId) async {
    print(' Empty repository: getHadithsByChapterId called with chapterId=$chapterId');
    return [];
  }
  
  @override
  Future<HadithEntity?> getHadithById(int hadithId) async {
    print(' Empty repository: getHadithById called with hadithId=$hadithId');
    return null;
  }
  
  @override
  Future<bool> verifyDatabaseConnection() async {
    print(' Empty repository: verifyDatabaseConnection called');
    return false;
  }
  
  @override
  Future<bool> bookExists(int bookId) async {
    print(' Empty repository: bookExists called with bookId=$bookId');
    return false;
  }
  
  @override
  Future<bool> chapterExists(int chapterId) async {
    print(' Empty repository: chapterExists called with chapterId=$chapterId');
    return false;
  }
  
  @override
  Future<Map<String, dynamic>> getDatabaseStats() async {
    print(' Empty repository: getDatabaseStats called');
    return {
      'connected': false,
      'bookCount': 0,
      'chapterCount': 0,
      'hadithCount': 0,
    };
  }

  @override
  Future<bool> createSampleChapters(int bookId) async {
    print(' Empty repository: createSampleChapters called with bookId=$bookId');
    return false;
  }

}