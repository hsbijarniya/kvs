import 'package:kvs/cipher.dart';
import 'package:kvs/kvs.dart';

void main() async {
  var localStorage = await KVS.init<String, int>(
    name: 'storeName',
    cipher: AESGCM256(key: 'mySecretKey'),
  );

  localStorage['year'] = 2023;
  localStorage['year']; // 2023
  localStorage.length; // 1
  localStorage.addAll({
    'month': 1,
    'date': 1,
  });
  localStorage.length; // 3
}
