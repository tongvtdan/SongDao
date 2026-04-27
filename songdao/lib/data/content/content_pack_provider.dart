import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/database_provider.dart';
import 'content_pack_importer.dart';

const defaultContentPackAsset =
    '../content/packs/songdao-pack-calendar-vn-demo-2026-0.1.0.json';

final contentPackImporterProvider = Provider<ContentPackImporter>((ref) {
  return ContentPackImporter(ref.watch(databaseProvider));
});

final seedContentBootstrapProvider = FutureProvider<ContentPackImportResult>((
  ref,
) async {
  final importer = ref.watch(contentPackImporterProvider);
  final source = await rootBundle.loadString(defaultContentPackAsset);
  return importer.importPackJson(source);
});
