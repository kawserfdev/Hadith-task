import 'package:flutter/material.dart';

class HadithBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'More Option',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildOptionItem(Icons.menu_book, 'Go To Main Hadith', Colors.teal),
          _buildOptionItem(Icons.bookmark_border, 'Add to Collection', Colors.teal),
          _buildOptionItem(Icons.language, 'Bangla Copy', Colors.teal),
          _buildOptionItem(Icons.language, 'English Copy', Colors.teal),
          _buildOptionItem(Icons.language, 'Arabic Copy', Colors.teal),
          _buildOptionItem(Icons.note_add_outlined, 'Add Hifz', Colors.teal),
          _buildOptionItem(Icons.note_add_outlined, 'Add Note', Colors.teal),
          _buildOptionItem(Icons.share, 'Share', Colors.teal),
          _buildOptionItem(Icons.report_problem_outlined, 'Report', Colors.teal),
        ],
      ),
    );
  }
  
  Widget _buildOptionItem(IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}