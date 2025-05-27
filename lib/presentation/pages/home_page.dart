import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hadith/presentation/controllers/book_controller.dart';

class HomePage extends StatelessWidget {
  final BookController controller = Get.find<BookController>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hadith Collections'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.fetchBooks(),
          )
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
                        child: Text('Retry')
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Get.toNamed('/diagnostics'), 
                        child: Text('Go to Diagnostics')
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: controller.books.length,
                itemBuilder: (context, index) {
                  final book = controller.books[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Color(book.colorCode!),
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
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18),
                      onTap: () {
                        Get.toNamed('/chapters', arguments: book.id);
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