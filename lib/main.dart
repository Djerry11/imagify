import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:dio/dio.dart';
import '../key.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final searchController = TextEditingController();
  var searchText = '';
  bool isloading = false;
  final dio = Dio();
  dynamic selectedImage;

  List<dynamic> imagesData = [];
  String baseUrl =
      'https://api.unsplash.com/search/photos/?client_id=$accessKey&';

  Future<void> _fetchImages(String searchText) async {
    try {
      final response = await dio.get("$baseUrl&query=$searchText&per_page=100");
      print('response: $response');

      if (response.statusCode == 200) {
        final data = response.data;

        setState(() {
          isloading = false;
          imagesData = data['results'];
        });
      } else {
        throw Exception('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching images: $e');
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 100, // Adjust the height of the AppBar
          title: Container(
            height: 50, // Adjust the height of the search bar
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25), // Apply border radius
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 54, 52, 52).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 2), // Shadow position
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {},
                    onSubmitted: (value) async {
                      setState(() {
                        isloading = true;
                      });
                      await _fetchImages(value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchText = '';
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        body: imagesData.isEmpty
            ? isloading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : const Center(child: Text('Search the images'))
            : MasonryGridView.builder(
                gridDelegate:
                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                itemCount: imagesData.length,
                itemBuilder: (BuildContext context, int index) => Container(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        setState(() {
                          selectedImage = imagesData[index];
                        });
                        _showEnlargeImageDialog(context, selectedImage);
                      });
                    },
                    // onTap: () {
                    //   setState(() {
                    //     isEnlarged = false;
                    //     selectedImageUrl = '';
                    //   });
                    // },
                    child: Hero(
                      tag: imagesData,
                      child: AspectRatio(
                        aspectRatio: imagesData[index]['width'] /
                            imagesData[index]['height'],
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: BlurHash(
                              hash: imagesData[index]['blur_hash'] ?? '',
                              image: imagesData[index]['urls']['regular'],
                              duration: const Duration(seconds: 2),
                            )),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void _showEnlargeImageDialog(BuildContext context, dynamic image) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        // Calculate the height based on the aspect ratio

        return Dialog(
          elevation: 10,
          insetAnimationCurve: Curves.bounceOut,
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 3,
                  color: Colors.white,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(14),
                ),
              ),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: image['width'] / image['height'],
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BlurHash(
                        hash: image['blur_hash'],
                        image: image['urls']['regular'],
                        duration: const Duration(milliseconds: 200),
                        imageFit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                      top: 2,
                      right: 1,
                      child: IconButton(
                        icon: const Icon(CupertinoIcons.cloud_download),
                        color: Colors.white,
                        iconSize: 30,
                        onPressed: () {},
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
