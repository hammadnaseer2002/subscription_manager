import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Un subscriptions ki ids jo hamesha ke liye delete ho chuki hain.
///
/// Drive backup purani file se merge hota hai, is liye agar ye ids yaad na
/// rakhi jayen to permanently delete ki hui subscription agle backup/restore
/// mein wapas aa jati. Ye list ek chhoti JSON file mein save hoti hai aur
/// backup file mein bhi ("deletedIds") jati hai.
class DeletedIdsStore {
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/permanently_deleted_ids.json');
  }

  Future<Set<String>> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return <String>{};
      final list = jsonDecode(await file.readAsString()) as List<dynamic>;
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> save(Set<String> ids) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(ids.toList()));
  }

  Future<void> add(String id) async {
    final ids = await load();
    ids.add(id);
    await save(ids);
  }
}