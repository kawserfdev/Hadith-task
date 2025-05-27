import 'package:flutter/material.dart';
import 'package:hadith/core/utils/text_utils.dart';
import 'package:hadith/domain/entities/hadith_entity.dart';
import 'package:hadith/presentation/widgets/hadith_bottom_sheet.dart';

class HadithCard extends StatelessWidget {
  final HadithEntity hadith;
  final String bookName;
  
  const HadithCard({
    Key? key,
    required this.hadith,
    required this.bookName,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                bookName.substring(0, 1),
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              'Hadith No: ${hadith.hadithId.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(bookName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorUtils.getHadithGradeColor(hadith.grade!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hadith.grade!,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => HadithBottomSheet(),
                    );
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
          
          // Narration info
          if (hadith.narrator!.isNotEmpty)
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
              hadith.bn!,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          
          // Reference footnote
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }
}