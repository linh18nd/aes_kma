import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:aes_kma/src/crypt.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AES Key Generator',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController inputController1 = TextEditingController();
  TextEditingController inputController2 = TextEditingController();
  String generatedKey = '';
  String encryptedData = '';
  String decryptedData = '';
  Duration duration = Duration();
  final crypt = AesCrypt('my cool password');

  @override
  void initState() {
    generatedKey = generateRandomKey(128);
    Uint8List key = Uint8List.fromList(
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]);
    crypt.aesSetKeys(key, key);
    crypt.aesSetMode(AesMode.cbc);
    super.initState();
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
            Text(
              generatedKey.toString(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                encrypt();
              },
              child: const Text('Encrypt'),
            ),
            const SizedBox(height: 24),
            Text(
              encryptedData,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                decrypt();
              },
              child: const Text('Decrypt'),
            ),
            const SizedBox(height: 24),
            Text(
              decryptedData,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void encrypt() {
    final data = stringToListInt(inputController1.text);
    final dt = crypt.aesEncrypt(Uint8List.fromList(data));
    print(dt);
    final encryptedString = base64.encode(dt);
    setState(() {
      encryptedData = encryptedString;
    });
  }

  void decrypt() {
    print(encryptedData.codeUnits);
    final data = base64.decode(encryptedData);
    final dt = crypt.aesDecrypt(data);
    setState(() {
      decryptedData = utf8.decode(removeNullBytes(dt));
    });
  }

  String generateRandomKey(int sizeInBits) {
    int numBytes = (sizeInBits / 8).ceil(); // Số lượng byte cần cho độ dài khóa

    Random random = Random();
    List<int> bytes =
        List<int>.generate(numBytes, (index) => random.nextInt(256));

    return base64.encode(Uint8List.fromList(bytes));
  }

  List<int> stringToListInt(String inputString) {
    List<int> stringBytes = utf8
        .encode(inputString); // Chuyển đổi chuỗi thành một danh sách các byte
    int length = stringBytes.length;
    int remainder = length %
        16; // Số lượng byte cần bổ sung để đạt được độ dài là bội của 16
    int paddingLength = remainder == 0
        ? 0
        : 16 -
            remainder; // Số lượng byte cần bổ sung để đạt được độ dài là bội của 16

    List<int> paddedBytes =
        List<int>.from(stringBytes); // Sao chép các byte từ chuỗi ban đầu
    paddedBytes.addAll(
        List.filled(paddingLength, 0)); // Bổ sung các byte null vào cuối chuỗi

    return paddedBytes;
  }

  List<int> removeNullBytes(List<int> bytes) {
    return bytes.where((byte) => byte != 0).toList();
  }
}
