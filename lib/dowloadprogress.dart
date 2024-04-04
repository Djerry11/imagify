import 'package:flutter/material.dart';
import 'package:imagify/pick_directory.dart';

class DownloadProgressDialog extends StatefulWidget {
  const DownloadProgressDialog({
    super.key,
    required this.baseUrl,
    required this.fileName,
  });
  final String baseUrl;
  final String fileName;

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double progress = 0.0;

  @override
  void initState() {
    _startDownload(
      widget.baseUrl,
      widget.fileName,
    );
    super.initState();
  }

  void _startDownload(String baseUrl, String fileName) {
    FileDownload().startDownloading(
      context: context,
      okCallback: (recivedBytes, totalBytes) {
        setState(() {
          progress = recivedBytes / totalBytes;
        });
      },
      baseUrl: baseUrl,
      fileName: fileName,
    );
  }

  @override
  Widget build(BuildContext context) {
    String downloadingProgress = (progress * 100).toInt().toString();
    return AlertDialog(
        content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: const Text(
            "Downloading",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey,
          color: Colors.green,
          minHeight: 10,
          borderRadius: BorderRadius.circular(4),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            "$downloadingProgress %",
          ),
        )
      ],
    ));
  }
}
