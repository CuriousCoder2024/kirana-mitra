import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/api_client.dart';
import '../assets/item_photos.dart';
import '../l10n/app_localizations.dart';
import '../theme/theme.dart';
import 'lang_chip.dart';

/// Picks one of the bundled sample shelf photos (web and desktop have no
/// camera; Android offers it as a second choice). Returns the JPEG bytes
/// exactly as a camera photo would be sent.
Future<UploadBlob?> showSampleShelfSheet(BuildContext context) {
  return showModalBottomSheet<UploadBlob?>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _SampleShelfSheet(),
  );
}

class _SampleShelfSheet extends StatelessWidget {
  const _SampleShelfSheet();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: 12),
            Text(l.sampleShelfTitle, style: KmText.sheetTitle),
            const SizedBox(height: 4),
            Text(l.sampleShelfHint, style: KmText.caption),
            const SizedBox(height: 12),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 4 / 3,
                ),
                itemCount: kSampleShelves.length,
                itemBuilder: (context, i) {
                  final s = kSampleShelves[i];
                  final path = 'assets/shelves/${s.id}.jpg';
                  return Semantics(
                    button: true,
                    label: s.title,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(KmRadius.field),
                        onTap: () async {
                          final data = await rootBundle.load(path);
                          if (!context.mounted) return;
                          Navigator.of(context).pop(UploadBlob(
                            bytes: data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
                            filename: '${s.id}.jpg',
                            mimeType: 'image/jpeg',
                          ));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(KmRadius.field),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(path, fit: BoxFit.cover, cacheWidth: 480),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  color: KmColors.ink.withValues(alpha: 0.55),
                                  child: Text(
                                    s.title,
                                    style: KmText.status.copyWith(color: KmColors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Android: camera first, sample shelf second. Returns 'camera', 'sample'
/// or null.
Future<String?> showPhotoSourceSheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<String>(
    context: context,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: 12),
            Text(l.dockPhoto, style: KmText.sheetTitle),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, size: 28, color: KmColors.saffron),
              title: Text(l.takePhoto, style: KmText.bodyBold),
              onTap: () => Navigator.of(context).pop('camera'),
            ),
            ListTile(
              leading: const Icon(Icons.collections_outlined, size: 28, color: KmColors.saffron),
              title: Text(l.sampleShelf, style: KmText.bodyBold),
              onTap: () => Navigator.of(context).pop('sample'),
            ),
          ],
        ),
      ),
    ),
  );
}
