import 'package:hadith/domain/entities/book_entity.dart';
import 'package:hadith/domain/entities/chapter_entity.dart';
import 'package:hadith/domain/entities/hadith_entity.dart';
import 'package:hadith/domain/repositories/hadith_repository.dart';

/// A fallback repository that returns empty data when the database initialization fails
class EmptyHadithRepository implements HadithRepository {
  @override
  Future<List<BookEntity>> getAllBooks() async {
    print('📝 EmptyHadithRepository: Returning empty book list');
    return [
      BookEntity(
        id: 1,
        title: 'Sample Book',
        titleAr: 'كتاب عينة',
        numberOfHadis: 1,
        abvrCode: 'Sample',
        bookName: 'Sample',
        bookDescr: 'Sample',
        colorCode: 0xFF009688
      )
    ];
  }

  @override
  Future<List<ChapterEntity>> getChaptersByBookId(int bookId) async {
    print('📝 EmptyHadithRepository: Returning empty chapter list');
    return [
      ChapterEntity(
        id: 1,
        chapterId: 1,
        bookId: bookId,
        title: 'Sample Chapter',
        number: 1,
        hadisRange: '1-1',
        bookName: 'Sample',
      )
    ];
  }

  @override
  Future<List<HadithEntity>> getHadithsByChapterId(int chapterId) async {
    print('📝 EmptyHadithRepository: Returning empty hadith list');
    return [
      HadithEntity(
        id: 1,
        bookId: 1,
        chapterId: 1,
        narrator: 'Sample Narrator',
        grade: 'Sample',
        bookName: 'Sample',
        ar: 'هذا محتوى حديث عينة لأغراض الاختبار عندما تكون قاعدة البيانات غير متوفرة',
        arDiacless: 'هذا محتوى حديث عينة لأغراض الاختبار عندما تكون قاعدة البيانات غير متوفرة',
        bn: 'This is a sample hadith content for testing purposes when the database is not available.',
       
      )
    ];
  }

  @override
  Future<HadithEntity?> getHadithById(int hadithId) async {
    print('📝 EmptyHadithRepository: Returning sample hadith');
    return HadithEntity(
      id: 1,
      bookId: 1,
      chapterId: 1,
      narrator: 'Sample Narrator',
      grade: 'Sample',
      bookName: 'Sample',
      ar: 'هذا محتوى حديث عينة لأغراض الاختبار عندما تكون قاعدة البيانات غير متوفرة',
      arDiacless: 'هذا محتوى حديث عينة لأغراض الاختبار عندما تكون قاعدة البيانات غير متوفرة',
      bn: 'This is a sample hadith content for testing purposes when the database is not available.',
    );
  }

  @override
  Future<bool> verifyDatabaseConnection() async {
    print('📝 EmptyHadithRepository: Database connection verification (always returns false)');
    return false;
  }

  @override
  Future<bool> bookExists(int bookId) async {
    print('📝 EmptyHadithRepository: Book exists check (always returns true for bookId=1)');
    return bookId == 1;
  }

  @override
  Future<bool> chapterExists(int chapterId) async {
    print('📝 EmptyHadithRepository: Chapter exists check (always returns true for chapterId=1)');
    return chapterId == 1;
  }

  @override
  Future<Map<String, dynamic>> getDatabaseStats() async {
    print('📝 EmptyHadithRepository: Getting database stats');
    return {
      'connected': false,
      'bookCount': 1,
      'chapterCount': 1,
      'hadithCount': 1,
      'usingEmptyRepository': true
    };
  }

  @override
  Future<Map<String, dynamic>> getSampleData() async {
    print('📝 EmptyHadithRepository: Getting sample data');
    return {
      'books': [
        BookEntity(
          id: 1,
          title: 'Sample Book',
          titleAr: 'كتاب عينة',
          numberOfHadis: 1,
          abvrCode: 'Sample',
          bookName: 'Sample',
          bookDescr: 'Sample',
          colorCode: 0xFF009688
        )
      ],
      'chapters': [
        ChapterEntity(
          id: 1,
          chapterId: 1,
          bookId: 1,
          title: 'Sample Chapter',
          number: 1,
          hadisRange: '1-1',
          bookName: 'Sample',
        )
      ],
      'hadiths': [
        HadithEntity(
          id: 1,
          bookId: 1,
          chapterId: 1,
          narrator: 'Sample Narrator',
          grade: 'Sample',
          bookName: 'Sample',
          ar: 'هذا محتوى حديث عينة لأغراض الاختبار عندما تكون قاعدة البيانات غير متوفرة',
          arDiacless: 'هذا محتوى حديث عينة لأغراض الاختبار عندما تكون قاعدة البيانات غير متوفرة',
          bn: 'This is a sample hadith content for testing purposes when the database is not available.',
        )
      ]
    };
  }

  @override
  Future<bool> checkDatabaseSchema() async {
    print('📝 EmptyHadithRepository: Database schema check (always returns false)');
    return false;
  }
}