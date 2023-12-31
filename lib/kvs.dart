library kvs;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:kvs/io/kvs_platform_interface.dart'
    if (dart.library.html) 'package:kvs/web/kvs_platform_interface.dart';
import 'cipher.dart';

Map<String, Completer<KVS>> _cache = {};

class KVS<K, V> extends KVSPlatformInterface<K, V> {
  late Map<K, V> data;
  Cipher? cipher;
  bool writeLock = false;
  int version = 0;

  KVS({
    super.name,
    super.documentDirectory,
    this.cipher,
  });

  /// Initialize instance of KVS of given [name].
  /// Encryption cipher custom or predefined can be provided using [cipher].
  static Future<KVS<K, V>> init<K, V>({
    String name = 'default',
    String? documentDirectory,
    Cipher? cipher,
    Map<K, V>? initialData,
  }) async {
    if (_cache.containsKey(name)) {
      return (_cache[name] as Completer<KVS<K, V>>).future;
    }

    var completer = _cache[name] = Completer<KVS<K, V>>();

    Map<K, V> data = {...(initialData ?? {})};

    WidgetsFlutterBinding.ensureInitialized();

    var kvs = KVS<K, V>(
      name: name,
      documentDirectory: documentDirectory,
      cipher: cipher,
    );

    String fileAsString;

    try {
      if (cipher != null) {
        var encryptedBytes = await kvs.read(raw: true);
        var decryptedBytes = await cipher.decrypt(encryptedBytes);

        fileAsString = utf8.decode(decryptedBytes);
      } else {
        fileAsString = await kvs.read();
      }

      data = {...data, ...jsonDecode(fileAsString)};
    } catch (error) {
      // implemention pending for
      // wrong key, corrupt data, file does not exists
    }

    kvs.data = data;

    completer.complete(kvs);

    return kvs;
  }

  /// Flush to changes to the disk
  flush() async {
    if (writeLock) return;

    writeLock = true;
    int writtenVersion = version;

    String fileAsString = jsonEncode(data);

    if (cipher != null) {
      var plainBytes = Uint8List.fromList(utf8.encode(fileAsString));
      var encryptedBytes = await cipher!.encrypt(plainBytes);

      await write(encryptedBytes);
    } else {
      await write(fileAsString);
    }

    writeLock = false;

    // if version changed in meantime flush it
    if (writtenVersion < version) {
      flush();
    }

    return true;
  }

  /// Get value of given key
  V? operator [](K key) => data[key];

  /// Update value of given key
  void operator []=(K key, V value) {
    data[key] = value;
    version++;

    flush();
  }

  /// Adds all key/value pairs of [other] to this map.
  /// If a key of [other] is already in this map, its value is overwritten.
  ///
  /// The operation is equivalent to doing this[key] = value for each key and associated value in other. It iterates over [other], which must therefore not change during the iteration.
  void addAll(Map<K, V> items) {
    data.addAll(items);
    flush();
  }

  /// Provides a view of this map as having [RK] keys and [RV] instances, if necessary.
  Map<RK, RV> cast<RK, RV>() => data.cast<RK, RV>();

  /// emoves all entries from the map.
  ///
  /// After this, the map is empty.
  void clear() {
    data.clear();
    flush();
  }

  /// Whether this map contains the given [key].
  bool containsKey(K key) => data.containsKey(key);

  /// Whether this map contains the given [value].
  bool containsValue(V value) => data.containsValue(value);

  /// Applies [action] to each key/value pair of the map.
  void forEach(void Function(K, V) action) => data.forEach(action);

  /// The keys of [this].
  ///
  /// The returned iterable has efficient length and contains operations, based on [length] and [containsKey] of the map.
  Iterable<K> get keys => data.keys;

  /// The number of key/value pairs in the map.
  int get length => data.length;

  /// Returns a new map where all entries of this map are transformed by the given [convert] function.
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K, V) convert) =>
      data.map(convert);

  /// The values of [this].
  ///
  /// The values are iterated in the order of their corresponding keys. This means that iterating [keys] and [values] in parallel will provide matching pairs of keys and values.
  Iterable<V> get values => data.values;
}
