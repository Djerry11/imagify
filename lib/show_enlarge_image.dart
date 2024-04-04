import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:imagify/dowloadprogress.dart';
import 'package:imagify/pick_directory.dart';
import 'package:permission_handler/permission_handler.dart';

void showEnlargeImageDialog(BuildContext context, dynamic image) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (BuildContext context) {
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
                    onPressed: () async {
                      Permission permission = Permission.manageExternalStorage;
                      bool result = await FileDownload.requestPermission(
                        permission,
                      );
                      if (result) {
                        showDialog(
                          context: context,
                          builder: (dialogcontext) {
                            return DownloadProgressDialog(
                              baseUrl: image['urls']['regular'],
                              fileName: '${image['id']}.jpg',
                            );
                          },
                        );
                      } else {
                        print("No permission to read and write.");
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
