import 'export_delivery_io.dart'
    if (dart.library.html) 'export_delivery_web.dart'
    as impl;

class ExportDeliveryResult {
  final bool showMessage;
  final String message;

  const ExportDeliveryResult({
    required this.showMessage,
    required this.message,
  });
}

Future<ExportDeliveryResult> deliverExport(String jsonPayload) {
  return impl.deliverExport(jsonPayload);
}
