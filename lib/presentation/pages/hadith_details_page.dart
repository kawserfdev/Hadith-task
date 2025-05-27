import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hadith/domain/entities/hadith_entity.dart';
import 'package:hadith/presentation/controllers/book_controller.dart';
import 'package:hadith/presentation/controllers/hadith_controller.dart';

class HadithPage extends StatelessWidget {
  final HadithController controller = Get.find<HadithController>();
  final BookController bookController = Get.find<BookController>();

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final chapterId = args['chapterId'] as int;
    final chapterTitle = args['chapterTitle'] as String;
    final bookId = args['bookId'] as int;

    // Get book information for display
    final book = bookController.getBookById(bookId);
    final bookName = book?.title ?? 'Hadith Book';
    final bookColor = book?.color ?? Colors.teal;

    controller.setChapterId(chapterId);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              bookName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              chapterTitle,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showChapterInfo(context, chapterTitle),
            tooltip: 'Chapter Information',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: bookColor),
                SizedBox(height: 16),
                Text(
                  'Loading hadiths...',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          );
        }

        if (controller.hadiths.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hadiths available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Try refreshing or selecting another chapter',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Icon(Icons.refresh),
                  label: Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bookColor,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => controller.fetchHadiths(),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.only(top: 16, bottom: 24),
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        'Chapter: $chapterTitle',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Book: $bookName',
                        style: TextStyle(
                          fontSize: 16,
                          color: bookColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Contains ${controller.hadiths.length} hadith(s)',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // List of hadiths
            ...controller.hadiths.map((hadith) {
              print("hadith: ${hadith}");
              return _buildHadithCard(context, hadith, bookName, bookColor);
            }).toList(),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSearchDialog(context),
        backgroundColor: bookColor,
        child: Icon(Icons.search),
        tooltip: 'Search in hadiths',
      ),
    );
  }

  Widget _buildHadithCard(
    BuildContext context,
    HadithEntity hadith,
    String bookName,
    Color bookColor,
  ) {
    // Choose a grade color based on hadith.grade
    Color gradeColor = bookColor;
    if (hadith.gradeColor != null && hadith.gradeColor!.isNotEmpty) {
      try {
        if (hadith.gradeColor!.startsWith('#')) {
          gradeColor = Color(
            int.parse('FF${hadith.gradeColor!.substring(1)}', radix: 16),
          );
        }
      } catch (e) {
        print('Error parsing grade color: $e');
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            // Hadith header
            ListTile(
              leading: CircleAvatar(
                backgroundColor: bookColor,
                child: Text(
                  hadith.hadithId.toString().padLeft(2, '0'),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                'Hadith No: ${hadith.hadithId ?? hadith.id.toString().padLeft(2, '0')}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(bookName),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hadith.grade != null && hadith.grade!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: gradeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hadith.grade!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showHadithOptions(context, hadith),
                    child: Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),

            // Arabic content
            if (hadith.ar != null && hadith.ar!.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  hadith.ar!,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Arabic',
                    fontSize: 22,
                    height: 1.5,
                  ),
                ),
              ),

            // Separator
            Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),

            // Narration info
            if (hadith.narrator != null && hadith.narrator!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                child: Text(
                  'It is narrated from ${hadith.narrator}:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: bookColor,
                  ),
                ),
              ),

            // Bengali/English content
            if (hadith.bn != null && hadith.bn!.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  hadith.bn!,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),

            // Reference footnote
            if (hadith.note != null && hadith.note!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  hadith.note!,
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ),

            // Action buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.bookmark_border, color: Colors.grey),
                    onPressed: () => _saveHadith(hadith),
                    tooltip: 'Save',
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.grey),
                    onPressed: () => _shareHadith(hadith),
                    tooltip: 'Share',
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: Colors.grey),
                    onPressed: () => _copyHadith(hadith),
                    tooltip: 'Copy',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChapterInfo(BuildContext context, String chapterTitle) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Chapter Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapterTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'This chapter contains a collection of authentic hadiths related to the given topic.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showHadithOptions(BuildContext context, HadithEntity hadith) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.bookmark_add),
                  title: Text('Save to Collection'),
                  onTap: () {
                    Navigator.pop(context);
                    _saveHadith(hadith);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share Hadith'),
                  onTap: () {
                    Navigator.pop(context);
                    _shareHadith(hadith);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Copy Text'),
                  onTap: () {
                    Navigator.pop(context);
                    _copyHadith(hadith);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.report_outlined),
                  title: Text('Report Issue'),
                  onTap: () {
                    Navigator.pop(context);
                    _reportIssue(hadith);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Search in Hadiths'),
            content: TextField(
              decoration: InputDecoration(
                hintText: 'Enter search term...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Search'),
              ),
            ],
          ),
    );
  }

  // Helper methods for hadith actions
  void _saveHadith(HadithEntity hadith) {
    Get.snackbar(
      'Saved',
      'Hadith ${hadith.hadithId} saved to collection',
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void _shareHadith(HadithEntity hadith) {
    String shareText = '';

    if (hadith.ar != null && hadith.ar!.isNotEmpty) {
      shareText += '${hadith.ar}\n\n';
    }

    if (hadith.narrator != null && hadith.narrator!.isNotEmpty) {
      shareText += 'Narrated by ${hadith.narrator}\n\n';
    }

    if (hadith.bn != null && hadith.bn!.isNotEmpty) {
      shareText += '${hadith.bn}\n\n';
    }

    shareText +=
        'Reference: ${hadith.bookName ?? 'Unknown'} ${hadith.hadithId ?? hadith.id.toString()}';

    Get.snackbar(
      'Share',
      'Sharing functionality not implemented in this demo',
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      backgroundColor: Colors.blue.withOpacity(0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void _copyHadith(HadithEntity hadith) {
    Get.snackbar(
      'Copied',
      'Hadith text copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      backgroundColor: Colors.grey.shade700.withOpacity(0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void _reportIssue(HadithEntity hadith) {
    Get.snackbar(
      'Report',
      'Reporting functionality not implemented in this demo',
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      backgroundColor: Colors.orange.withOpacity(0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }
}
