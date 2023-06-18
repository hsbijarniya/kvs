High performance persistant memory key-value storage with AES256 encryption.

## Features
+ Persistant storage in document directory or directory provided.
+ Supports encryption on rest.
+ Can be used as Map alternative.

## Planned Features
+ Use IndexedDB instead of localStorage

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

## Add encryption to existing storage

```dart
var localStorage = await KVS.init<String, int>(
  name: 'storeName'
);

localStorage.cipher = AESGCM256(key: 'mySecretKey');
localStorage.flush();
```

## Remove encryption from existing storage

```dart
var localStorage = await KVS.init<String, int>(
  name: 'storeName',
  cipher: AESGCM256(key: 'mySecretKey'),
);

localStorage.cipher = null;
localStorage.flush();
```

## Change encryption key of existing storage

```dart
var localStorage = await KVS.init<String, int>(
  name: 'storeName',
  cipher: AESGCM256(key: 'oldSecretKey'),
);

localStorage.cipher = AESGCM256(key: 'newSecretKey');
localStorage.flush();
```