import 'package:get/get.dart';
import 'package:hadith/domain/entities/chapter_entity.dart';
import 'package:hadith/domain/repositories/hadith_repository.dart';
import 'package:hadith/domain/repositories/hadith_repository_impl.dart';
import 'package:flutter/material.dart';

class ChapterController extends GetxController {
  final HadithRepository repository;

  ChapterController({required this.repository});

  final RxList<ChapterEntity> chapters = <ChapterEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedBookId = 0.obs;
  final RxBool showSampleButton = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isCreatingSamples = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(selectedBookId, (_) => fetchChapters());
  }

  void setBookId(int bookId) async {
    if (bookId <= 0) {
      return;
    }
    
    selectedBookId.value = bookId;

    if (repository is HadithRepositoryImpl) {
      try {
        await (repository as HadithRepositoryImpl).debugChapters(bookId);
      } catch (e) {
        print(' Error debugging chapters: $e');
      }
    }
  }

  Future<void> fetchChapters() async {
    if (selectedBookId.value <= 0) {
      return;
    }

    try {
      isLoading(true);
      errorMessage('');
      
      final bookExists = await repository.bookExists(selectedBookId.value);
      if (!bookExists) {
        errorMessage('Book not found');
        showSampleButton(false);
        chapters.clear();
        return;
      }
      
      final fetchedChapters = await repository.getChaptersByBookId(
        selectedBookId.value,
      );
      
      chapters.value = fetchedChapters;
      
      showSampleButton(chapters.isEmpty);
      
    } catch (e) {
      errorMessage('Failed to load chapters');
      showSampleButton(true);
    } finally {
      isLoading(false);
    }
  }
  
  Future<void> createSampleChapters() async {
    if (selectedBookId.value <= 0) {
      Get.snackbar(
        'Error',
        'Invalid book ID',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      isCreatingSamples(true);
      isLoading(true);
      
      Get.dialog(
        Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Creating sample chapters...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      
      bool success = false;
      
      if (repository is HadithRepositoryImpl) {
        final repo = repository as HadithRepositoryImpl;
        success = await repo.createSampleChapters(selectedBookId.value);
      } else {
        success = await repository.createSampleChapters(selectedBookId.value);
      }
      
      Get.back();
      
      if (success) {
        Get.snackbar(
          'Success',
          'Sample chapters created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
        
        await fetchChapters();
      } else {
        Get.snackbar(
          'Error',
          'Failed to create sample chapters',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); 
      
      Get.snackbar(
        'Error',
        'Failed to create sample chapters: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreatingSamples(false);
      isLoading(false);
    }
  }
  
  Future<void> refreshChapters() async {
    await fetchChapters();
  }
  
  Future<void> verifyChaptersTable() async {
    try {
      if (repository is HadithRepositoryImpl) {
        final repo = repository as HadithRepositoryImpl;
        await repo.verifyChaptersTable();
      } else {
        print('cannot verify chapters table');
      }
    } catch (e) {
      print('Error verifying chapters table: $e');
    }
  }
  
  bool get isDatabaseAvailable {
    if (repository is! HadithRepositoryImpl) return false;
    return (repository as HadithRepositoryImpl).database != null;
  }
  
  Future<void> exploreDatabaseStructure() async {
    try {
      if (repository is HadithRepositoryImpl) {
        final repo = repository as HadithRepositoryImpl;
        await repo.exploreAllTables();
      } else {
        print('cannot explore database structure');
      }
    } catch (e) {
      print(' Error exploring database structure: $e');
    }
  }
}





// import 'package:get/get.dart';
// import 'package:hadith/domain/entities/chapter_entity.dart';
// import 'package:hadith/domain/repositories/hadith_repository.dart';

// class ChapterController extends GetxController {
//   final HadithRepository repository;

//   ChapterController({required this.repository});

//   final RxList<ChapterEntity> chapters = <ChapterEntity>[].obs;
//   final RxBool isLoading = false.obs;
//   final RxInt selectedBookId = 0.obs;
//   final RxString errorMessage = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     ever(selectedBookId, (_) => fetchChapters());
//   }

//   void setBookId(int bookId) {
//     if (bookId <= 0) return;
//     selectedBookId.value = bookId;
//   }

//   Future<void> fetchChapters() async {
//     if (selectedBookId.value <= 0) return;

//     try {
//       isLoading(true);
//       errorMessage('');
      
//       final bookExists = await repository.bookExists(selectedBookId.value);
//       if (!bookExists) {
//         errorMessage('Book not found');
//         chapters.clear();
//         return;
//       }
      
//       chapters.value = await repository.getChaptersByBookId(selectedBookId.value);
//     } catch (e) {
//       errorMessage('Failed to load chapters');
//     } finally {
//       isLoading(false);
//     }
//   }
  
//   Future<void> refreshChapters() async {
//     await fetchChapters();
//   }
// }