import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hadith/presentation/controllers/book_controller.dart';
import 'package:hadith/presentation/controllers/chapter_controller.dart';
import 'package:hadith/presentation/controllers/hadith_controller.dart';
import 'package:hadith/presentation/widgets/hadith_card.dart';

class HadithDetailsPage extends StatelessWidget {
  final HadithController controller = Get.find<HadithController>();
  final BookController bookController = Get.find<BookController>();
  final ChapterController chapterController = Get.find<ChapterController>();
  
  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final chapterId = args['chapterId'] as int;
    final chapterTitle = args['chapterTitle'] as String;
    final bookId = args['bookId'] as int;
    
    controller.setChapterId(chapterId);
    
    // Find book information
    final book = bookController.books.firstWhere((b) => b.id == bookId);
    
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              book.title!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Revelation',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (controller.hadiths.isEmpty) {
          return Center(child: Text('No hadiths available'));
        }
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chapter title section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1/1 Chapter: How the Divine Revelation started being revealed to Allah\'s Messenger',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'In publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // List of hadiths in this chapter
              ...controller.hadiths.map((hadith) => 
                HadithCard(hadith: hadith, bookName: book.title!)
              ).toList(),
              
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}








/*


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hadith_app/presentation/controllers/hadith_controller.dart';
import 'package:hadith_app/presentation/widgets/hadith_bottom_sheet.dart';

class HadithDetailsPage extends StatelessWidget {
  final HadithController controller = Get.find<HadithController>();
  
  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final chapterId = args['chapterId'] as int;
    final chapterTitle = args['chapterTitle'] as String;
    
    controller.setChapterId(chapterId);
    
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Sahih Bukhari'),
        subtitle: Text('Revelation'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (controller.hadiths.isEmpty) {
          return Center(child: Text('No hadiths available'));
        }
        
        // Taking the first hadith for demonstration
        final hadith = controller.hadiths.first;
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chapter title section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1/1 Chapter: $chapterTitle',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          hadith.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Hadith card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Hadith header
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text(
                            'B',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          'Hadith No: ${hadith.hadithNumber.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('Books Name'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Sahih',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                showHadithBottomSheet(context);
                              },
                              child: Icon(Icons.more_vert),
                            ),
                          ],
                        ),
                      ),
                      
                      // Arabic content
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          hadith.contentAr,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: 'Arabic',
                            fontSize: 22,
                            height: 1.5,
                          ),
                        ),
                      ),
                      
                      // Narration info
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'It is narrated from ${hadith.narrator} (may Allaah have mercy on him):',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      
                      // English content
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          hadith.content,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                      
                      // Reference footnote
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        child: Text(
                          '(See also 51, 2681, 2804, 2941, 2978, 3174, 4553, 5980, 6260, 7196, 7541) (Modern Publication: 6, Islamic Foundation: 6)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
  
  void showHadithBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => HadithBottomSheet(),
    );
  }
}


 */