import 'package:get/get.dart';
import 'package:hadith/domain/entities/chapter_entity.dart';
import 'package:hadith/domain/repositories/hadith_repository.dart';

class ChapterController extends GetxController {
  final HadithRepository repository;
  
  ChapterController({required this.repository});
  
  final RxList<ChapterEntity> chapters = <ChapterEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedBookId = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    // The book ID will be passed when navigating to the Chapters page
  }
  
void setBookId(int bookId) async {
  selectedBookId.value = bookId;
  
  // Check if the book exists
  final exists = await repository.bookExists(bookId);
  if (!exists) {
    print('⚠️ Attempting to load chapters for non-existent bookId=$bookId');
  }
  
  fetchChapters();
}
  
  Future<void> fetchChapters() async {
    if (selectedBookId.value == 0) return;
    
    try {
      isLoading(true);
      chapters.value = await repository.getChaptersByBookId(selectedBookId.value);
    } catch (e) {
      print('Error fetching chapters: $e');
    } finally {
      isLoading(false);
    }
  }
}
