import 'package:get/get.dart';
import 'package:hadith/domain/entities/book_entity.dart';
import 'package:hadith/domain/repositories/hadith_repository.dart';

class BookController extends GetxController {
  final HadithRepository repository;  
  
  BookController({ required this.repository}); 
  
  final RxList<BookEntity> books = <BookEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    print(' BookController onInit called');
    fetchBooks();
  }
  
  Future<void> fetchBooks() async {
    try {
      isLoading(true);
      errorMessage('');
      
      final bookList = await repository.getAllBooks();
      
      books.value = bookList;
      
      for (var book in books) {
        print(' Book ID: ${book.id}, Title: ${book.title}');
      }
    } catch (e) {
      print(' Error fetching books: $e');
      
    } finally {
      isLoading(false);
    }
  }
  
  BookEntity? getBookById(int bookId) {
    try {
      return books.firstWhereOrNull((book) => book.id == bookId);
    } catch (e) {
      print(' Error finding book by ID $bookId: $e');
      return null;
    }
  }
}