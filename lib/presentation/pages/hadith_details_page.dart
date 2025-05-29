import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hadith/core/themes/theme.dart';
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
    //final chapterTitle = args['chapterTitle'] as String;
    final bookId = args['bookId'] as int;

    // Get book information for display
    final book = bookController.getBookById(bookId);
    final bookName = book?.title ?? 'Hadith Book';
    final bookColor = book?.color ?? AppColors.primary;

    controller.setChapterId(chapterId);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              bookName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              "Revelation",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
            color: Color(0xFFF4F4F4),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.fromLTRB(12, 4, 12, 20),
          child: ListView(
            padding: EdgeInsets.only(top: 10, bottom: 24),
            children: [
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 14, height: 1.3),
                          children: [
                            TextSpan(
                              text: '$bookId/$chapterId Chapter: ',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "How the Divine Revelation started being revealed to Allah's Messenger",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF5D646F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 10,
                        color: Color(0xFFF4F4F4),
                        thickness: 1,
                      ),
                      Text(
                        'In publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content.',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF353535).withOpacity(0.5),
                          fontWeight: FontWeight.w400,
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

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
            leading: Container(
              width: 34,
              height: 37,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/polygon.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Text(
                  hadith.bookName!.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            title: RichText(
              text: TextSpan(
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                children: [
                  TextSpan(
                    text: "Hadith No: ",
                    style: TextStyle(color: Color(0xFF5D646F)),
                  ),
                  TextSpan(
                    text: hadith.id.toString().padLeft(2, '0'),
                    style: TextStyle(color: Color(0xFF1AA483)),
                  ),
                ],
              ),
            ),
            subtitle: Text(bookName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hadith.grade != null && hadith.grade!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: gradeColor,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      hadith.grade!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                SizedBox(width: 10),
                InkWell(
                  onTap: () => _showHadithOptions(context, hadith),
                  child: Icon(Icons.more_vert, color: Color(0xFF5D646F)),
                ),
              ],
            ),
          ),

          // Arabic content
          if (hadith.ar != null && hadith.ar!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                hadith.ar!,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'me_quran Regular',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

          // Narration info
          if (hadith.narrator != null && hadith.narrator!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
              child: Text(
                'It is narrated from ${hadith.narrator}:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),

          if (hadith.bn != null && hadith.bn!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                hadith.bn!,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
            ),

          // Reference footnote
          if (hadith.note != null && hadith.note!.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(12, 20, 12, 12),
              child: Text(
                hadith.note!,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF353535).withOpacity(.5),
                ),
              ),
            ),
        ],
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
                  title: Text('Hadith Copy'),
                  onTap: () {
                    Navigator.pop(context);
                    _copyHadith(hadith);
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
