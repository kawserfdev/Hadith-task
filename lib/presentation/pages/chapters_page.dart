import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hadith/domain/entities/book_entity.dart';
import 'package:hadith/presentation/controllers/book_controller.dart';
import 'package:hadith/presentation/controllers/chapter_controller.dart';

class ChaptersPage extends StatelessWidget {
  final ChapterController controller = Get.find<ChapterController>();
  final BookController bookController = Get.find<BookController>();

  @override
  Widget build(BuildContext context) {
    final bookId = Get.arguments as int;
    controller.setBookId(bookId);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          // Safely find the book
          BookEntity? book;
          try {
            if (bookController.books.isNotEmpty) {
              // Use firstWhereOrNull to avoid exceptions if book isn't found
              book = bookController.books.firstWhereOrNull(
                (b) => b.id == bookId,
              );
            }
          } catch (e) {
            print('Error finding book: $e');
          }

          return Text('${book?.title ?? 'Chapters'} Chapters');
        }),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.chapters.isEmpty) {
          return Center(child: Text('No chapters available'));
        }

        return ListView.builder(
          itemCount: controller.chapters.length,
          itemBuilder: (context, index) {
            final chapter = controller.chapters[index];
            final hadithCount =
                chapter.hadisRange!
                    .split('-')
                    .last; 
                    //! - chapter.hadithStartNumber! + 1;

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  chapter.title!,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text(
                      chapter.title!,
                      style: TextStyle(fontFamily: 'Arabic', fontSize: 14),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "$hadithCount hadiths",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                onTap: () {
                  Get.toNamed(
                    '/hadith-details',
                    arguments: {
                      'chapterId': chapter.id,
                      'chapterTitle': chapter.title,
                      'bookId': bookId,
                    },
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
