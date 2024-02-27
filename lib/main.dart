import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:aes_kma/aes/aes.dart';
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
  Uint8List generatedKey = Uint8List(0);
  String data = '';

  void _generateKey() {
    generatedKey = generateRandomKey();

    setState(() {});
  }

  Uint8List generateRandomKey() {
    Random random = Random.secure();
    List<int> randomBytes = List.generate(16, (index) => random.nextInt(256));

    return Uint8List.fromList(randomBytes);
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
            const SizedBox(height: 16),
            TextField(
              controller: inputController2,
              decoration: const InputDecoration(labelText: 'Input 2'),
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
          ],
        ),
      ),
    );
  }

  void encrypt() {
    var text = inputController1.text;
    final obj = AES.withIV(generateRandomKey(), generateRandomKey());

    while (text.length % 16 != 0) {
      text += " ";
    }

// Mã hóa văn bản thành mảng byte
    final result = obj.encrypt(Uint8List.fromList(utf8.encode(text)));

// Chuyển đổi kết quả thành chuỗi văn bản và cập nhật state
    setState(() {
      data = bitsToText(result);
    });
  }

  String bitsToText(Uint8List byteData) {
    String text = utf8.decode(byteData);
    return text;
  }

  Uint8List hexStringToBytes(String hexString) {
    // Chia chuỗi hexa thành các cặp ký tự
    Iterable<String> pairs = hexString.replaceAll(' ', '').split('');

    // Chuyển đổi các cặp ký tự thành các giá trị byte
    List<int> bytes =
        pairs.map((String hex) => int.parse(hex, radix: 16)).toList();

    // Chuyển đổi danh sách byte thành Uint8List
    return Uint8List.fromList(bytes);
  }
}
