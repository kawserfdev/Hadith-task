import 'package:get/get.dart';
import 'package:hadith/domain/entities/hadith_entity.dart';
import 'package:hadith/domain/repositories/hadith_repository.dart';

class HadithController extends GetxController {
  final HadithRepository repository;
  
  HadithController({ required this.repository});
  
  final RxList<HadithEntity> hadiths = <HadithEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedChapterId = 0.obs;
  final Rx<HadithEntity?> selectedHadith = Rx<HadithEntity?>(null);
  
  @override
  void onInit() {
    super.onInit();
  }
  
  void setChapterId(int chapterId) {
    selectedChapterId.value = chapterId;
    fetchHadiths();
  }
  
  Future<void> fetchHadiths() async {
    if (selectedChapterId.value == 0) return;
    
    try {
      isLoading(true);
      hadiths.value = await repository.getHadithsByChapterId(selectedChapterId.value);
    } catch (e) {
      print('Error fetching hadiths: $e');
    } finally {
      isLoading(false);
    }
  }
  
  Future<void> fetchHadithById(int hadithId) async {
    try {
      isLoading(true);
      selectedHadith.value = await repository.getHadithById(hadithId);
    } catch (e) {
      print('Error fetching hadith: $e');
    } finally {
      isLoading(false);
    }
  }
}

