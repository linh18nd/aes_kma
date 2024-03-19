import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:aes_kma/algorithm/crypt.dart';
import 'package:aes_kma/utils/app_convert.dart';
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
  final crypt = AesCrypt();

  @override
  void initState() {
    final kt = generateRandomKey(16);
    Uint8List key = Uint8List.fromList(kt);
    crypt.aesSetKeys(key, key);
    crypt.aesSetMode(AesMode.cbc);
    super.initState();
  }

  List<int> generateRandomKey(int length) {
    Random random = Random();
    List<int> randomList = List.generate(
        length,
        (index) =>
            random.nextInt(100)); // Đổi 100 thành giá trị tối đa bạn mong muốn
    return randomList;
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
                final kt = generateRandomKey(16);
                setState(() {
                  generatedKey = base64.encode(Uint8List.fromList(kt));
                  crypt.aesSetKeys(Uint8List.fromList(kt),
                      Uint8List.fromList(kt));
                });
              },
              child: const Text('Generate Key'),
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
    final data = AppConvert.stringToListInt(inputController1.text);
    print("Data: $data");
    final dt = crypt.aesEncrypt(Uint8List.fromList(data));
    print("Encrypted data: $dt");
    final encryptedString = base64.encode(dt);
    setState(() {
      encryptedData = encryptedString;
    });
  }

  void decrypt() {
    print("Encrypted data_ de: $encryptedData");

    final data = base64.decode(encryptedData);
    final dt = crypt.aesDecrypt(data);
    setState(() {
      print("Decrypted data: $dt");
      decryptedData = utf8.decode(AppConvert.removeNullBytes(dt));
    });
  }

  
}
