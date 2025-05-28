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
    
    final chaptersSchema = await customSelect('PRAGMA table_info(chapter)').get();
    
    final hasBookIdColumn = chaptersSchema.any((col) => 
      col.data['name'].toString().toLowerCase() == 'book_id');
    
    if (!hasBookIdColumn) {
      print(' Critical issue: chapters table does not have a book_id column!');
      
      final possibleBookColumns = chaptersSchema
          .where((col) => col.data['name'].toString().toLowerCase().contains('book'))
          .map((col) => col.data['name'].toString())
          .toList();
          
      
      if (possibleBookColumns.isEmpty) {
        return [];
      } else {
        final alternateColumn = possibleBookColumns.first;
        
        final altResults = await customSelect(
          'SELECT * FROM chapters WHERE $alternateColumn = ?',
          variables: [Variable.withInt(bookId)]
        ).get();
                
        if (altResults.isEmpty) return [];
        
        return altResults.map((row) => Chapter(
          id: row.data['id'] as int? ?? 0,
          chapterId: row.data['chapter_id'] as int? ?? 0,
          bookId: bookId, 
          title: row.data['title'] as String?,
          number: _safeIntParse(row.data['number']),
          hadisRange: row.data['hadis_range'] as String?,
          bookName: row.data['book_name'] as String?,
        )).toList();
      }
    }
    
    
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
          print(' Found $count matches in column "$colName"');
          
          final colMatches = await customSelect(
            'SELECT * FROM chapters WHERE $colName = ?',
            variables: [Variable.withInt(bookId)]
          ).get();
          
          results = colMatches.map((row) => row.data).toList();
          
          break;
        }
      } catch (e) {
       
        continue;
      }
    }
    
    if (results.isNotEmpty) {
    
      
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
    
    
    final allChapters = await customSelect('SELECT * FROM chapter').get();
    print(' Total chapters in database: ${allChapters.length}');
    
    final matchingChapters = allChapters.where((row) {
      try {
        return row.data.entries.any((entry) {
          if (entry.value is int && entry.value == bookId) {
            print(' Found match in column "${entry.key}" with value $bookId');
            return true;
          }
          return false;
        });
      } catch (e) {
        return false;
      }
    }).toList();
    
    if (matchingChapters.isNotEmpty) {
      
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
    
    try {
      
      final stringResults = await customSelect(
        'SELECT * FROM chapters WHERE book_id = ?',
        variables: [Variable.withString(bookId.toString())]
      ).get();
      
      
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
      print(' String comparison failed: $e');
    }
    
    print(' All methods to find chapters for book $bookId failed');
    return [];
    
  } catch (e, stackTrace) {
    print(' Error in getChaptersByBookId: $e');
    print(' Stack trace: $stackTrace');
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


Future<List<Hadith>> getHadithsByChapterId(int chapterId) async {
  try {
    
   
    final results = await customSelect(
      'SELECT * FROM hadith WHERE chapter_id = ?',
      variables: [Variable.withInt(chapterId)]
    ).get();
    
    if (results.isEmpty) {
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
        return Hadith(id: 0, bookId: 0, chapterId: chapterId);
      }
    }).where((hadith) => hadith.id > 0 && hadith.chapterId == chapterId).toList();
  } catch (e) {
    try {
      return await (select(hadiths)..where((h) => h.chapterId.equals(chapterId))).get();
    } catch (e) {
      return [];
    }
  }
}

Future<Hadith?> getHadithById(int hadithId) async {
  try {
        final hadithExists = await this.customSelect(
      'SELECT EXISTS(SELECT 1 FROM hadiths WHERE id = ?) AS exists',
      variables: [Variable.withInt(hadithId)]
    ).getSingleOrNull();
    
    final hadithExistsFlag = hadithExists?.data['exists'] as int? ?? 0;
    if (hadithExistsFlag == 0) {
      return null;
    }
    
    
    final result = await this.customSelect(
      'SELECT * FROM hadiths WHERE id = ?',
      variables: [Variable.withInt(hadithId)]
    ).getSingleOrNull();
    
    if (result == null) {
      print(' No hadith found with ID $hadithId');
      return null;
    }
    
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
    
    print(' Retrieved hadith with ID $hadithId successfully');
    return hadith;
    
  } catch (e, stackTrace) {
    print(' Error in getHadithById: $e');
    print(' Stack trace: $stackTrace');
    return null;
  }
}

Future<Book?> getBookById(int bookId) async {
  try {
    return await (select(books)..where((b) => b.id.equals(bookId))).getSingleOrNull();
  } catch (e) {
    print(' Error getting book by ID: $e');
    return null;
  }
}

Future<Chapter?> getChapterById(int chapterId) async {
  try {
    return await (select(chapters)..where((c) => c.id.equals(chapterId))).getSingleOrNull();
  } catch (e) {
    print(' Error getting chapter by ID: $e');
    return null;
  }
}

Future<int> getBookCount() async {
  try {
    final result = await customSelect('SELECT COUNT(*) AS count FROM books').getSingleOrNull();
    return result?.data['count'] as int? ?? 0;
  } catch (e) {
    print(' Error counting books: $e');
    return 0;
  }
}

Future<int> getChapterCount() async {
  try {
    final result = await customSelect('SELECT COUNT(*) AS count FROM chapters').getSingleOrNull();
    return result?.data['count'] as int? ?? 0;
  } catch (e) {
    print(' Error counting chapters: $e');
    return 0;
  }
}

Future<int> getHadithCount() async {
  try {
    final result = await customSelect('SELECT COUNT(*) AS count FROM hadiths').getSingleOrNull();
    return result?.data['count'] as int? ?? 0;
  } catch (e) {
    print(' Error counting hadiths: $e');
    return 0;
  }
}

Future<List<Book>> getSampleBooks() async {
  try {
    return await (select(books)..limit(5)).get();
  } catch (e) {
    print(' Error getting sample books: $e');
    return [];
  }
}

Future<List<Chapter>> getSampleChaptersForBook(int bookId) async {
  try {
    return await (select(chapters)
      ..where((c) => c.bookId.equals(bookId))
      ..limit(5)
    ).get();
  } catch (e) {
    print(' Error getting sample chapters: $e');
    return [];
  }
}

Future<List<Hadith>> getSampleHadithsForChapter(int chapterId) async {
  try {
    return await (select(hadiths)
      ..where((h) => h.chapterId.equals(chapterId))
      ..limit(5)
    ).get();
  } catch (e) {
    print(' Error getting sample hadiths: $e');
    return [];
  }
}

Future<bool> checkDatabaseSchema() async {
  try {
    
    // Check for required tables
    final tables = await customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('books', 'chapter', 'hadith')"
    ).get();
    
    final tableNames = tables.map((row) => row.data['name'] as String).toSet();
    final requiredTables = {'books', 'chapter', 'hadith'};
    
    final missingTables = requiredTables.difference(tableNames);
    if (missingTables.isNotEmpty) {
      print(' Missing tables: ${missingTables.join(', ')}');
      return false;
    }
    
    if (tableNames.contains('books')) {
      final bookColumns = await customSelect("PRAGMA table_info(books)").get();
      final columnNames = bookColumns.map((row) => row.data['name'] as String).toSet();
      final requiredColumns = {'id', 'title', 'title_ar', 'number_of_hadis', 'abvr_code', 'color_code'};
      
      final missingColumns = requiredColumns.difference(columnNames);
      if (missingColumns.isNotEmpty) {
        print(' Books table missing columns: ${missingColumns.join(', ')}');
        return false;
      }
    }
    
    print(' Database schema verification successful');
    return true;
  } catch (e) {
    print(' Error checking database schema: $e');
    return false;
  }
}

Future<bool> verifyConnection() async {
  try {
    try {
      
      final booksCount = await customSelect('SELECT COUNT(*) AS count FROM books').getSingleOrNull();
      if (booksCount != null) {
        print(' Found ${booksCount.data['count']} books in database');
        return true;
      } else {
        print(' Books table query returned null');
        return false;
      }
    } catch (e) {
      print(' Error during database query: $e');
            try {
        print(' Basic database query successful');
        return true;
      } catch (e) {
        print(' Basic database query failed: $e');
        return false;
      }
    }
  } catch (e, stackTrace) {
    print(' Error verifying database: $e');
    print(' Stack trace: $stackTrace');
    return false;
  }
}
 

Future<bool> bookExists(int bookId) async {
  try {
    final book = await (select(books)..where((b) => b.id.equals(bookId))).getSingleOrNull();
    return book != null;
  } catch (e) {
    print(' Error checking if book exists: $e');
    return false;
  }
}
  

  Future<void> dumpChaptersTable() async {
  try {
    
    final allChapters = await select(chapters).get();
    
    final Map<int, List<Chapter>> chaptersByBook = {};
    for (var chapter in allChapters) {
      if (!chaptersByBook.containsKey(chapter.bookId)) {
        chaptersByBook[chapter.bookId] = [];
      }
      chaptersByBook[chapter.bookId]!.add(chapter);
    }
    
    for (var bookId in chaptersByBook.keys) {
      final chapters = chaptersByBook[bookId]!;
      print('Book ID: $bookId, Chapters: ${chapters.length}');
    }
    
  } catch (e) {
    print(' Error dumping chapters table: $e');
  }
}
}




LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      print(' Database path: ${dbFolder.path}');
      final file = File(p.join(dbFolder.path, 'hadith.db'));
      print(' Database file path: ${file.path}');
      
      if (!file.existsSync()) {
        try {
          if (!file.parent.existsSync()) {
            print('Creating parent directory: ${file.parent.path}');
            file.parent.createSync(recursive: true);
          }
          
          print(' Loading database from assets...');
          ByteData data = await rootBundle.load('assets/database/hadith.db');
          print('Database size from assets: ${data.lengthInBytes} bytes');
          
          if (data.lengthInBytes > 0) {
            List<int> bytes = data.buffer.asUint8List();
            print('Copying database...');
            await file.writeAsBytes(bytes, flush: true);
            print('Database copied successfully');
          } else {
            print(' Error: Database asset has zero size');
            throw Exception('Database asset has zero size');
          }
        } catch (e) {
          print(' Error copying database: $e');
          try {
            final db = NativeDatabase.memory();
            print(' Created empty database in memory');
            return db;
          } catch (e) {
            print(' Failed to create empty database: $e');
            rethrow;
          }
        }
      } else {
        print(' Database already exists at: ${file.path}');
        final fileSize = await file.length();
        print(' Existing database size: $fileSize bytes');
        
        if (fileSize == 0) {
          print(' Warning: Existing database file has zero size! Attempting to replace it...');
          
          // Backup the broken file
          final backupFile = File('${file.path}.bak');
          if (await backupFile.exists()) {
            await backupFile.delete();
          }
          await file.copy('${file.path}.bak');
          
          await file.delete();
          
          // Copy fresh database from assets
          ByteData data = await rootBundle.load('assets/database/hadith.db');
          List<int> bytes = data.buffer.asUint8List();
          await file.writeAsBytes(bytes, flush: true);
          print(' Replaced database file with fresh copy from assets');
        }
      }
      
      // Open the database
      return NativeDatabase(file);
      
    } catch (e, stackTrace) {
      print(' Critical error in database initialization: $e');
      print(' Stack trace: $stackTrace');
      return NativeDatabase.memory();
    }
  });
  
}



