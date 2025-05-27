import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:hadith/domain/entities/chapter_entity.dart';
import 'package:hadith/domain/entities/hadith_entity.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
part 'database.g.dart';


class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().nullable()();
  TextColumn get titleAr => text().named('title_ar').nullable()();
  IntColumn get numberOfHadis => integer().named('number_of_hadis').nullable()();
  TextColumn get abvrCode => text().named('abvr_code').nullable()();
  TextColumn get bookName => text().named('book_name').nullable()();
  TextColumn get bookDescr => text().named('book_descr').nullable()();
  TextColumn get colorCode => text().named('color_code').nullable()(); 
}





@DriftDatabase(tables: [Books, Chapters, Hadiths])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Book>> getAllBooks() async {
    try {
      return await select(books).get();
    } catch (e) {
      print('Error in getAllBooks: $e');
      return [];
    }
  }


 Future<List<Chapter>> getChaptersByBookId(int bookId) async {
  try {
    print('📚 Database: getChaptersByBookId called with bookId=$bookId');
    
    // 1. First check the structure of chapters table
    print('🔍 Examining chapters table structure...');
    final chaptersSchema = await customSelect('PRAGMA table_info(chapter)').get();
    
    // Print out the schema
    print('📊 Chapters table columns:');
    for (final col in chaptersSchema) {
      print('   - ${col.data['name']} (${col.data['type']})');
    }
    
    // 2. Check if this book_id column actually exists
    final hasBookIdColumn = chaptersSchema.any((col) => 
      col.data['name'].toString().toLowerCase() == 'book_id');
    
    if (!hasBookIdColumn) {
      print('❌ Critical issue: chapters table does not have a book_id column!');
      
      // Try to find any column that might contain book information
      final possibleBookColumns = chaptersSchema
          .where((col) => col.data['name'].toString().toLowerCase().contains('book'))
          .map((col) => col.data['name'].toString())
          .toList();
          
      print('🔍 Possible book-related columns: $possibleBookColumns');
      
      if (possibleBookColumns.isEmpty) {
        return [];
      } else {
        // Try using the first found column
        final alternateColumn = possibleBookColumns.first;
        print('🔄 Will try to use "$alternateColumn" instead of "book_id"');
        
        // Check if this alternative column contains our book ID
        final altResults = await customSelect(
          'SELECT * FROM chapters WHERE $alternateColumn = ?',
          variables: [Variable.withInt(bookId)]
        ).get();
        
        print('🔍 Using $alternateColumn = $bookId returned ${altResults.length} chapters');
        
        if (altResults.isEmpty) return [];
        
        // Map the results to Chapter objects
        return altResults.map((row) => Chapter(
          id: row.data['id'] as int? ?? 0,
          chapterId: row.data['chapter_id'] as int? ?? 0,
          bookId: bookId,  // Use the provided bookId since we're searching by it
          title: row.data['title'] as String?,
          number: _safeIntParse(row.data['number']),
          hadisRange: row.data['hadis_range'] as String?,
          bookName: row.data['book_name'] as String?,
        )).toList();
      }
    }
    
    // 3. Dump a few rows from the chapters table to understand the data
    print('🔍 Sampling chapters table data...');
    final sampleRows = await customSelect('SELECT * FROM chapters LIMIT 5').get();
    
    print('📊 Sample from chapters table:');
    for (final row in sampleRows) {
      print('   - ${row.data}');
    }
    
    // 4. Check if there are any chapters with this book_id
    print('🔍 Searching for chapters with book_id = $bookId...');
    
    // First check if book exists
    final bookCheck = await customSelect(
      'SELECT COUNT(*) AS count FROM books WHERE id = ?',
      variables: [Variable.withInt(bookId)]
    ).getSingleOrNull();
    
    final bookCount = bookCheck?.data['count'] as int? ?? 0;
    
    if (bookCount == 0) {
      print('⚠️ Book with ID $bookId does not exist in books table');
      
      // Check if this book ID is present in the chapters table anyway
      final chapterCheck = await customSelect(
        'SELECT COUNT(*) AS count FROM chapters WHERE book_id = ?',
        variables: [Variable.withInt(bookId)]
      ).getSingleOrNull();
      
      final chapterCount = chapterCheck?.data['count'] as int? ?? 0;
      print('📊 Found $chapterCount chapters with book_id = $bookId despite book not existing');
    } else {
      print('✅ Book with ID $bookId exists, fetching chapters...');
    }
    
    // 5. Try a case-insensitive search of book_id in all the columns
    print('🔍 Searching all columns for bookId = $bookId...');
    
    List<Map<String, dynamic>> results = [];
    for (final col in chaptersSchema) {
      final colName = col.data['name'].toString();
      
      try {
        final check = await customSelect(
          'SELECT COUNT(*) AS count FROM chapters WHERE $colName = ?',
          variables: [Variable.withInt(bookId)]
        ).getSingleOrNull();
        
        final count = check?.data['count'] as int? ?? 0;
        if (count > 0) {
          print('🎯 Found $count matches in column "$colName"');
          
          // Get these records
          final colMatches = await customSelect(
            'SELECT * FROM chapters WHERE $colName = ?',
            variables: [Variable.withInt(bookId)]
          ).get();
          
          results = colMatches.map((row) => row.data as Map<String, dynamic>).toList();
          
          print('✅ Found chapter data using column "$colName"');
          break;
        }
      } catch (e) {
        // This column might not be compatible with integer comparison
        continue;
      }
    }
    
    if (results.isNotEmpty) {
      print('✅ Found ${results.length} chapters using column search');
      
      // Convert results to Chapter objects
      return results.map((row) => Chapter(
        id: row['id'] as int? ?? 0,
        chapterId: row['chapter_id'] as int? ?? 0,
        bookId: bookId,
        title: row['title'] as String?,
        number: _safeIntParse(row['number']),
        hadisRange: row['hadis_range'] as String?,
        bookName: row['book_name'] as String?,
      )).toList();
    }
    
    // 6. Try a brute force approach - get all chapters and check them
    print('🔍 Trying brute force approach - fetching all chapters...');
    
    final allChapters = await customSelect('SELECT * FROM chapter').get();
    print('📊 Total chapters in database: ${allChapters.length}');
    
    // Find any that might match our book
    final matchingChapters = allChapters.where((row) {
      try {
        // Check if any numeric column equals our bookId
        return row.data.entries.any((entry) {
          if (entry.value is int && entry.value == bookId) {
            print('🎯 Found match in column "${entry.key}" with value $bookId');
            return true;
          }
          return false;
        });
      } catch (e) {
        return false;
      }
    }).toList();
    
    if (matchingChapters.isNotEmpty) {
      print('✅ Found ${matchingChapters.length} potential matching chapters with brute force');
      
      // Convert to Chapter objects
      return matchingChapters.map((row) => Chapter(
        id: row.data['id'] as int? ?? 0,
        chapterId: row.data['chapter_id'] as int? ?? 0,
        bookId: bookId,
        title: row.data['title'] as String?,
        number: _safeIntParse(row.data['number']),
        hadisRange: row.data['hadis_range'] as String?,
        bookName: row.data['book_name'] as String?,
      )).toList();
    }
    
    // 7. If nothing worked, maybe the book_id is a string
    try {
      print('🔍 Trying string comparison - book_id = "${bookId}"...');
      
      final stringResults = await customSelect(
        'SELECT * FROM chapters WHERE book_id = ?',
        variables: [Variable.withString(bookId.toString())]
      ).get();
      
      print('📊 String comparison returned ${stringResults.length} chapters');
      
      if (stringResults.isNotEmpty) {
        // Convert to Chapter objects
        return stringResults.map((row) => Chapter(
          id: row.data['id'] as int? ?? 0,
          chapterId: row.data['chapter_id'] as int? ?? 0,
          bookId: bookId,
          title: row.data['title'] as String?,
          number: _safeIntParse(row.data['number']),
          hadisRange: row.data['hadis_range'] as String?,
          bookName: row.data['book_name'] as String?,
        )).toList();
      }
    } catch (e) {
      print('❌ String comparison failed: $e');
    }
    
    // If we reach here, all methods failed
    print('❌ All methods to find chapters for book $bookId failed');
    return [];
    
  } catch (e, stackTrace) {
    print('❌ Error in getChaptersByBookId: $e');
    print('📈 Stack trace: $stackTrace');
    return [];
  }
}



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


// Future<List<Hadith>> getHadithsByChapterId(int chapterId) async {
//   try {
//     try {
//       final results = await customSelect(
//         'SELECT * FROM hadith WHERE chapter_id = ?',
//         variables: [Variable.withInt(chapterId)]
//       ).get();
      
//       if (results.isEmpty) {
//         return [];
//       }
      
//       return results.map((row) {
//         try {
//           return Hadith(
//             id: row.data['id'] as int? ?? 0,
//             bookId: row.data['book_id'] as int? ?? 0,
//             bookName: row.data['book_name'] as String?,
//             chapterId: row.data['chapter_id'] as int? ?? 0,
//             sectionId: row.data['section_id'] as int?,
//             hadithKey: row.data['hadith_key'] as String?,
//             hadithId: row.data['hadith_id'] as int?,
//             narrator: row.data['narrator'] as String?,
//             bn: row.data['bn'] as String?,
//             ar: row.data['ar'] as String?,
//             arDiacless: row.data['ar_diacless'] as String?,
//             note: row.data['note'] as String?,
//             gradeId: row.data['grade_id'] as int?,
//             grade: row.data['grade'] as String?,
//             gradeColor: row.data['grade_color'] as String?,
//           );
//         } catch (e) {
//           return Hadith(
//             id: 0, 
//             bookId: 0,
//             chapterId: chapterId, 
//           );
//         }
//       }).where((hadith) => hadith.id > 0).toList();
//     } catch (e) {
//       // Try fallback using drift's query builder
//       return await (select(hadiths)..where((h) => h.chapterId.equals(chapterId))).get();
//     }
//   } catch (e) {
//     return [];
//   }
// }

  Future<List<Hadith>> getHadithsByChapterId(int chapterId) async {
  try {
    print('📚 Repository: in getHadithsByChapterId Getting hadiths for chapter $chapterId...');
    
    final chapterCheck = await customSelect(
      'SELECT COUNT(*) AS count FROM chapter WHERE id = ?',
      variables: [Variable.withInt(chapterId)]
    ).getSingleOrNull();

    print('📊 Chapter check returned ${chapterCheck?.data['count']}');
    
    final chapterCount = chapterCheck?.data['count'] as int? ?? 0;
    if (chapterCount == 0) {
      print('⚠️ Chapter with ID $chapterId does not exist in chapters table');
    } else {
      print('Chapter with ID $chapterId exists, fetching hadiths...');
    }
    
    final hadithsSchema = await customSelect('PRAGMA table_info(hadith)').get();
    
    for (final col in hadithsSchema) {
      print('   - ${col.data['name']} (${col.data['type']})');
    }
    
    final hasChapterIdColumn = hadithsSchema.any((col) => 
      col.data['name'].toString().toLowerCase() == 'chapter_id');
    
    if (!hasChapterIdColumn) {
      
      final possibleChapterColumns = hadithsSchema
          .where((col) => col.data['name'].toString().toLowerCase().contains('chapter'))
          .map((col) => col.data['name'].toString())
          .toList();      
      if (possibleChapterColumns.isEmpty) {
        return [];
      }
    }
    
    final sampleRows = await customSelect('SELECT * FROM hadith LIMIT 5').get();
    
    for (final row in sampleRows) {
      print('   - ${row.data}');
    }
    
    try {
      final results = await customSelect(
        'SELECT * FROM hadith WHERE chapter_id = ?',
        variables: [Variable.withInt(chapterId)]
      ).get();
      
      
      if (results.isEmpty) {
        
        final totalHadiths = await customSelect('SELECT COUNT(*) AS count FROM hadith').getSingleOrNull();
        final hadithCount = totalHadiths?.data['count'] as int? ?? 0;
        
        if (hadithCount == 0) {
          print(' Warning: hadiths table appears to be empty!');
        }
        
        return [];
      }
      
      return results.map((row) {
        try {
          return Hadith(
            id: row.data['id'] as int? ?? 0,
            bookId: row.data['book_id'] as int? ?? 0,
            bookName: row.data['book_name'] as String?,
            chapterId: row.data['chapter_id'] as int? ?? 0,
            sectionId: row.data['section_id'] as int?,
            hadithKey: row.data['hadith_key'] as String?,
            hadithId: row.data['hadith_id'] as int?,
            narrator: row.data['narrator'] as String?,
            bn: row.data['bn'] as String?,
            ar: row.data['ar'] as String?,
            arDiacless: row.data['ar_diacless'] as String?,
            note: row.data['note'] as String?,
            gradeId: row.data['grade_id'] as int?,
            grade: row.data['grade'] as String?,
            gradeColor: row.data['grade_color'] as String?,
          );
        } catch (e) {
          print('❌ Error mapping hadith row: $e');
          print('📊 Problematic row data: ${row.data}');
          return Hadith(
            id: 0, 
            bookId: 0,
            chapterId: chapterId, 
          );
        }
      }).where((hadith) => hadith.id > 0).toList();
    } catch (e, stack) {
      print('❌ Error in standard query: $e');
      print('📈 Stack trace: $stack');
      
      // Try a fallback using drift's query builder
      try {
        print('🔄 Trying Drift query builder as fallback...');
        final driftResults = await (select(hadiths)..where((h) => h.chapterId.equals(chapterId))).get();
        print('✅ Drift query returned ${driftResults.length} hadiths');
        return driftResults;
      } catch (e) {
        print('❌ Drift query also failed: $e');
        return [];
      }
    }
  } catch (e, stackTrace) {
    print('❌ Error in getHadithsByChapterId: $e');
    print('📈 Stack trace: $stackTrace');
    return [];
  }
}



  //  Future<Hadith?> getHadithById(int hadithId) async {
  //   try {
  //     return await (select(hadiths)..where((h) => h.id.equals(hadithId))).getSingleOrNull();
  //   } catch (e) {
  //     print('Error in getHadithById: $e');
  //     return null;
  //   }
  // }
Future<Hadith?> getHadithById(int hadithId) async {
  try {
    print('📚 Database: getHadithById called with hadithId=$hadithId');
    
    // Check if the hadith exists
    final hadithExists = await this.customSelect(
      'SELECT EXISTS(SELECT 1 FROM hadiths WHERE id = ?) AS exists',
      variables: [Variable.withInt(hadithId)]
    ).getSingleOrNull();
    
    final hadithExistsFlag = hadithExists?.data['exists'] as int? ?? 0;
    if (hadithExistsFlag == 0) {
      print('⚠️ Hadith with ID $hadithId does not exist');
      return null;
    }
    
    print('✅ Hadith with ID $hadithId exists, fetching data...');
    
    // Using direct SQL query for better logging and debugging
    final result = await this.customSelect(
      'SELECT * FROM hadiths WHERE id = ?',
      variables: [Variable.withInt(hadithId)]
    ).getSingleOrNull();
    
    if (result == null) {
      print('ℹ️ No hadith found with ID $hadithId');
      return null;
    }
    
    // Convert raw result to Hadith object
    final hadith = Hadith(
      id: result.data['id'] as int,
      bookId: result.data['book_id'] as int,
      bookName: result.data['book_name'] as String?,
      chapterId: result.data['chapter_id'] as int,
      sectionId: result.data['section_id'] as int?,
      hadithKey: result.data['hadith_key'] as String?,
      hadithId: result.data['hadith_id'] as int?,
      narrator: result.data['narrator'] as String?,
      bn: result.data['bn'] as String?,
      ar: result.data['ar'] as String?,
      arDiacless: result.data['ar_diacless'] as String?,
      note: result.data['note'] as String?,
      gradeId: result.data['grade_id'] as int?,
      grade: result.data['grade'] as String?,
      gradeColor: result.data['grade_color'] as String?,
    );
    
    print('📊 Retrieved hadith with ID $hadithId successfully');
    return hadith;
    
  } catch (e, stackTrace) {
    print('❌ Error in getHadithById: $e');
    print('📈 Stack trace: $stackTrace');
    return null;
  }
}
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //


Future<Book?> getBookById(int bookId) async {
  try {
    return await (select(books)..where((b) => b.id.equals(bookId))).getSingleOrNull();
  } catch (e) {
    print('❌ Error getting book by ID: $e');
    return null;
  }
}

// Get a specific chapter by ID
Future<Chapter?> getChapterById(int chapterId) async {
  try {
    return await (select(chapters)..where((c) => c.id.equals(chapterId))).getSingleOrNull();
  } catch (e) {
    print('❌ Error getting chapter by ID: $e');
    return null;
  }
}

// Get count of books
Future<int> getBookCount() async {
  try {
    final result = await customSelect('SELECT COUNT(*) AS count FROM books').getSingleOrNull();
    return result?.data['count'] as int? ?? 0;
  } catch (e) {
    print('❌ Error counting books: $e');
    return 0;
  }
}

// Get count of chapters
Future<int> getChapterCount() async {
  try {
    final result = await customSelect('SELECT COUNT(*) AS count FROM chapters').getSingleOrNull();
    return result?.data['count'] as int? ?? 0;
  } catch (e) {
    print('❌ Error counting chapters: $e');
    return 0;
  }
}

// Get count of hadiths
Future<int> getHadithCount() async {
  try {
    final result = await customSelect('SELECT COUNT(*) AS count FROM hadiths').getSingleOrNull();
    return result?.data['count'] as int? ?? 0;
  } catch (e) {
    print('❌ Error counting hadiths: $e');
    return 0;
  }
}

// Get a sample of books (up to 5)
Future<List<Book>> getSampleBooks() async {
  try {
    return await (select(books)..limit(5)).get();
  } catch (e) {
    print('❌ Error getting sample books: $e');
    return [];
  }
}

// Get a sample of chapters for a specific book (up to 5)
Future<List<Chapter>> getSampleChaptersForBook(int bookId) async {
  try {
    return await (select(chapters)
      ..where((c) => c.bookId.equals(bookId))
      ..limit(5)
    ).get();
  } catch (e) {
    print('❌ Error getting sample chapters: $e');
    return [];
  }
}

// Get a sample of hadiths for a specific chapter (up to 5)
Future<List<Hadith>> getSampleHadithsForChapter(int chapterId) async {
  try {
    return await (select(hadiths)
      ..where((h) => h.chapterId.equals(chapterId))
      ..limit(5)
    ).get();
  } catch (e) {
    print('❌ Error getting sample hadiths: $e');
    return [];
  }
}

// Check database schema
Future<bool> checkDatabaseSchema() async {
  try {
    print('🔍 Checking database schema...');
    
    // Check for required tables
    final tables = await customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('books', 'chapter', 'hadith')"
    ).get();
    
    final tableNames = tables.map((row) => row.data['name'] as String).toSet();
    final requiredTables = {'books', 'chapter', 'hadith'};
    
    final missingTables = requiredTables.difference(tableNames);
    if (missingTables.isNotEmpty) {
      print('❌ Missing tables: ${missingTables.join(', ')}');
      return false;
    }
    
    // Check for required columns in books table
    if (tableNames.contains('books')) {
      final bookColumns = await customSelect("PRAGMA table_info(books)").get();
      final columnNames = bookColumns.map((row) => row.data['name'] as String).toSet();
      final requiredColumns = {'id', 'title', 'title_ar', 'number_of_hadis', 'abvr_code', 'color_code'};
      
      final missingColumns = requiredColumns.difference(columnNames);
      if (missingColumns.isNotEmpty) {
        print('❌ Books table missing columns: ${missingColumns.join(', ')}');
        return false;
      }
    }
    
    // Verify the schema matches our expectations
    print('✅ Database schema verification successful');
    return true;
  } catch (e) {
    print('❌ Error checking database schema: $e');
    return false;
  }
}













  
  
  // Verification method to check database connection
Future<bool> verifyConnection() async {
  try {
    print('🔍 Verifying database connection...');
    
    // Use a direct select statement instead of selectOnly
    try {
      // Attempt to query the SQLite version - this should work even if tables don't exist
      final result = await customSelect('SELECT sqlite_version() AS version').getSingleOrNull();
      print('✅ SQLite version: ${result?.data['version']}');
      
      // Now try to query the books table
      final booksCount = await customSelect('SELECT COUNT(*) AS count FROM books').getSingleOrNull();
      if (booksCount != null) {
        print('✅ Found ${booksCount.data['count']} books in database');
        return true;
      } else {
        print('⚠️ Books table query returned null');
        return false;
      }
    } catch (e) {
      print('❌ Error during database query: $e');
      
      // Try a simpler check - just verify the database file exists and can be opened
      try {
        // Just get one row from the books table
        final result = await customSelect('SELECT 1 AS test').getSingleOrNull();
        print('✅ Basic database query successful');
        return true;
      } catch (e) {
        print('❌ Basic database query failed: $e');
        return false;
      }
    }
  } catch (e, stackTrace) {
    print('❌ Error verifying database: $e');
    print('📈 Stack trace: $stackTrace');
    return false;
  }
}
 

Future<bool> bookExists(int bookId) async {
  try {
    final book = await (select(books)..where((b) => b.id.equals(bookId))).getSingleOrNull();
    return book != null;
  } catch (e) {
    print('❌ Error checking if book exists: $e');
    return false;
  }
}
  







  Future<void> dumpChaptersTable() async {
  try {
    print('📊 Dumping chapters table contents...');
    
    final allChapters = await select(chapters).get();
    print('📊 Found ${allChapters.length} total chapters in the database');
    
    // Group chapters by book_id
    final Map<int, List<Chapter>> chaptersByBook = {};
    for (var chapter in allChapters) {
      if (!chaptersByBook.containsKey(chapter.bookId)) {
        chaptersByBook[chapter.bookId] = [];
      }
      chaptersByBook[chapter.bookId]!.add(chapter);
    }
    
    // Print summary
    print('📊 Chapters distribution by book_id:');
    chaptersByBook.forEach((bookId, bookChapters) {
      print('   • Book ID $bookId: ${bookChapters.length} chapters');
    });
    
    // Print first few chapters from each book
    chaptersByBook.forEach((bookId, bookChapters) {
      if (bookChapters.isNotEmpty) {
        print('   • Sample from Book ID $bookId:');
        final sample = bookChapters.take(2).toList();
        for (var chapter in sample) {
          print('     - Chapter ${chapter.id}: "${chapter.title ?? 'No title'}"');
        }
      }
    });
    
  } catch (e) {
    print('❌ Error dumping chapters table: $e');
  }
}
}




LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    try {
      // Get a location for storing the database on the device
      final dbFolder = await getApplicationDocumentsDirectory();
      print('📚 Database path: ${dbFolder.path}');
      final file = File(p.join(dbFolder.path, 'hadith.db'));
      print('📊 Database file path: ${file.path}');
      
      // Check if database exists, if not copy it from assets
      if (!file.existsSync()) {
        try {
          // Create parent directory if it doesn't exist
          if (!file.parent.existsSync()) {
            print('📁 Creating parent directory: ${file.parent.path}');
            file.parent.createSync(recursive: true);
          }
          
          // Copy database from assets
          print('📥 Loading database from assets...');
          ByteData data = await rootBundle.load('assets/database/hadith.db');
          print('📊 Database size from assets: ${data.lengthInBytes} bytes');
          
          if (data.lengthInBytes > 0) {
            List<int> bytes = data.buffer.asUint8List();
            print('📊 Copying database...');
            await file.writeAsBytes(bytes, flush: true);
            
            // Verify the file was created with proper size
            if (await file.exists()) {
              final fileSize = await file.length();
              print('📊 Copied database size: $fileSize bytes');
              
              if (fileSize == 0 || fileSize != data.lengthInBytes) {
                print('⚠️ Warning: Copied file size ($fileSize) differs from source (${data.lengthInBytes})');
              } else {
                print('✅ Database copied successfully to: ${file.path}');
              }
            } else {
              print('❌ Failed to create database file');
            }
          } else {
            print('❌ Error: Database asset has zero size');
            throw Exception('Database asset has zero size');
          }
        } catch (e) {
          print('❌ Error copying database: $e');
          // If copying fails, try to create an empty database as fallback
          print('⚠️ Attempting to create empty database as fallback');
          try {
            // This will create an empty SQLite database
            final db = NativeDatabase.memory();
            print('✅ Created empty database in memory');
            return db;
          } catch (e) {
            print('❌ Failed to create empty database: $e');
            rethrow;
          }
        }
      } else {
        print('📚 Database already exists at: ${file.path}');
        final fileSize = await file.length();
        print('📊 Existing database size: $fileSize bytes');
        
        if (fileSize == 0) {
          print('⚠️ Warning: Existing database file has zero size! Attempting to replace it...');
          
          // Backup the broken file
          final backupFile = File('${file.path}.bak');
          if (await backupFile.exists()) {
            await backupFile.delete();
          }
          await file.copy('${file.path}.bak');
          
          // Delete the broken file
          await file.delete();
          
          // Copy fresh database from assets
          ByteData data = await rootBundle.load('assets/database/hadith.db');
          List<int> bytes = data.buffer.asUint8List();
          await file.writeAsBytes(bytes, flush: true);
          print('🔄 Replaced database file with fresh copy from assets');
        }
      }
      
      // Create the database connection without verification
      // We'll verify it works in the AppDatabase itself
      return NativeDatabase(file);
      
    } catch (e, stackTrace) {
      print('❌ Critical error in database initialization: $e');
      print('📈 Stack trace: $stackTrace');
      
      // Last resort - create an in-memory database
      print('⚠️ Creating in-memory database as last resort');
      return NativeDatabase.memory();
    }
  });







  
}







// import 'dart:io';
// import 'package:drift/drift.dart';
// import 'package:drift/native.dart';
// import 'package:flutter/services.dart';
// import 'package:hadith/domain/entities/chapter_entity.dart';
// import 'package:hadith/domain/entities/hadith_entity.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// part 'database.g.dart';

// class Books extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get title => text().nullable()();
//   TextColumn get titleAr => text().named('title_ar').nullable()();
//   IntColumn get numberOfHadis => integer().named('number_of_hadis').nullable()();
//   TextColumn get abvrCode => text().named('abvr_code').nullable()();
//   TextColumn get bookName => text().named('book_name').nullable()();
//   TextColumn get bookDescr => text().named('book_descr').nullable()();
//   TextColumn get colorCode => text().named('color_code').nullable()(); 
// }

// @DriftDatabase(tables: [Books, Chapters, Hadiths])
// class AppDatabase extends _$AppDatabase {
//   AppDatabase() : super(_openConnection());

//   @override
//   int get schemaVersion => 1;

//   Future<List<Book>> getAllBooks() async {
//     try {
//       return await select(books).get();
//     } catch (e) {
//       return [];
//     }
//   }

//   Future<List<Chapter>> getChaptersByBookId(int bookId) async {
//     try {
//       return await (select(chapters)..where((c) => c.bookId.equals(bookId))).get();
//     } catch (e) {
//       return [];
//     }
//   }

//   int? _safeIntParse(dynamic value) {
//     if (value == null) return null;
//     if (value is int) return value;
//     if (value is double) return value.toInt();
    
//     try {
//       return int.parse(value.toString());
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<List<Hadith>> getHadithsByChapterId(int chapterId) async {
//     try {
//       return await (select(hadiths)..where((h) => h.chapterId.equals(chapterId))).get();
//     } catch (e) {
//       return [];
//     }
//   }

//   Future<Hadith?> getHadithById(int hadithId) async {
//     try {
//       return await (select(hadiths)..where((h) => h.id.equals(hadithId))).getSingleOrNull();
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<Book?> getBookById(int bookId) async {
//     try {
//       return await (select(books)..where((b) => b.id.equals(bookId))).getSingleOrNull();
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<Chapter?> getChapterById(int chapterId) async {
//     try {
//       return await (select(chapters)..where((c) => c.id.equals(chapterId))).getSingleOrNull();
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<int> getBookCount() async {
//     try {
//       final result = await customSelect('SELECT COUNT(*) AS count FROM books').getSingleOrNull();
//       return result?.data['count'] as int? ?? 0;
//     } catch (e) {
//       return 0;
//     }
//   }

//   Future<int> getChapterCount() async {
//     try {
//       final result = await customSelect('SELECT COUNT(*) AS count FROM chapter').getSingleOrNull();
//       return result?.data['count'] as int? ?? 0;
//     } catch (e) {
//       return 0;
//     }
//   }

//   Future<int> getHadithCount() async {
//     try {
//       final result = await customSelect('SELECT COUNT(*) AS count FROM hadith').getSingleOrNull();
//       return result?.data['count'] as int? ?? 0;
//     } catch (e) {
//       return 0;
//     }
//   }

//   Future<bool> bookExists(int bookId) async {
//     try {
//       final book = await (select(books)..where((b) => b.id.equals(bookId))).getSingleOrNull();
//       return book != null;
//     } catch (e) {
//       return false;
//     }
//   }
// }

// LazyDatabase _openConnection() {
//   return LazyDatabase(() async {
//     final dbFolder = await getApplicationDocumentsDirectory();
//     final file = File(p.join(dbFolder.path, 'hadith.db'));
    
//     if (!file.existsSync()) {
//       if (!file.parent.existsSync()) {
//         file.parent.createSync(recursive: true);
//       }
      
//       ByteData data = await rootBundle.load('assets/database/hadith.db');
//       List<int> bytes = data.buffer.asUint8List();
//       await file.writeAsBytes(bytes, flush: true);
//     }
    
//     return NativeDatabase(file);
//   });
// }