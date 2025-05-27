import 'package:hadith/data/datasources/local/drift/database.dart';
import 'package:hadith/domain/entities/book_entity.dart';
import 'package:hadith/domain/entities/chapter_entity.dart';
import 'package:hadith/domain/entities/hadith_entity.dart';
import 'package:hadith/domain/repositories/hadith_repository.dart';

class HadithRepositoryImpl implements HadithRepository {
  final AppDatabase? database;
  
  HadithRepositoryImpl(this.database);

  @override
  Future<List<BookEntity>> getAllBooks() async {
    if (database == null) return [];
    
    try {
      print('📚 Repository: Getting all books...');
      final books = await database!.getAllBooks();
      print('✅ Repository: Retrieved ${books.length} books');
      
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
      print('❌ Repository: Error in getAllBooks: $e');
      return [];
    }
  }

  @override
  Future<List<ChapterEntity>> getChaptersByBookId(int bookId) async {
    if (database == null) return [];
    
    try {
      print('📚 Repository: Getting chapters for book $bookId...');
      final chapters = await database!.getChaptersByBookId(bookId);
      print('✅ Repository: Retrieved ${chapters.length} chapters for book $bookId');
      
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
      print('❌ Repository: Error in getChaptersByBookId: $e');
      return [];
    }
  }

  @override
  Future<List<HadithEntity>> getHadithsByChapterId(int chapterId) async {
    if (database == null) return [];
    
    try {
      print('📚 Repository: Getting hadiths for chapter $chapterId...');
      final hadiths = await database!.getHadithsByChapterId(chapterId);
      print('✅ Repository: Retrieved ${hadiths.length} hadiths for chapter $chapterId');
      
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
      print('❌ Repository: Error in getHadithsByChapterId: $e');
      return [];
    }
  }
  @override
Future<HadithEntity?> getHadithById(int hadithId) async {
  if (database == null) return null;
  
  try {
    print('📚 Repository: Getting hadith with ID $hadithId...');
    final hadith = await database!.getHadithById(hadithId);
    
    if (hadith == null) {
      print('⚠️ Repository: Hadith with ID $hadithId not found');
      return null;
    }
    
    print('✅ Repository: Retrieved hadith with ID $hadithId');
    
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
    print('❌ Repository: Error in getHadithById: $e');
    return null;
  }
}
  @override
  Future<bool> verifyDatabaseConnection() async {
    if (database == null) {
      print('⚠️ Repository: Database is null');
      return false;
    }
    
    try {
      print('🔍 Repository: Verifying database connection...');
      final isValid = await database!.verifyConnection();
      print(isValid 
        ? '✅ Repository: Database connection verified' 
        : '❌ Repository: Database connection failed');
      return isValid;
    } catch (e) {
      print('❌ Repository: Error verifying database connection: $e');
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
      print('❌ Repository: Error checking if book exists: $e');
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
      print('❌ Repository: Error checking if chapter exists: $e');
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
      print('📊 Repository: Getting database statistics...');
      
      // Get book count
      try {
        final bookCount = await database!.getBookCount();
        stats['bookCount'] = bookCount;
        stats['connected'] = true;
        print('📚 Repository: Found $bookCount books');
      } catch (e) {
        print('❌ Repository: Error getting book count: $e');
      }
      
      // Get chapter count
      try {
        final chapterCount = await database!.getChapterCount();
        stats['chapterCount'] = chapterCount;
        print('📚 Repository: Found $chapterCount chapters');
      } catch (e) {
        print('❌ Repository: Error getting chapter count: $e');
      }
      
      // Get hadith count
      try {
        final hadithCount = await database!.getHadithCount();
        stats['hadithCount'] = hadithCount;
        print('📚 Repository: Found $hadithCount hadiths');
      } catch (e) {
        print('❌ Repository: Error getting hadith count: $e');
      }
      
      return stats;
    } catch (e) {
      print('❌ Repository: Error getting database stats: $e');
      return stats;
    }
  }
  
  @override
  Future<Map<String, dynamic>> getSampleData() async {
    final sample = <String, dynamic>{
      'books': <BookEntity>[],
      'chapters': <ChapterEntity>[],
      'hadiths': <HadithEntity>[],
    };
    
    if (database == null) {
      return sample;
    }
    
    try {
      print('📊 Repository: Getting sample data...');
      
      // Get sample books (not creating, just fetching existing ones)
      final books = await database!.getSampleBooks();
      sample['books'] = books.map((book) => BookEntity(
        id: book.id,
        title: book.title ?? '',
        titleAr: book.titleAr ?? '',
        numberOfHadis: book.numberOfHadis ?? 0,
        abvrCode: book.abvrCode ?? '',
        bookName: book.bookName ?? '',
        bookDescr: book.bookDescr ?? '',
        colorCode: book.colorCode ?? ''
      )).toList();
      
      // If we have books, get some chapters from the first book
      if (books.isNotEmpty) {
        final chapters = await database!.getSampleChaptersForBook(books.first.id);
        sample['chapter'] = chapters.map((chapter) => ChapterEntity(
          id: chapter.id,
          bookId: chapter.bookId,
          chapterId: chapter.chapterId,
          title: chapter.title ?? '',
          number: chapter.number ?? 0,
          hadisRange: chapter.hadisRange ?? '',
          bookName: chapter.bookName ?? '',
        )).toList();
        
        // If we have chapters, get some hadiths from the first chapter
        if (chapters.isNotEmpty) {
          final hadiths = await database!.getSampleHadithsForChapter(chapters.first.id);
          sample['hadith'] = hadiths.map((hadith) => HadithEntity(
            id: hadith.id,
            chapterId: hadith.chapterId,
            hadithId: hadith.hadithId,
            hadithKey: hadith.hadithKey ?? '',
            narrator: hadith.narrator ?? '',
            bn: hadith.bn ?? '',
            ar: hadith.ar ?? '',
            arDiacless: hadith.arDiacless ?? '',
            note: hadith.note ?? '',
            gradeId: hadith.gradeId ?? 0,
            grade: hadith.grade ?? '',
            gradeColor: hadith.gradeColor ?? '',
            bookId: hadith.bookId,
            bookName: hadith.bookName ?? '',
          )).toList();
        }
      }
      
      return sample;
    } catch (e) {
      print('❌ Repository: Error getting sample data: $e');
      return sample;
    }
  }
  
  @override
  Future<bool> checkDatabaseSchema() async {
    if (database == null) {
      print('⚠️ Repository: Database is null');
      return false;
    }
    
    try {
      print('🔍 Repository: Checking database schema...');
      final isValid = await database!.checkDatabaseSchema();
      print(isValid 
        ? '✅ Repository: Database schema is valid' 
        : '❌ Repository: Database schema is invalid');
      return isValid;
    } catch (e) {
      print('❌ Repository: Error checking database schema: $e');
      return false;
    }
  }
  
  @override
  Future<bool> createSampleChapters(int bookId) async {
    print('ℹ️ Repository: createSampleChapters called but no action taken (sample data creation disabled)');
    return true; // Return true to avoid UI errors, but don't create any data
  }

  @override
  Future<void> verifyChaptersTable() async {
    if (database == null) {
      print('⚠️ Repository: Database is null');
      return;
    }
    
    try {
      print('🔍 Repository: Verifying chapters table...');
      await database!.dumpChaptersTable();
    } catch (e) {
      print('❌ Repository: Error verifying chapters table: $e');
    }
  }

  @override
  Future<void> exploreAllTables() async {
    if (database == null) {
      print('⚠️ Repository: Database is null');
      return;
    }
    
    try {
      print('🔍 Repository: Exploring all tables...');
      
      // Get book count
      try {
        final bookCount = await database!.getBookCount();
        print('📚 Repository: Found $bookCount books');
      } catch (e) {
        print('❌ Repository: Error getting book count: $e');
      }
      
      // Get chapter count
      try {
        final chapterCount = await database!.getChapterCount();
        print('📚 Repository: Found $chapterCount chapters');
      } catch (e) {
        print('❌ Repository: Error getting chapter count: $e');
      }
      
      // Get hadith count
      try {
        final hadithCount = await database!.getHadithCount();
        print('📚 Repository: Found $hadithCount hadiths');
      } catch (e) {
        print('❌ Repository: Error getting hadith count: $e');
      }
    } catch (e) {
      print('❌ Repository: Error exploring tables: $e');
    }
  }
  
  // Helper method to safely parse integers
  int? _safeIntParse(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    
    try {
      return int.parse(value.toString());
    } catch (e) {
      return null;
    }
  }
  
  // Helper method for debugging chapters
  Future<void> debugChapters(int bookId) async {
    if (database == null) return;
    
    try {
      print('🔍 Repository: Debugging chapters for book $bookId');
      
      // Check if the book exists
      final bookExists = await this.bookExists(bookId);
      print('📚 Book exists: $bookExists');
      
      // Get chapters for this book
      final chapters = await database!.getChaptersByBookId(bookId);
      print('📊 Found ${chapters.length} chapters for bookId=$bookId');
      
      if (chapters.isNotEmpty) {
        print('📝 First chapter data:');
        for (var chapter in chapters) {
          print('   - Chapter ${chapter.id}: "${chapter.title ?? 'No title'}" Book Id $bookId - "${chapter.hadisRange ?? 'No hadis range'}" - "${chapter.bookName ?? 'No book name'}" - "${chapter.number ?? 'No number'}"');
        }
        final firstChapter = chapters.first;
        print('   • id: ${firstChapter.id}');
        print('   • chapterId: ${firstChapter.chapterId}');
        print('   • bookId: ${firstChapter.bookId}');
        print('   • title: ${firstChapter.title}');
        print('   • number: ${firstChapter.number}');
        print('   • hadisRange: ${firstChapter.hadisRange}');
        print('   • bookName: ${firstChapter.bookName}');
      }
    } catch (e) {
      print('❌ Error debugging chapters: $e');
    }
  }
}

// import 'package:hadith/data/datasources/local/drift/database.dart';
// import 'package:hadith/domain/entities/book_entity.dart';
// import 'package:hadith/domain/entities/chapter_entity.dart';
// import 'package:hadith/domain/entities/hadith_entity.dart';
// import 'package:hadith/domain/repositories/hadith_repository.dart';

// class HadithRepositoryImpl implements HadithRepository {
//   final AppDatabase? database;
  
//   HadithRepositoryImpl(this.database);

//   @override
//   Future<List<BookEntity>> getAllBooks() async {
//     if (database == null) return [];
    
//     try {
//       final books = await database!.getAllBooks();
      
//       return books.map((book) => BookEntity(
//         id: book.id,
//         title: book.title ?? '',
//         titleAr: book.titleAr ?? '',
//         numberOfHadis: book.numberOfHadis ?? 0,
//         abvrCode: book.abvrCode ?? '',
//         bookName: book.bookName ?? '',
//         bookDescr: book.bookDescr ?? '',
//         colorCode: book.colorCode ?? '',
//       )).toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   @override
//   Future<List<ChapterEntity>> getChaptersByBookId(int bookId) async {
//     if (database == null) return [];
    
//     try {
//       final chapters = await database!.getChaptersByBookId(bookId);
      
//       return chapters.map((chapter) => ChapterEntity(
//         id: chapter.id,
//         chapterId: chapter.chapterId,
//         bookId: chapter.bookId,
//         title: chapter.title ?? '',
//         number: chapter.number ?? 0,
//         hadisRange: chapter.hadisRange ?? '',
//         bookName: chapter.bookName ?? '',
//       )).toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   @override
//   Future<List<HadithEntity>> getHadithsByChapterId(int chapterId) async {
//     if (database == null) return [];
    
//     try {
//       final hadiths = await database!.getHadithsByChapterId(chapterId);
      
//       return hadiths.map((hadith) => HadithEntity(
//         id: hadith.id,
//         bookId: hadith.bookId,
//         bookName: hadith.bookName ?? '',
//         chapterId: hadith.chapterId,
//         sectionId: hadith.sectionId,
//         hadithKey: hadith.hadithKey ?? '',
//         hadithId: hadith.hadithId ?? 0,
//         narrator: hadith.narrator ?? '',
//         bn: hadith.bn ?? '',
//         ar: hadith.ar ?? '',
//         arDiacless: hadith.arDiacless ?? '',
//         note: hadith.note ?? '',
//         gradeId: hadith.gradeId ?? 0,
//         grade: hadith.grade ?? '',
//         gradeColor: hadith.gradeColor ?? '',
//       )).toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   @override
//   Future<HadithEntity?> getHadithById(int hadithId) async {
//     if (database == null) return null;
    
//     try {
//       final hadith = await database!.getHadithById(hadithId);
      
//       if (hadith == null) {
//         return null;
//       }
      
//       return HadithEntity(
//         id: hadith.id,
//         bookId: hadith.bookId,
//         bookName: hadith.bookName ?? '',
//         chapterId: hadith.chapterId,
//         sectionId: hadith.sectionId,
//         hadithKey: hadith.hadithKey ?? '',
//         hadithId: hadith.hadithId ?? 0,
//         narrator: hadith.narrator ?? '',
//         bn: hadith.bn ?? '',
//         ar: hadith.ar ?? '',
//         arDiacless: hadith.arDiacless ?? '',
//         note: hadith.note ?? '',
//         gradeId: hadith.gradeId ?? 0,
//         grade: hadith.grade ?? '',
//         gradeColor: hadith.gradeColor ?? '',
//       );
//     } catch (e) {
//       return null;
//     }
//   }
  
//   @override
//   Future<bool> bookExists(int bookId) async {
//     if (database == null) return false;
    
//     try {
//       final book = await database!.getBookById(bookId);
//       return book != null;
//     } catch (e) {
//       return false;
//     }
//   }
  
//   @override
//   Future<bool> chapterExists(int chapterId) async {
//     if (database == null) return false;
    
//     try {
//       final chapter = await database!.getChapterById(chapterId);
//       return chapter != null;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Required interfaces that can be minimally implemented
//   @override
//   Future<bool> checkDatabaseSchema() async => database != null;
  
//   @override
//   Future<bool> createSampleChapters(int bookId) async => true;
  
//   @override
//   Future<Map<String, dynamic>> getDatabaseStats() async => {
//     'connected': database != null,
//     'bookCount': 0,
//     'chapterCount': 0,
//     'hadithCount': 0,
//   };
  
//   @override
//   Future<Map<String, dynamic>> getSampleData() async => {
//     'books': <BookEntity>[],
//     'chapter': <ChapterEntity>[],
//     'hadith': <HadithEntity>[],
//   };
  
//   @override
//   Future<bool> verifyDatabaseConnection() async => database != null;
  
//   @override
//   Future<void> verifyChaptersTable() async {}
  
//   @override
//   Future<void> exploreAllTables() async {}
// }