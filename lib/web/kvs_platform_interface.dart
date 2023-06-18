import 'dart:convert';
import 'dart:html';

class KVSPlatformInterface<K, V> {
  String name;
  String? documentDirectory;

  KVSPlatformInterface({
    this.name = 'default',
    this.documentDirectory,
  });

  /// Load data from disk
  read({bool raw = false}) async {
    if (raw) {
      return base64Decode(window.localStorage['kvs-$name.json'] ?? '');
    } else {
      return window.localStorage['kvs-$name.json'] ?? '';
    }
  }

  /// Write data to disk
  write(dynamic data) async {
    if (data is List<int>) {
      window.localStorage['kvs-$name.json'] = base64Encode(data);
    } else {
      window.localStorage['kvs-$name.json'] = data;
    }
  }
}
