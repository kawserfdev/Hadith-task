import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hadith/data/datasources/local/drift/database.dart';
import 'package:hadith/data/datasources/local/drift/database_helper.dart';
import 'package:hadith/domain/repositories/empty_hadith_repository.dart';
import 'package:hadith/domain/repositories/hadith_repository.dart';
import 'package:hadith/domain/repositories/hadith_repository_impl.dart';
import 'package:hadith/presentation/controllers/book_controller.dart';
import 'package:hadith/presentation/controllers/chapter_controller.dart';
import 'package:hadith/presentation/controllers/hadith_controller.dart';
import 'package:hadith/presentation/pages/chapters_page.dart';
import 'package:hadith/presentation/pages/diagnostic_page.dart';
import 'package:hadith/presentation/pages/hadith_details_page.dart';
import 'package:hadith/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting app initialization...');

  // Create a default repository that returns empty data
  HadithRepository repository = EmptyHadithRepository();

  try {
    // print('📚 Initializing database...');

    // // Check if database file exists in assets first
    // final dbExistsInAssets = await DatabaseHelper.checkDatabaseInAssets();
    // if (!dbExistsInAssets) {
    //   print('⚠️ Warning: Database file not found in assets!');
    // } else {
    //   // Initialize database and create repository

    // }
    await DatabaseHelper.initDatabase();

    print('🔄 Creating database instance...');
    final database = AppDatabase();

    // Specifically check database schema before trying to access data
    await database.checkDatabaseSchema();

    print('🔍 Verifying database connection...');
    final isValid = await database.verifyConnection();
    await database.checkDatabaseSchema();
    await database.dumpChaptersTable();

    if (!isValid) {
      print('❌ Database verification failed, will use empty repository');
    } else {
      // Test database access
      try {
        print('🔍 Testing database access...');
        final books = await database.getAllBooks();
        print('✅ Database access successful. Found ${books.length} books');

        // Create real repository if test was successful
        print('🔄 Creating repository instance...');
        repository = HadithRepositoryImpl(database);
        print('✅ Database and repository initialized successfully');
      } catch (e) {
        print('❌Error testing database access: $e');
        print('⚠️ Will continue with empty repository');
      }
    }
  } catch (e, stackTrace) {
    print('❌ Error during initialization: $e');
    print('📈 Stack trace: $stackTrace');
    print('⚠️ Will continue with empty repository');
  }

  // Register controllers with the repository (empty or real) 
  print('⚙️ Registering controllers...'); 
  Get.put(BookController(repository: repository), permanent: true); 
  Get.put(ChapterController(repository: repository), permanent: true); 
  Get.put(HadithController(repository: repository), permanent: true);

  print('✅ App initialization complete');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Al Hadith App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(elevation: 0, centerTitle: true),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => HomePage()),
        GetPage(name: '/chapters', page: () => ChaptersPage()),
        GetPage(name: '/hadith-details', page: () => HadithDetailsPage()),
        GetPage(name: '/diagnostics', page: () => DiagnosticPage()),
      ],
    );
  }
}
