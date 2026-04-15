import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gutcheck/l10n/app_localizations.dart';

/// Show a scrollable error dialog with a Copy button that puts the error and
/// stack trace on the clipboard. Use for diagnosing runtime exceptions.
Future<void> showErrorDialog(
  BuildContext context,
  Object error, [
  StackTrace? stackTrace,
]) {
  final body = stackTrace != null ? '$error\n\n$stackTrace' : '$error';
  return showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      final l10n = AppLocalizations.of(dialogCtx)!;
      return AlertDialog(
        title: Text(l10n.genericError(error.runtimeType)),
        content: SingleChildScrollView(
          child: SelectableText(
            body,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(l10n.copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: body));
              if (dialogCtx.mounted) {
                ScaffoldMessenger.of(dialogCtx).showSnackBar(
                  SnackBar(
                    content: Text(l10n.copiedToClipboard),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.ok),
          ),
        ],
      );
    },
  );
}
