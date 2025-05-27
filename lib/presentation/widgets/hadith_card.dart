import 'package:flutter/material.dart';
import 'package:hadith/domain/entities/hadith_entity.dart';

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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              // Hadith header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Hadith ${hadith.hadithId ?? hadith.id.toString()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.bookmark_border, color: Colors.grey),
                  SizedBox(width: 8),
                  Icon(Icons.share, color: Colors.grey),
                ],
              ),
              SizedBox(height: 16),
              
              // Narrator section if available
              if (hadith.narrator != null && hadith.narrator!.isNotEmpty)
                Text(
                  hadith.narrator!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              
              SizedBox(height: 12),
              
              // Arabic text
              if (hadith.ar != null && hadith.ar!.isNotEmpty)
                Text(
                  hadith.ar!,
                  style: TextStyle(
                    fontFamily: 'Arabic',
                    fontSize: 18,
                    height: 1.5,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
              
              SizedBox(height: 16),
              
              // Bengali translation
              if (hadith.bn != null && hadith.bn!.isNotEmpty)
                Text(
                  hadith.bn!,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              
              SizedBox(height: 12),
              
              // Grade section if available
              if (hadith.grade != null && hadith.grade!.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Grade: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        hadith.grade!,
                        style: TextStyle(
                          color: hadith.gradeColor != null && hadith.gradeColor!.isNotEmpty
                              ? Color(int.parse('FF${hadith.gradeColor!.substring(1)}', radix: 16))
                              : Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: 12),
              
              // Book reference
              Text(
                'Reference: $bookName ${hadith.hadithId ?? hadith.id.toString()}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}