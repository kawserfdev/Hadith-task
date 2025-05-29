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
      backgroundColor: Colors.teal,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(bookName, style: TextStyle()),
            Text(
              "Revelation",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                Icon(Icons.search_off, size: 64, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'No hadiths available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'No hadiths found for $chapterId chapter.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20, 0.0, 20, 16),
          child: ListView(
            padding: EdgeInsets.only(top: 16, bottom: 24),
            children: [
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                          children: [
                            TextSpan(
                              text: '$bookId/$chapterId Chapter: ',
                              style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: chapterTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 24),
                      Text(
                        'In publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // List of hadiths
              ...controller.hadiths.map((hadith) {
                return _buildHadithCard(context, hadith, bookName, bookColor);
              }).toList(),
            ],
          ),
        );
      }),
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
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            // Hadith header
            ListTile(
              leading: Container(
                width: 40,
                height: 45,
                //color: Colors.transparent,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/polygon.png'),
                  ),
                ),
                child: Center(
                  child: Text(
                    hadith.bookName!.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              //  CircleAvatar(
              //   backgroundColor: bookColor,
              //   child: Text(
              //     hadith.hadithId.toString().padLeft(2, '0'),
              //     style: TextStyle(color: Colors.white),
              //   ),
              // ),
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

  void _showHadithOptions(BuildContext context, HadithEntity hadith) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.65,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 4, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'More Option',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),

                ListTile(
                  leading: Icon(Icons.send_outlined),
                  title: Text('Go To Main Hadith'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bookmark_outline),
                  title: Text('Add to Collection'),
                  onTap: () {
                    Navigator.pop(context);
                    _saveHadith(hadith);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Bangla Copy'),
                  onTap: () {
                    Navigator.pop(context);
                    _copyBangla(hadith);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('English Copy'),
                  onTap: () {
                    Navigator.pop(context);
                    _copyEnglish(hadith);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Arabic Copy'),
                  onTap: () {
                    Navigator.pop(context);
                    _copyArabic(hadith);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.lock_outline),
                  title: Text('Add Hifz'),
                  onTap: () {
                    Navigator.pop(context);
                    _addHifz(hadith);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.note_add_outlined),
                  title: Text('Add Note'),
                  onTap: () {
                    Navigator.pop(context);
                    _addNote(hadith);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                  onTap: () {
                    Navigator.pop(context);
                    _shareHadith(hadith);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.report_outlined),
                  title: Text('Report'),
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

  void _copyBangla(HadithEntity hadith) {
    // Copy Bangla text to clipboard
    Get.snackbar(
      'Copied',
      'Bangla text copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      backgroundColor: Colors.grey.shade700.withOpacity(0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void _copyEnglish(HadithEntity hadith) {
    // Copy English text to clipboard
    Get.snackbar(
      'Copied',
      'English text copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      backgroundColor: Colors.grey.shade700.withOpacity(0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void _copyArabic(HadithEntity hadith) {
    // Copy Arabic text to clipboard
    Get.snackbar(
      'Copied',
      'Arabic text copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      backgroundColor: Colors.grey.shade700.withOpacity(0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void _addHifz(HadithEntity hadith) {
    Get.snackbar(
      'Hifz',
      'Hadith added to Hifz list',
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void _addNote(HadithEntity hadith) {
    Get.snackbar(
      'Note',
      'Note added for this hadith',
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      backgroundColor: Colors.blue.withOpacity(0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }
}
