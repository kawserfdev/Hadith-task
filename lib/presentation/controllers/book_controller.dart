import 'package:get/get.dart';
import 'package:hadith/domain/entities/book_entity.dart';
import 'package:hadith/domain/repositories/hadith_repository.dart';

class BookController extends GetxController {
  final HadithRepository repository;  // Make this nullable
  
  BookController({ required this.repository});  // Make optional for safety
  
  final RxList<BookEntity> books = <BookEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    print('🔄 BookController onInit called');
    fetchBooks();
  }
  
  Future<void> fetchBooks() async {
    try {
      print('🔄 Fetching books...');
      isLoading(true);
      errorMessage('');
      
      print('📚 Calling repository.getAllBooks()');
      final bookList = await repository.getAllBooks();
      
      print('📊 Received ${bookList.length} books from repository');
      books.value = bookList;
      
      // For debugging: print all book titles
      for (var book in books) {
        print('📖 Book ID: ${book.id}, Title: ${book.title}');
      }
    } catch (e) {
      print('❌ Error fetching books: $e');
      if (e is TypeError) {
        print('❌ TypeError details: $e');
      }
      errorMessage('Failed to load books: $e');
      print('❌ Error in fetchBooks: $errorMessage');
    } finally {
      isLoading(false);
    }
  }
  
  BookEntity? getBookById(int bookId) {
    try {
      return books.firstWhereOrNull((book) => book.id == bookId);
    } catch (e) {
      print('❌ Error finding book by ID $bookId: $e');
      return null;
    }
  }
}