import 'package:flutter/material.dart';

import 'ocr_camera_page.dart';

Future<Map<String, String>?> showOcrScreen(
    BuildContext context, List<String> properties,
    {bool singleMode = false,
    String? title,
    String? titleCameraButton,
    String? titleSelectText}) async {
  return await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => OcrCameraPage(
            properties: properties,
            singleMode: singleMode,
            title: title ?? "Scan text",
            titleCameraButton: titleCameraButton ?? "Scan",
            titleSelectText: titleSelectText ?? "Select text",
          )));
}
