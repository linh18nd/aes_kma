import 'dart:convert';
import 'dart:io';

import 'package:aes_kma/algorithm/aescrypt.dart';
import 'package:aes_kma/model/user.dart';
import 'package:aes_kma/utils/key.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WebSocket Client',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final ipController = TextEditingController();
  WebSocketChannel? channel;
  String ip = "localhost";
  List<User> users = [];
  FileModel? file;
  FileModel? encryptedFile;
  FileModel? decryptedFile;
  FileModel? receivedFile;
  String receiverId = '';
  String generateKey = '';

  @override
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() {
    channel = IOWebSocketChannel.connect('ws://$ip:8080');
    channel?.stream.listen((message) {
      handleMessage(message);
    });
  }

  void handleMessage(String message) {
    final Map<String, dynamic> result = jsonDecode(message);
    final type = result['type'];
    print(type);
    switch (type) {
      case "userInfo":
        updateAllUser(message);
        break;
      case "file":
        receiveFile(message);
        break;
      default:
    }
  }

  void updateAllUser(String text) {
    users.clear();
    Map<String, dynamic> result = jsonDecode(text);

    final data = result['data'];

    for (var item in data) {
      users.add(User.fromJson(item));
    }
    setState(() {});
  }

  void receiveFile(String text) {
    final data = jsonDecode(text);
    final encryptedData = base64.decode(data['data']);
    final fileName = data['fileName'];

    setState(() {
      receivedFile =
          FileModel.asset(fileName, Uint8List.fromList(encryptedData));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: (receiverId.isNotEmpty && encryptedFile != null)
          ? FloatingActionButton(
              onPressed: () {
                sendFile();
              },
              child: const Icon(Icons.send),
            )
          : null,
      appBar: AppBar(
        title: const Text('WebSocket Client'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                ip = ipController.text;
              });
              connect();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Server: http://$ip:8080',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ipController,
              decoration: const InputDecoration(
                labelText: 'Enter IP Address',
              ),
              onChanged: (value) {
                ip = value;
              },
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              "key: $generateKey",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickFile,
              child: const Text('Pick File'),
            ),
            if (file != null)
              Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "File selected: ${file!.name}",
                    style: const TextStyle(fontSize: 20),
                  ),
                  ElevatedButton(
                    onPressed: encryptFile,
                    child: const Text('Encrypt File'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            const SizedBox(height: 20),
            if (encryptedFile != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Encrypted file: ${encryptedFile!.name}",
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20, width: 20),
                  ElevatedButton(
                    onPressed: () {
                      saveFile(encryptedFile!);
                    },
                    child: const Text('Save File'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (receivedFile != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Receive file: ${receivedFile!.name}",
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20, width: 20),
                  ElevatedButton(
                    onPressed: () {
                      print("1");
                      decryptFile();
                    },
                    child: const Text('Decrypt File'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (decryptedFile != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Decrypted file: ${decryptedFile!.name}",
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20, width: 20),
                  ElevatedButton(
                    onPressed: () {
                      print("2");
                      saveFile(decryptedFile!);
                    },
                    child: const Text('Save File'),
                  ),
                ],
              ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      setState(() {
                        if (!users[index].isMe) {
                          receiverId = users[index].id;
                        }
                      });
                    },
                    selected: users[index].id == receiverId,
                    selectedColor: Colors.blueAccent,
                    title: Text(users[index].name),
                    subtitle: Text(users[index].id),
                    trailing: users[index].isMe
                        ? const Icon(Icons.check)
                        : const Icon(Icons.close),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(compressionQuality: 1);
    setState(() {
      file = FileModel(File(result!.files.single.path!));
    });
  }

  void encryptFile() {
    final aesCrypt = AesCrypt();
    final key = base64.decode(aesKey);
    aesCrypt.aesSetKeys(Uint8List.fromList(key), Uint8List.fromList(key));
    aesCrypt.aesSetMode(AesMode.cbc);
    setState(() {
      generateKey = base64.encode(key);
      encryptedFile = aesCrypt.aesEncryptFile(file!);
    });
  }

  void decryptFile() {
    final aesCrypt = AesCrypt();
    final key = base64.decode(aesKey);
    aesCrypt.aesSetKeys(Uint8List.fromList(key), Uint8List.fromList(key));
    aesCrypt.aesSetMode(AesMode.cbc);
    setState(() {
      decryptedFile = aesCrypt.aesDecryptFile(receivedFile!);
    });
  }

  void sendFile() {
    final data = {
      'receiverId': receiverId,
      'data': base64.encode(encryptedFile!.bytes),
      'fileName': encryptedFile!.name,
    };
    channel?.sink.add(jsonEncode(data));
  }

  void saveFile(FileModel file) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save File',
      fileName: file.name,
      bytes: file.bytes,
    );
    if (result != null) {
      await File(result).writeAsBytes(file.bytes);
    }
  }
}
