import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {



  static Future<String> initDatabase() async {
    // Get the path to the app's document directory
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, 'hadith.db');
   // print('📚 Database path: $path');
    // Check if DB exists
    final file = File(path);
    if (!file.existsSync()) {
      print('🔄 Database not found, copying from assets...');
      // Create directory if it doesn't exist
      final dir = Directory(p.dirname(path));
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      
      try {
        // Copy from asset
        ByteData data = await rootBundle.load('assets/database/hadith.db');
        List<int> bytes = data.buffer.asUint8List();
        print('📊 Database size: ${bytes.length} bytes');
        
        // Write and flush the bytes
        await file.writeAsBytes(bytes, flush: true);
        print('Database copied successfully to: $path');
      } catch (e) {
        print('Error copying database from assets: $e');
        // More detailed error logging
        if (e is FileSystemException) {
          print('FileSystemException: ${e.message}, path: ${e.path}, osError: ${e.osError}');
        }
      }
    } else {
      print('Database already exists at: $path');
    }
    print('📚 Database initialization complete');
    print('📚 Database path: $path');
    return path;
  }


  static Future<bool> validateDatabase(String dbPath) async {
  try {
    final file = File(dbPath);
    if (!file.existsSync()) {
      print('❌ Database file does not exist at: $dbPath');
      return false;
    }
    
    final db = await openDatabase(dbPath);
    
    // Check if key tables exist
    final tablesResult = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('books', 'chapters', 'hadiths')"
    );
    
    final tables = tablesResult.map((row) => row['name']).toList();
    print('📊 Found tables: $tables');
    
    bool hasRequiredTables = tables.contains('books') && 
                             tables.contains('chapters') && 
                             tables.contains('hadiths');
                             
    if (!hasRequiredTables) {
      print('❌ Database is missing required tables');
      return false;
    }
    
    // Check if tables have data
    final booksCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM books'));
    print('📚 Books count: $booksCount');
    
    if (booksCount == 0) {
      print('⚠️ Warning: No books found in database');
    }
    
    return true;
  } catch (e) {
    print('❌ Error validating database: $e');
    return false;
  }
}
}