import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'export_delivery.dart';

Future<ExportDeliveryResult> deliverExport(String jsonPayload) async {
  final dir = await getTemporaryDirectory();
  final ts = DateTime.now().millisecondsSinceEpoch;
  final file = File('${dir.path}/gutcheck_export_$ts.json');
  await file.writeAsString(jsonPayload);

  final isDesktop =
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS;

  if (isDesktop) {
    return ExportDeliveryResult(
      showMessage: true,
      message: 'Export saved to: ${file.path}',
    );
  }

  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)], subject: 'GutCheck Data Export'),
  );

  return const ExportDeliveryResult(showMessage: false, message: '');
}
