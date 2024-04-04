import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:imagify/image_provider.dart';
import 'package:imagify/show_enlarge_image.dart';

class ImageList extends StatefulWidget {
  final ImagesProvider imageProvider;

  const ImageList({super.key, required this.imageProvider});

  @override
  State<ImageList> createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreImages);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreImages() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      widget.imageProvider.fetchMoreImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: widget.imageProvider.imagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Djher: waiting loaidnig');
          //delay by 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
        }

        final images = snapshot.data!;

        return MasonryGridView.builder(
            controller: _scrollController,
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: images.length + 1,
            itemBuilder: (context, index) {
              if (index == images.length) {
                return widget.imageProvider.isLoadingMore
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const SizedBox.shrink();
              }

              if (index < images.length) {
                final image = images[index];
                return Container(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      showEnlargeImageDialog(context, image);
                    },
                    child: Hero(
                      tag: image,
                      child: AspectRatio(
                        aspectRatio: image['width'] / image['height'],
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: BlurHash(
                            hash: image['blur_hash'] ?? '',
                            image: image['urls']['regular'],
                            duration: const Duration(seconds: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            });
      },
    );
  }
}
