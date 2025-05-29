import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hadith/core/themes/theme.dart';
import 'package:hadith/presentation/controllers/book_controller.dart';

class HomePage extends StatelessWidget {
  final BookController controller = Get.find<BookController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Hadith Collections'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.fetchBooks(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Error message display
          Obx(() {
            if (controller.errorMessage.isNotEmpty) {
              return Container(
                padding: EdgeInsets.all(16),
                color: Colors.red.shade50,
                width: double.infinity,
                child: Text(
                  'Error: ${controller.errorMessage.value}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            return SizedBox();
          }),

          // Main content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.books.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No hadith books available'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.fetchBooks(),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.books.length,
                itemBuilder: (context, index) {
                  final book = controller.books[index];
                  Color bookColor = AppColors.primary; // Default
                  if (book.colorCode != null && book.colorCode!.isNotEmpty) {
                    try {
                      if (book.colorCode!.startsWith('#')) {
                        final colorValue = int.parse(
                          'FF${book.colorCode!.substring(1)}',
                          radix: 16,
                        );
                        bookColor = Color(colorValue);
                      }
                    } catch (e) {
                      print('Error parsing color: $e');
                    }
                  }
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Color(bookColor.value),
                        child: Text(
                          book.abvrCode!,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        book.title!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "${book.numberOfHadis} hadiths",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18),
                      onTap: () {
                        Get.toNamed(
                          '/chapters',
                          arguments: {'bookId': book.id},
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
