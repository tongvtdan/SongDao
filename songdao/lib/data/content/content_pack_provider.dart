import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/database_provider.dart';
import 'content_pack_importer.dart';

const defaultContentPackAssets = [
  '../content/packs/songdao-pack-calendar-vn-2026-0.2.0.json',
  '../content/packs/songdao-pack-parishes-vn-beta-2026-0.1.0.json',
];

final contentPackImporterProvider = Provider<ContentPackImporter>((ref) {
  return ContentPackImporter(ref.watch(databaseProvider));
});

final seedContentBootstrapProvider =
    FutureProvider<List<ContentPackImportResult>>((ref) async {
      final importer = ref.watch(contentPackImporterProvider);
      final results = <ContentPackImportResult>[];
      for (final asset in defaultContentPackAssets) {
        final source = await rootBundle.loadString(asset);
        results.add(await importer.importPackJson(source));
      }
      return results;
    });
