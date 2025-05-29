import 'package:hadith/data/datasources/local/drift/database.dart';
import 'package:hadith/domain/entities/book_entity.dart';
import 'package:hadith/domain/entities/chapter_entity.dart';
import 'package:hadith/domain/entities/hadith_entity.dart';
import 'package:hadith/domain/hadith_repository.dart';

class HadithRepositoryImpl implements HadithRepository {
  final AppDatabase? database;
  
  HadithRepositoryImpl(this.database);

  @override
  Future<List<BookEntity>> getAllBooks() async {
    if (database == null) return [];
    
    try {
      final books = await database!.getAllBooks();      
      return books.map((book) => BookEntity(
        id: book.id,
        title: book.title ?? '',
        titleAr: book.titleAr ?? '',
        numberOfHadis: book.numberOfHadis ?? 0,
        abvrCode: book.abvrCode ?? '',
        bookName: book.bookName ?? '',
        bookDescr: book.bookDescr ?? '',
        colorCode: book.colorCode ?? '',
      )).toList();
    } catch (e) {
      print(' Repository: Error in getAllBooks: $e');
      return [];
    }
  }

  @override
  Future<List<ChapterEntity>> getChaptersByBookId(int bookId) async {
    if (database == null) return [];
    
    try {
      final chapters = await database!.getChaptersByBookId(bookId);
      print(' Repository: Retrieved ${chapters.length} chapters for book $bookId');
      
      return chapters.map((chapter) => ChapterEntity(
        id: chapter.id,
        chapterId: chapter.chapterId,
        bookId: chapter.bookId,
        title: chapter.title ?? '',
        number: chapter.number ?? 0,
        hadisRange: chapter.hadisRange ?? '',
        bookName: chapter.bookName ?? '',
      )).toList();
    } catch (e) {
      print(' Repository: Error in getChaptersByBookId: $e');
      return [];
    }
  }

  @override
  Future<List<HadithEntity>> getHadithsByChapterId(int chapterId) async {
    if (database == null) return [];
    
    try {
      final hadiths = await database!.getHadithsByChapterId(chapterId);
      print(' Repository: Retrieved ${hadiths.length} hadiths for chapter $chapterId');
      
      return hadiths.map((hadith) => HadithEntity(
        id: hadith.id,
        bookId: hadith.bookId,
        bookName: hadith.bookName ?? '',
        chapterId: hadith.chapterId,
        sectionId: hadith.sectionId,
        hadithKey: hadith.hadithKey ?? '',
        hadithId: hadith.hadithId ?? 0,
        narrator: hadith.narrator ?? '',
        bn: hadith.bn ?? '',
        ar: hadith.ar ?? '',
        arDiacless: hadith.arDiacless ?? '',
        note: hadith.note ?? '',
        gradeId: hadith.gradeId ?? 0,
        grade: hadith.grade ?? '',
        gradeColor: hadith.gradeColor ?? '',
      )).toList();
    } catch (e) {
      print(' Repository: Error in getHadithsByChapterId: $e');
      return [];
    }
  }
  @override
Future<HadithEntity?> getHadithById(int hadithId) async {
  if (database == null) return null;
  
  try {
    final hadith = await database!.getHadithById(hadithId);
    
    if (hadith == null) {
      return null;
    }
        
    return HadithEntity(
      id: hadith.id,
      bookId: hadith.bookId,
      bookName: hadith.bookName ?? '',
      chapterId: hadith.chapterId,
      sectionId: hadith.sectionId,
      hadithKey: hadith.hadithKey ?? '',
      hadithId: hadith.hadithId ?? 0,
      narrator: hadith.narrator ?? '',
      bn: hadith.bn ?? '',
      ar: hadith.ar ?? '',
      arDiacless: hadith.arDiacless ?? '',
      note: hadith.note ?? '',
      gradeId: hadith.gradeId ?? 0,
      grade: hadith.grade ?? '',
      gradeColor: hadith.gradeColor ?? '',
    );
  } catch (e) {
    print(' Repository: Error in getHadithById: $e');
    return null;
  }
}
  @override
  Future<bool> verifyDatabaseConnection() async {
    if (database == null) {
      print(' Repository: Database is null');
      return false;
    }
    
    try {
      final isValid = await database!.verifyConnection();
      print(isValid 
        ? ' Repository: Database connection verified' 
        : ' Repository: Database connection failed');
      return isValid;
    } catch (e) {
      print(' Repository: Error verifying database connection: $e');
      return false;
    }
  }
  
  @override
  Future<bool> bookExists(int bookId) async {
    if (database == null) return false;
    
    try {
      final book = await database!.getBookById(bookId);
      return book != null;
    } catch (e) {
      print(' Repository: Error checking if book exists: $e');
      return false;
    }
  }
  
  @override
  Future<bool> chapterExists(int chapterId) async {
    if (database == null) return false;
    
    try {
      final chapter = await database!.getChapterById(chapterId);
      return chapter != null;
    } catch (e) {
      print(' Repository: Error checking if chapter exists: $e');
      return false;
    }
  }
  
  @override
  Future<Map<String, dynamic>> getDatabaseStats() async {
    final stats = <String, dynamic>{
      'connected': false,
      'bookCount': 0,
      'chapterCount': 0,
      'hadithCount': 0,
    };
    
    if (database == null) {
      return stats;
    }
    
    try {
      
      // Get book count
      try {
        final bookCount = await database!.getBookCount();
        stats['bookCount'] = bookCount;
        stats['connected'] = true;
        print(' Repository: Found $bookCount books');
      } catch (e) {
        print(' Repository: Error getting book count: $e');
      }
      
      // Get chapter count
      try {
        final chapterCount = await database!.getChapterCount();
        stats['chapterCount'] = chapterCount;
        print(' Repository: Found $chapterCount chapters');
      } catch (e) {
        print(' Repository: Error getting chapter count: $e');
      }
      
      // Get hadith count
      try {
        final hadithCount = await database!.getHadithCount();
        stats['hadithCount'] = hadithCount;
        print(' Repository: Found $hadithCount hadiths');
      } catch (e) {
        print(' Repository: Error getting hadith count: $e');
      }
      
      return stats;
    } catch (e) {
      print(' Repository: Error getting database stats: $e');
      return stats;
    }
  }
  
  @override
  Future<bool> createSampleChapters(int bookId) async {
    return true;
  }

}
