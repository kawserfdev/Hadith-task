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
    final dynamic arguments = Get.arguments;
    int bookId;

    if (arguments is Map<String, dynamic>) {
      bookId = arguments['bookId'] as int;
    } else if (arguments is int) {
      bookId = arguments;
    } else {
      throw ArgumentError(
        'Expected int or Map<String, dynamic> with bookId key',
      );
    }

    controller.setBookId(bookId);

    return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          BookEntity? book;
          try {
            if (bookController.books.isNotEmpty) {
              book = bookController.books.firstWhereOrNull(
                (b) => b.id == bookId,
              );
            }
          } catch (e) {
            print('Error finding book: $e');
          }

          return Text(book?.title ?? 'Chapters');
        }),
        centerTitle: true,
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

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 1,
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
                      chapter.bookName!,
                      style: TextStyle(fontSize: 14),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${chapter.hadisRange} hadiths",
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
