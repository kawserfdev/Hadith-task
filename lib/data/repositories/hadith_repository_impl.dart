

// import 'package:hadith/data/datasources/local/cache_service.dart';
// import 'package:hadith/data/datasources/local/drift/database.dart';
// import 'package:hadith/domain/entities/book_entity.dart';
// import 'package:hadith/domain/entities/chapter_entity.dart';
// import 'package:hadith/domain/entities/hadith_entity.dart';
// import 'package:hadith/domain/repositories/hadith_repository.dart';

// class HadithRepositoryImpl implements HadithRepository {
//   final AppDatabase database;
  
//   HadithRepositoryImpl( this.database);
  
//   @override
//   Future<List<BookEntity>> getAllBooks() async {
//     // Try to get from cache first
//     final cachedBooks = CacheService.get('all_books');
//     if (cachedBooks != null) {
//       return cachedBooks as List<BookEntity>;
//     }
    
//     final books = await database.getAllBooks();
//     final bookEntities = books.map((book) => BookEntity(
//       id: book.id,
//       title: book.title,
//       titleAr: book.titleAr,
//       numberOfHadith: book.numberOfHadith,
//       abvrCode: book.abvrCode,
//       bookColor: book.bookColor
//     )).toList();
    
//     // Cache for 1 hour
//     CacheService.setWithExpiry('all_books', bookEntities, Duration(hours: 1));
    
//     return bookEntities;
//   }
  
//   @override

//   Future<List<ChapterEntity>> getChaptersByBookId(int bookId) async {
//     // Try to get from cache first
//     final cacheKey = 'chapters_book_$bookId';
//     final cachedChapters = CacheService.get(cacheKey);
//     if (cachedChapters != null) {
//       return cachedChapters as List<ChapterEntity>;
//     }
    
//     final chapters = await database.getChaptersByBookId(bookId);
//     final chapterEntities = chapters.map((chapter) => ChapterEntity(
//       id: chapter.id,
//       bookId: chapter.bookId,
//       title: chapter.title,
//       titleAr: chapter.titleAr,
//       hadithStartNumber: chapter.hadithStartNumber,
//       hadithEndNumber: chapter.hadithEndNumber
//     )).toList();
    
//     // Cache for 1 hour
//     CacheService.setWithExpiry(cacheKey, chapterEntities, Duration(hours: 1));
    
//     return chapterEntities;
//   }
  
//   @override
//   Future<List<HadithEntity>> getHadithsByChapterId(int chapterId) async {
//     // Try to get from cache first
//     final cacheKey = 'hadiths_chapter_$chapterId';
//     final cachedHadiths = CacheService.get(cacheKey);
//     if (cachedHadiths != null) {
//       return cachedHadiths as List<HadithEntity>;
//     }
    
//     final hadiths = await database.getHadithsByChapterId(chapterId);
//     final hadithEntities = hadiths.map((hadith) => HadithEntity(
//       id: hadith.id,
//       bookId: hadith.bookId,
//       chapterId: hadith.chapterId,
//       hadithNumber: hadith.hadithNumber,
//       narrator: hadith.narrator,
//       narratorAr: hadith.narratorAr,
//       content: hadith.content,
//       contentAr: hadith.contentAr,
//       grade: hadith.grade
//     )).toList();
    
//     // Cache for 30 minutes
//     CacheService.setWithExpiry(cacheKey, hadithEntities, Duration(minutes: 30));
    
//     return hadithEntities;
//   }
  
//   @override
//   Future<HadithEntity> getHadithById(int hadithId) async {
//     // Try to get from cache first
//     final cacheKey = 'hadith_$hadithId';
//     final cachedHadith = CacheService.get(cacheKey);
//     if (cachedHadith != null) {
//       return cachedHadith as HadithEntity;
//     }
    
//     final hadith = await database.getHadithById(hadithId);
//     final hadithEntity = HadithEntity(
//       id: hadith.id,
//       bookId: hadith.bookId,
//       chapterId: hadith.chapterId,
//       hadithNumber: hadith.hadithNumber,
//       narrator: hadith.narrator,
//       narratorAr: hadith.narratorAr,
//       content: hadith.content,
//       contentAr: hadith.contentAr,
//       grade: hadith.grade
//     );
    
//     // Cache for 30 minutes
//     CacheService.setWithExpiry(cacheKey, hadithEntity, Duration(minutes: 30));
    
//     return hadithEntity;
//   }
// }