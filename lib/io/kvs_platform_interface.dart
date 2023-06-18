import 'dart:io';
import 'package:path_provider/path_provider.dart';

class KVSPlatformInterface<K, V> {
  String name;
  String? documentDirectory;

  KVSPlatformInterface({
    this.name = 'default',
    this.documentDirectory,
  });

  /// Load data from disk
  read({bool raw = false}) async {
    documentDirectory ??= (await getApplicationDocumentsDirectory()).path;

    var file = File('$documentDirectory/kvs-$name.json');

    if (raw) {
      return await file.readAsBytes();
    } else {
      return await file.readAsString();
    }
  }

  /// Write data to disk
  write(dynamic data) async {
    var file = File('$documentDirectory/kvs-$name.json');

    if (data is List<int>) {
      await file.writeAsBytes(data, flush: true);
    } else {
      await file.writeAsString(data, flush: true);
    }
  }
}
