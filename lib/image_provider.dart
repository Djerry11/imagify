import 'dart:async';
import 'package:dio/dio.dart';
import '../key.dart';

// class LoadingState extends ChangeNotifier {
//   bool isLoading = false;
//   bool isLoadingMore = false;

//   void setLoading(bool value) {
//     isLoading = value;
//     notifyListeners();
//   }

//   void setLoadingMore(bool value) {
//     notifyListeners();
//   }
// }

// final loadingProvider = ChangeNotifierProvider<LoadingState>((ref) {
//   return LoadingState();
// });

class ImagesProvider {
  final dio = Dio();
  final List<dynamic> _images = [];
  int _pageNumber = 1;
  bool _isLoadingMore = false;
  final _imagesController = StreamController<List<dynamic>>.broadcast();
  String _searchText = '';

  Stream<List<dynamic>> get imagesStream => _imagesController.stream;

  String baseUrl =
      'https://api.unsplash.com/search/photos/?client_id=$accessKey&';

  Future<void> fetchImages(String searchText) async {
    _searchText = searchText;
    _pageNumber = 1;
    try {
      final response = await dio
          .get("$baseUrl&page=$_pageNumber&query=$_searchText&per_page=10");

      if (response.statusCode == 200) {
        final data = response.data;

        _images.addAll(data['results']);
        _imagesController.sink.add(_images);
      } else {
        throw Exception('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  Future<void> fetchMoreImages() async {
    if (_isLoadingMore) return;

    _isLoadingMore = true;

    try {
      final response = await dio
          .get("$baseUrl&page=$_pageNumber&query=$_searchText&per_page=10");
      _pageNumber++;

      if (response.statusCode == 200) {
        final data = response.data;
        _images.addAll(data['results']);
        _imagesController.sink.add(_images);
      } else {
        throw Exception('Failed to load more images: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching more images: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get isLoadingMore => _isLoadingMore;

  void resetState() {
    _images.clear();
    _pageNumber = 1;
    _isLoadingMore = false;
  }

  void dispose() {
    _imagesController.close();
  }
}
