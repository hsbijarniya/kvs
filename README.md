High performance persistant memory key-value storage with AES256 encryption.

## Features

+ Persistant storage in document directory or directory provided.
+ Supports encryption on rest.
+ Can be used as Map alternative.

## Usage

```dart
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
```