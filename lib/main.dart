import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';



import 'package:aes_kma/algorithms/aes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AES Key Generator',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController inputController1 = TextEditingController();
  TextEditingController inputController2 = TextEditingController();
  String generatedKey = '';
  String data = '';
  String data2 = '';
  Duration duration = Duration();

  void _generateKey() {
    generatedKey = generateRandomKey(16);
    print("key: $generatedKey");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AES Key Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: inputController1,
              decoration: const InputDecoration(labelText: 'Input 1'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _generateKey,
              child: const Text('Generate Key'),
            ),
            const SizedBox(height: 24),
            Text(
              generatedKey.toString(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                encrypt();
              },
              child: const Text('Gen'),
            ),
            const SizedBox(height: 24),
            Text(
              data,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text(
              duration.toString(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 24,
            ),
            ElevatedButton(
              onPressed: () {
                decrypt();
              },
              child: const Text('Decrypt'),
            ),
            const SizedBox(height: 24),
            Text(
              data2,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void encrypt() {
    var text = inputController1.text;
    // final now = DateTime.now();
    // final AES aes = AES.withIV(Uint8List.fromList(generatedKey.codeUnits),
    //     Uint8List.fromList(generatedKey.codeUnits));

    // final rt = aes.CBC_encrypt(Uint8List.fromList(text.codeUnits));
    // setState(() {
    //   duration = DateTime.now().difference(now);
    //   data = convertBytesToString(rt);
    //   print(data);
    // });

    // Uint8List bytes = convertStringToBytes(generatedKey);
    // print("bytes: key:" + "$bytes");

    // var crypt = AesCrypt('my cool password');
    // crypt.aesSetKeys(bytes, bytes);
    // crypt.aesSetMode(AesMode.cbc);
    // // Invalid data length for AES: 13 bytes.
    // final encrypted = crypt.aesEncrypt(convertStringToBytes(text));
    // setState(() {
    //   data = convertBytesToString(encrypted);
    // });

    final aes = AES(generatedKey.codeUnits);
    final now = DateTime.now();
    final rt = aes.ecbEncrypt(text.codeUnits);
    print("rt: $rt");
    String test = convertBytesToString(convertStringToBytes(text));
    print("test: $test");

    setState(() {
      duration = DateTime.now().difference(now);
      data = convertBytesToString(rt);
      print(data);
    });
  }

  void decrypt() {
    var text = data;
    final aes = AES(Uint8List.fromList(generatedKey.codeUnits));
    final now = DateTime.now();
    final rt = aes.ecbDecrypt(convertStringToBytes(text));
    setState(
      () {
        duration = DateTime.now().difference(now);
        print(rt);
        data2 = convertBytesToString(rt);
        print(data2);
      },
    );
  }

  String generateRandomKey(int size) {
    Random random = Random();
    StringBuffer sb = StringBuffer();

    for (int i = 0; i < size; i++) {
      int randomNumber = random.nextInt(size);
      int randomChar = (randomNumber < 10)
          ? '0'.codeUnitAt(0) + randomNumber
          : 'a'.codeUnitAt(0) + randomNumber - 10;
      sb.write(String.fromCharCode(randomChar));
    }

    return sb.toString();
  }

  Uint8List convertStringToBytes(String text) {
    return base64.decode(text);
  }

  String convertBytesToString(Uint8List bytes) {
    return base64.encode(bytes);
  }
}
