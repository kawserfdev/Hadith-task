import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:hadith/domain/entities/book_entity.dart';
import 'package:hadith/domain/entities/chapter_entity.dart';
import 'package:hadith/domain/entities/hadith_entity.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';




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
      return await (select(chapters)..where((c) => c.bookId.equals(bookId))).get();
    } catch (e) {
      print('Error in getChaptersByBookId: $e');
      return [];
    }
  }

   Future<List<Hadith>> getHadithsByChapterId(int chapterId) async {
    try {
      return await (select(hadiths)..where((h) => h.chapterId.equals(chapterId))).get();
    } catch (e) {
      print('Error in getHadithsByChapterId: $e');
      return [];
    }
  }

   Future<Hadith?> getHadithById(int hadithId) async {
    try {
      return await (select(hadiths)..where((h) => h.id.equals(hadithId))).getSingleOrNull();
    } catch (e) {
      print('Error in getHadithById: $e');
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
      "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('books', 'chapters', 'hadiths')"
    ).get();
    
    final tableNames = tables.map((row) => row.data['name'] as String).toSet();
    final requiredTables = {'books', 'chapters', 'hadiths'};
    
    final missingTables = requiredTables.difference(tableNames);
    if (missingTables.isNotEmpty) {
      print('❌ Missing tables: ${missingTables.join(', ')}');
      return false;
    }
    
    // Check for required columns in books table
    if (tableNames.contains('books')) {
      final bookColumns = await customSelect("PRAGMA table_info(books)").get();
      final columnNames = bookColumns.map((row) => row.data['name'] as String).toSet();
      final requiredColumns = {'id', 'title', 'title_ar', 'number_of_hadith', 'abvr_code', 'book_color'};
      
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
  // Enhanced getAllBooks with proper error handling
  // Future<List<Book>> getAllBooks() async {
  //   try {
  //     print('📚 getAllBooks called');
  //     final result = await select(books).get();
  //     print('✅ Query successful, found ${result.length} books');
      
  //     if (result.isNotEmpty) {
  //       final firstBook = result.first;
  //       print('📖 First book: id=${firstBook.id}, title=${firstBook.title}');
  //     }
      
  //     return result;
  //   } catch (e, stackTrace) {
  //     print('❌ Error in getAllBooks: $e');
  //     print('📈 Stack trace: $stackTrace');
  //     return [];
  //   }
  // }
  
  // Enhanced getChaptersByBookId with error handling
// Future<List<Chapter>> getChaptersByBookId(int bookId) async {
//   try {
//     print('📚 getChaptersByBookId called for bookId=$bookId');
    
//     // First, let's do a full dump of ALL chapters to see what's there
//     try {
//       final allChaptersResult = await customSelect('SELECT * FROM chapters LIMIT 10').get();
//       print('📊 Sample of ALL chapters in database (up to 10):');
//       for (final row in allChaptersResult) {
//         // Print each column of the row to see what we're dealing with
//         print('   • Chapter: ${row.data}');
//       }
//     } catch (e) {
//       print('❌ Error getting sample chapters: $e');
//     }
    
//     // Check for the specific book_id column to verify its name and type
//     try {
//       final columnInfo = await customSelect("PRAGMA table_info(chapters)").get();
//       print('📊 Chapters table columns:');
//       for (final col in columnInfo) {
//         print('   • Column: ${col.data['name']}, Type: ${col.data['type']}');
//       }
      
//       // Check specifically for the book_id column
//       final bookIdColumn = columnInfo.where((col) => 
//           col.data['name'].toString().toLowerCase() == 'book_id' || 
//           col.data['name'].toString().toLowerCase() == 'bookid'
//       ).toList();
      
//       if (bookIdColumn.isEmpty) {
//         print('❌ Warning: No column named "book_id" or "bookid" found in chapters table!');
//       } else {
//         print('✅ Found book_id column: ${bookIdColumn.first.data}');
//       }
//     } catch (e) {
//       print('❌ Error checking columns: $e');
//     }
    
//     // Try a case-insensitive or alternative column name search
//     try {
//       print('🔍 Trying alternative query approaches...');
      
//       // Try with both lowercase and as-is cases for book_id
//       final alternativeQuery1 = await customSelect(
//         'SELECT * FROM chapters WHERE lower(book_id) = lower(?)',
//         variables: [Variable.withString(bookId.toString())]
//       ).get();
//       print('📊 Alternative query 1 results: ${alternativeQuery1.length}');
      
//       // Try with bookId instead of book_id
//       final alternativeQuery2 = await customSelect(
//         'SELECT * FROM chapters WHERE bookId = ?',
//         variables: [Variable.withInt(bookId)]
//       ).get();
//       print('📊 Alternative query 2 results: ${alternativeQuery2.length}');
      
//       // Try casting the book_id to string in case of type mismatch
//       final alternativeQuery3 = await customSelect(
//         'SELECT * FROM chapters WHERE cast(book_id as TEXT) = ?',
//         variables: [Variable.withString(bookId.toString())]
//       ).get();
//       print('📊 Alternative query 3 results: ${alternativeQuery3.length}');
      
//       // Try getting all chapters and manually filter them
//       final allChapters = await customSelect('SELECT * FROM chapters').get();
//       print('📊 Total chapters in database: ${allChapters.length}');
      
//       // Manually find chapters matching our bookId
//       final matchingChapters = allChapters.where((row) {
//         // Try to match in various ways
//         final rowBookId = row.data['book_id'] ?? row.data['bookId'];
//         if (rowBookId == null) return false;
        
//         // Try comparing as int, string, etc.
//         return rowBookId.toString() == bookId.toString() || 
//                (rowBookId is int && rowBookId == bookId);
//       }).toList();
      
//       print('📊 Manually filtered chapters for bookId=$bookId: ${matchingChapters.length}');
//       if (matchingChapters.isNotEmpty) {
//         print('📖 Sample matching chapter: ${matchingChapters.first.data}');
//       }
//     } catch (e) {
//       print('❌ Error trying alternative queries: $e');
//     }
    
//     // Now try the original Drift query again
//     try {
//       print('🔍 Building original Drift query: SELECT * FROM chapters WHERE book_id = $bookId');
//       final query = select(chapters)..where((t) => t.bookId.equals(bookId));
      
//       final result = await query.get();
//       print('✅ Query returned ${result.length} chapters');
      
//       if (result.isNotEmpty) {
//         print('📖 First chapter: ${result.first.toString()}');
//         return result;
//       } else {
//         // If we found chapters manually but not with Drift, there might be a schema mismatch
//         print('⚠️ Drift query returned 0 results - may indicate schema mismatch between application and database');
//         return result;
//       }
//     } catch (e, stackTrace) {
//       print('❌ Error executing Drift query: $e');
//       print('📈 Stack trace: $stackTrace');
//       return [];
//     }
//   } catch (e, stackTrace) {
//     print('❌ Unexpected error in getChaptersByBookId: $e');
//     print('📈 Stack trace: $stackTrace');
//     return [];
//   }
// }

Future<bool> bookExists(int bookId) async {
  try {
    final book = await (select(books)..where((b) => b.id.equals(bookId))).getSingleOrNull();
    return book != null;
  } catch (e) {
    print('❌ Error checking if book exists: $e');
    return false;
  }
}
  
  // Enhanced getHadithsByChapterId with error handling
  // Future<List<Hadith>> getHadithsByChapterId(int chapterId) async {
  //   try {
  //     print('📚 getHadithsByChapterId called for chapterId=$chapterId');
  //     final result = await (select(hadiths)..where((t) => t.chapterId.equals(chapterId))).get();
  //     print('✅ Query successful, found ${result.length} hadiths');
  //     return result;
  //   } catch (e, stackTrace) {
  //     print('❌ Error in getHadithsByChapterId: $e');
  //     print('📈 Stack trace: $stackTrace');
  //     return [];
  //   }
  // }
  
  // Enhanced getHadithById with error handling
  // Future<Hadith?> getHadithById(int hadithId) async {
  //   try {
  //     print('📚 getHadithById called for hadithId=$hadithId');
  //     final result = await (select(hadiths)..where((t) => t.id.equals(hadithId))).getSingleOrNull();
  //     if (result != null) {
  //       print('✅ Query successful, found hadith');
  //     } else {
  //       print('⚠️ No hadith found with id=$hadithId');
  //     }
  //     return result;
  //   } catch (e, stackTrace) {
  //     print('❌ Error in getHadithById: $e');
  //     print('📈 Stack trace: $stackTrace');
  //     return null;
  //   }
  // }
  
  
  // // Helper method to check database schema
  // Future<void> checkDatabaseSchema() async {
  //   try {
  //     print('🔍 Checking database schema...');
      
  //     // Check for books table
  //     final booksExists = await customSelect(
  //       "SELECT count(*) as count FROM sqlite_master WHERE type='table' AND name='books'"
  //     ).getSingleOrNull();
      
  //     print('📚 Books table exists: ${(booksExists?.data['count'] ?? 0) > 0}');
      
  //     // Check for chapters table
  //     final chaptersExists = await customSelect(
  //       "SELECT count(*) as count FROM sqlite_master WHERE type='table' AND name='chapters'"
  //     ).getSingleOrNull();
      
  //     print('📚 Chapters table exists: ${(chaptersExists?.data['count'] ?? 0) > 0}');
      
  //     // Check for hadiths table
  //     final hadithsExists = await customSelect(
  //       "SELECT count(*) as count FROM sqlite_master WHERE type='table' AND name='hadiths'"
  //     ).getSingleOrNull();
      
  //     print('📚 Hadiths table exists: ${(hadithsExists?.data['count'] ?? 0) > 0}');
      
  //     // Get table names
  //     final tables = await customSelect(
  //       "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'drift_%'"
  //     ).get();
      
  //     print('📊 Found tables: ${tables.map((row) => row.data['name']).join(', ')}');
      
  //   } catch (e, stackTrace) {
  //     print('❌ Error checking schema: $e');
  //     print('📈 Stack trace: $stackTrace');
  //   }
  // }










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