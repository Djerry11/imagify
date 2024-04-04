import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';

class FileDownload {
  Dio dio = Dio();
  bool isSuccess = false;

  void startDownloading(
      {required BuildContext context,
      required final Function okCallback,
      required String baseUrl,
      required String fileName}) async {
    String? path = await getDownloadPath();
    if (path == null) {
      return;
    } else {
      path = "$path/$fileName";
    }

    try {
      await dio.download(
        baseUrl,
        path,
        onReceiveProgress: (recivedBytes, totalBytes) {
          okCallback(recivedBytes, totalBytes);
        },
        deleteOnError: true,
      ).then((_) {
        isSuccess = true;
      });
    } catch (e) {
      debugPrint("Exception$e");
    }

    if (isSuccess) {
      Navigator.pop(context);
    }
  }

  Future<String?> getDownloadPath() async {
    final pathBox = await Hive.openBox('DownloadPath');
    String? path = await pathBox.get('savedPath');
    if (path != null) {
      pathBox.close();
      return path;
    } else {
      final result = await FilePicker.platform.getDirectoryPath();
      pathBox.put('savedPath', result);
      pathBox.close();
      return result;
    }
  }

  static Future<bool> requestPermission(Permission permission) async {
    print('Permission :${permission.status}');
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }
}
