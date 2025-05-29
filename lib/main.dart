import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hadith/data/datasources/local/drift/database.dart';
import 'package:hadith/domain/repositories/empty_hadith_repository.dart';
import 'package:hadith/domain/repositories/hadith_repository.dart';
import 'package:hadith/domain/repositories/hadith_repository_impl.dart';
import 'package:hadith/presentation/controllers/book_controller.dart';
import 'package:hadith/presentation/controllers/chapter_controller.dart';
import 'package:hadith/presentation/controllers/hadith_controller.dart';
import 'package:hadith/presentation/pages/chapters_page.dart';
import 'package:hadith/presentation/pages/hadith_details_page.dart';
import 'package:hadith/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HadithRepository repository;

  try {
    final database = AppDatabase();
    repository = HadithRepositoryImpl(database);
  } catch (e) {
    repository = EmptyHadithRepository();
  }

  Get.put(BookController(repository: repository), permanent: true);
  Get.put(ChapterController(repository: repository), permanent: true);
  Get.put(HadithController(repository: repository), permanent: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      
      title: 'Al Hadith App',
      theme: ThemeData(
        primaryColor: const Color(0xFF1AA483),
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          elevation: 0,
          color: const Color(0xFF1AA483),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => HomePage()),
        GetPage(name: '/chapters', page: () => ChaptersPage()),
        GetPage(name: '/hadith-details', page: () => HadithPage()),
      ],
    );
  }
}
