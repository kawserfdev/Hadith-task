import 'package:hadith/data/datasources/local/drift/database.dart';
import 'package:hadith/domain/entities/book_entity.dart';
import 'package:hadith/domain/entities/chapter_entity.dart';
import 'package:hadith/domain/entities/hadith_entity.dart';
import 'package:hadith/domain/repositories/hadith_repository.dart';

class HadithRepositoryImpl implements HadithRepository {
 final AppDatabase? database;
  
  HadithRepositoryImpl(this.database);
  




// @override
//   Future<List<BookEntity>> getAllBooks() async {
//     print('📚 Repository: getAllBooks called');
    
//     if (database == null) {
//       print('⚠️ Repository: database is null');
//       return [];
//     }
    
//     try {
//       final books = await database!.getAllBooks();
//       print('✅ Repository: Got ${books.length} books');
      
//       return books.map((book) => BookEntity(
//         id: book.id,
//         title: book.title ?? '',
//         titleAr: book.titleAr ?? '',
//         numberOfHadith: book.numberOfHadith ?? 0,
//         abvrCode: book.abvrCode ?? '',
//         bookColor: book.bookColor ?? 0
//       )).toList();
//     } catch (e, stackTrace) {
//       print('❌ Repository: Error in getAllBooks: $e');
//       print('📈 Stack trace: $stackTrace');
//       return [];
//     }
//   }



 @override
  Future<List<BookEntity>> getAllBooks() async {
    if (database == null) return [];
    
    try {
      final books = await database!.getAllBooks();
      return books.map((book) => BookEntity(
        id: book.id,
        title: book.title,
        titleAr: book.titleAr,
        numberOfHadis: book.numberOfHadis,
        abvrCode: book.abvrCode,
        bookName: book.bookName,
        bookDescr: book.bookDescr,
        colorCode: book.colorCode,
      )).toList();
    } catch (e) {
      print('Error in getAllBooks: $e');
      return [];
    }
  }


  // @override
  // Future<List<ChapterEntity>> getChaptersByBookId(int bookId) async {
  //   print('📚 Repository: getChaptersByBookId called with bookId=$bookId');
    
  //   if (database == null) {
  //     print('⚠️ Repository: database is null');
  //     return [];
  //   }
    
  //   try {
  //     // First verify the book exists
  //     final exists = await bookExists(bookId);
  //     if (!exists) {
  //       print('⚠️ Repository: book with id=$bookId does not exist!');
  //     }
      
  //     final chapters = await database!.getChaptersByBookId(bookId);
  //     print('✅ Repository: Got ${chapters.length} chapters for bookId=$bookId');
      
  //     return chapters.map((chapter) => ChapterEntity(
  //       id: chapter.id,
  //       bookId: chapter.bookId,
  //       title: chapter.title ?? '',
  //       titleAr: chapter.titleAr ?? '',
  //       hadithStartNumber: chapter.hadithStartNumber ?? 0,
  //       hadithEndNumber: chapter.hadithEndNumber ?? 0
  //     )).toList();
  //   } catch (e, stackTrace) {
  //     print('❌ Repository: Error in getChaptersByBookId: $e');
  //     print('📈 Stack trace: $stackTrace');
  //     return [];
  //   }
  // }


 @override
  Future<List<ChapterEntity>> getChaptersByBookId(int bookId) async {
    if (database == null) return [];
    
    try {
      final chapters = await database!.getChaptersByBookId(bookId);
      return chapters.map((chapter) => ChapterEntity(
        id: chapter.id,
        chapterId: chapter.chapterId,
        bookId: chapter.bookId,
        title: chapter.title,
        number: chapter.number,
        hadisRange: chapter.hadisRange,
        bookName: chapter.bookName,
      )).toList();
    } catch (e) {
      print('Error in getChaptersByBookId: $e');
      return [];
    }
  }
  //   @override
  // Future<List<HadithEntity>> getHadithsByChapterId(int chapterId) async {
  //   print('📚 Repository: getHadithsByChapterId called with chapterId=$chapterId');
    
  //   if (database == null) {
  //     print('⚠️ Repository: database is null');
  //     return [];
  //   }
    
  //   try {
  //     // First verify the chapter exists
  //     final exists = await chapterExists(chapterId);
  //     if (!exists) {
  //       print('⚠️ Repository: chapter with id=$chapterId does not exist!');
  //     }
      
  //     final hadiths = await database!.getHadithsByChapterId(chapterId);
  //     print('✅ Repository: Got ${hadiths.length} hadiths for chapterId=$chapterId');
      
  //     return hadiths.map((hadith) => HadithEntity(
  //       id: hadith.id,
  //       bookId: hadith.bookId,
  //       chapterId: hadith.chapterId,
  //       hadithNumber: hadith.hadithNumber ?? 0,
  //       narrator: hadith.narrator ?? '',
  //       narratorAr: hadith.narratorAr ?? '',
  //       content: hadith.content ?? '',
  //       contentAr: hadith.contentAr ?? '',
  //       grade: hadith.grade ?? ''
  //     )).toList();
  //   } catch (e, stackTrace) {
  //     print('❌ Repository: Error in getHadithsByChapterId: $e');
  //     print('📈 Stack trace: $stackTrace');
  //     return [];
  //   }
  // }


 @override
  Future<List<HadithEntity>> getHadithsByChapterId(int chapterId) async {
    if (database == null) return [];
    
    try {
      final hadiths = await database!.getHadithsByChapterId(chapterId);
      return hadiths.map((hadith) => HadithEntity(
        id: hadith.id,
        bookId: hadith.bookId,
        bookName: hadith.bookName,
        chapterId: hadith.chapterId,
        sectionId: hadith.sectionId,
        hadithKey: hadith.hadithKey,
        hadithId: hadith.hadithId,
        narrator: hadith.narrator,
        bn: hadith.bn,
        ar: hadith.ar,
        arDiacless: hadith.arDiacless,
        note: hadith.note,
        gradeId: hadith.gradeId,
        grade: hadith.grade,
        gradeColor: hadith.gradeColor,
      )).toList();
    } catch (e) {
      print('Error in getHadithsByChapterId: $e');
      return [];
    }
  }
  //   @override
  // Future<HadithEntity?> getHadithById(int hadithId) async {
  //   print('📚 Repository: getHadithById called with hadithId=$hadithId');
    
  //   if (database == null) {
  //     print('⚠️ Repository: database is null');
  //     return null;
  //   }
    
  //   try {
  //     final hadith = await database!.getHadithById(hadithId);
  //     if (hadith == null) {
  //       print('⚠️ Repository: No hadith found with id=$hadithId');
  //       return null;
  //     }
      
  //     print('✅ Repository: Got hadith with id=$hadithId');
      
  //     return HadithEntity(
  //       id: hadith.id,
  //       bookId: hadith.bookId,
  //       chapterId: hadith.chapterId,
  //       hadithNumber: hadith.hadithNumber ?? 0,
  //       narrator: hadith.narrator ?? '',
  //       narratorAr: hadith.narratorAr ?? '',
  //       content: hadith.content ?? '',
  //       contentAr: hadith.contentAr ?? '',
  //       grade: hadith.grade ?? ''
  //     );
  //   } catch (e, stackTrace) {
  //     print('❌ Repository: Error in getHadithById: $e');
  //     print('📈 Stack trace: $stackTrace');
  //     return null;
  //   }
  // }
  

 @override
  Future<HadithEntity?> getHadithById(int hadithId) async {
    if (database == null) return null;
    
    try {
      final hadith = await database!.getHadithById(hadithId);
      if (hadith == null) return null;
      
      return HadithEntity(
        id: hadith.id,
        bookId: hadith.bookId,
        bookName: hadith.bookName,
        chapterId: hadith.chapterId,
        sectionId: hadith.sectionId,
        hadithKey: hadith.hadithKey,
        hadithId: hadith.hadithId,
        narrator: hadith.narrator,
        bn: hadith.bn,
        ar: hadith.ar,
        arDiacless: hadith.arDiacless,
        note: hadith.note,
        gradeId: hadith.gradeId,
        grade: hadith.grade,
        gradeColor: hadith.gradeColor,
      );
    } catch (e) {
      print('Error in getHadithById: $e');
      return null;
    }
  }




  @override
  Future<bool> verifyDatabaseConnection() async {
    if (database == null) {
      print('⚠️ Repository: database is null');
      return false;
    }
    
    try {
      // Try to execute a simple query to verify the connection
      final stats = await getDatabaseStats();
      return stats['connected'] as bool;
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
      // Query the database for basic statistics
      try {
        final bookCount = await database!.getBookCount();
        stats['bookCount'] = bookCount;
        stats['connected'] = true;
      } catch (e) {
        print('❌ Error getting book count: $e');
      }
      
      try {
        final chapterCount = await database!.getChapterCount();
        stats['chapterCount'] = chapterCount;
      } catch (e) {
        print('❌ Error getting chapter count: $e');
      }
      
      try {
        final hadithCount = await database!.getHadithCount();
        stats['hadithCount'] = hadithCount;
      } catch (e) {
        print('❌ Error getting hadith count: $e');
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
      // Get a sample of books
      final books = await database!.getSampleBooks();
      sample['books'] = books.map((book) => BookEntity(
        id: book.id,
        title: book.title ?? '',
        titleAr: book.titleAr ?? '',
        numberOfHadis: book.numberOfHadis ?? 0,
        abvrCode: book.abvrCode ?? '',
        bookName: book.bookName ?? '',
        bookDescr: book.bookDescr ?? '',
        colorCode: book.colorCode
      )).toList();
      
      // If we have books, get chapters for the first book
      if (books.isNotEmpty) {
        final chapters = await database!.getSampleChaptersForBook(books.first.id);
        sample['chapters'] = chapters.map((chapter) => ChapterEntity(
          id: chapter.id,
          bookId: chapter.bookId,
          chapterId: chapter.chapterId ,
          title: chapter.title ?? '',
          number: chapter.number ?? 0,
          hadisRange: chapter.hadisRange ?? '',
          bookName: chapter.bookName ?? '',
        )).toList();
        
        // If we have chapters, get hadiths for the first chapter
        if (chapters.isNotEmpty) {
          final hadiths = await database!.getSampleHadithsForChapter(chapters.first.id);
          sample['hadiths'] = hadiths.map((hadith) => HadithEntity(
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
      print('⚠️ Repository: database is null');
      return false;
    }
    
    try {
      return await database!.checkDatabaseSchema();
    } catch (e) {
      print('❌ Repository: Error checking database schema: $e');
      return false;
    }
  }


  ///////////////////////


//   @override
//   Future<List<BookEntity>> getAllBooks() async {
//     print('📚 Repository: getAllBooks called');
    
//     if (database == null) {
//       print('⚠️ Repository: database is null');
//       return [];
//     }
    
//     try {
//       final books = await database!.getAllBooks();
//       print('✅ Repository: Got ${books.length} books');
      
//       return books.map((book) => BookEntity(
//         id: book.id,
//         title: book.title ?? '',
//         titleAr: book.titleAr ?? '',
//         numberOfHadith: book.numberOfHadith ?? 0,
//         abvrCode: book.abvrCode ?? '',
//         bookColor: book.bookColor ?? 0
//       )).toList();
//     } catch (e, stackTrace) {
//       print('❌ Repository: Error in getAllBooks: $e');
//       print('📈 Stack trace: $stackTrace');
//       return [];
//     }
//   }
  
// @override
// Future<List<ChapterEntity>> getChaptersByBookId(int bookId) async {
//   print('📚 Repository: getChaptersByBookId called with bookId=$bookId');
  
//   if (database == null) {
//     print('⚠️ Repository: database is null');
//     return [];
//   }
  
//   try {
//     // First verify the book exists
//     final bookExists = await database!.bookExists(bookId);
//     if (!bookExists) {
//       print('⚠️ Repository: book with id=$bookId does not exist!');
//     }
    
//     final chapters = await database!.getChaptersByBookId(bookId);
//     print('✅ Repository: Got ${chapters.length} chapters');
    
//     return chapters.map((chapter) => ChapterEntity(
//       id: chapter.id,
//       bookId: chapter.bookId,
//       title: chapter.title ?? '',
//       titleAr: chapter.titleAr ?? '',
//       hadithStartNumber: chapter.hadithStartNumber ?? 0,
//       hadithEndNumber: chapter.hadithEndNumber ?? 0
//     )).toList();
//   } catch (e, stackTrace) {
//     print('❌ Repository: Error in getChaptersByBookId: $e');
//     print('📈 Stack trace: $stackTrace');
//     return [];
//   }
// }
  
//   @override
//   Future<List<HadithEntity>> getHadithsByChapterId(int chapterId) async {
//     print('📚 Repository: getHadithsByChapterId called');
    
//     if (database == null) {
//       print('⚠️ Repository: database is null');
//       return [];
//     }
    
//     try {
//       final hadiths = await database!.getHadithsByChapterId(chapterId);
//       print('✅ Repository: Got ${hadiths.length} hadiths');
      
//       return hadiths.map((hadith) => HadithEntity(
//         id: hadith.id,
//         bookId: hadith.bookId,
//         chapterId: hadith.chapterId,
//         hadithNumber: hadith.hadithNumber ?? 0,
//         narrator: hadith.narrator ?? '',
//         narratorAr: hadith.narratorAr ?? '',
//         content: hadith.content ?? '',
//         contentAr: hadith.contentAr ?? '',
//         grade: hadith.grade ?? ''
//       )).toList();
//     } catch (e, stackTrace) {
//       print('❌ Repository: Error in getHadithsByChapterId: $e');
//       print('📈 Stack trace: $stackTrace');
//       return [];
//     }
//   }
  
//   @override
//   Future<HadithEntity?> getHadithById(int hadithId) async {
//     print('📚 Repository: getHadithById called');
    
//     if (database == null) {
//       print('⚠️ Repository: database is null');
//       return null;
//     }
    
//     try {
//       final hadith = await database!.getHadithById(hadithId);
//       if (hadith == null) {
//         print('⚠️ Repository: No hadith found with id=$hadithId');
//         return null;
//       }
      
//       print('✅ Repository: Got hadith with id=$hadithId');
      
//       return HadithEntity(
//         id: hadith.id,
//         bookId: hadith.bookId,
//         chapterId: hadith.chapterId,
//         hadithNumber: hadith.hadithNumber ?? 0,
//         narrator: hadith.narrator ?? '',
//         narratorAr: hadith.narratorAr ?? '',
//         content: hadith.content ?? '',
//         contentAr: hadith.contentAr ?? '',
//         grade: hadith.grade ?? ''
//       );
//     } catch (e, stackTrace) {
//       print('❌ Repository: Error in getHadithById: $e');
//       print('📈 Stack trace: $stackTrace');
//       return null;
//     }
//   }
}