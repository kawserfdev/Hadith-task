import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {



  static Future<String> initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, 'hadith.db');
   
    final file = File(path);
    if (!file.existsSync()) {
      final dir = Directory(p.dirname(path));
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      
      try {
        // Copy from asset
        ByteData data = await rootBundle.load('assets/database/hadith.db');
        List<int> bytes = data.buffer.asUint8List();
        
        // Write and flush the bytes
        await file.writeAsBytes(bytes, flush: true);
      } catch (e) {
        if (e is FileSystemException) {
        }
      }
    } else {
      print('Database file already exists at: $path');
    }
    return path;
  }


  static Future<bool> validateDatabase(String dbPath) async {
  try {
    final file = File(dbPath);
    if (!file.existsSync()) {
      print('Database file does not exist at: $dbPath');
      return false;
    }
    
    final db = await openDatabase(dbPath);
    
    // Check if key tables exist
    final tablesResult = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('books', 'chapter', 'hadith')"
    );
    
    final tables = tablesResult.map((row) => row['name']).toList();
    
    bool hasRequiredTables = tables.contains('books') && 
                             tables.contains('chapter') && 
                             tables.contains('hadith');
                             
    if (!hasRequiredTables) {
      print('Database is missing required tables');
      return false;
    }
    
    // Check if tables have data
    final booksCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM books'));
    print('Books count: $booksCount');
    
    if (booksCount == 0) {
      print('Warning: No books found in database');
    }
    
    return true;
  } catch (e) {
    print(' Error validating database: $e');
    return false;
  }
}
}