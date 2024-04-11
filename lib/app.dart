import 'dart:convert';
import 'dart:io';

import 'package:aes_kma/algorithm/aescrypt.dart';
import 'package:aes_kma/model/user.dart';
import 'package:aes_kma/utils/key.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WebSocket Client',
      home: const MyHomePage(),
      builder: EasyLoading.init(),
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
  String deviceId = '';
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
  }

  void connect() {
    try {
      print(deviceId);
      channel?.sink.close();
      channel = IOWebSocketChannel.connect('ws://$ip:8080?name=$deviceId');
      channel?.stream.listen((message) {
        handleMessage(message);
      });
    } catch (e) {
      users.clear();
      setState(() {});
      print(e);
    }
  }

  void handleMessage(String message) {
    final Map<String, dynamic> result = jsonDecode(message);
    final type = result['type'];
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
                if (ipController.text.isNotEmpty) {
                  ip = ipController.text;
                } else {
                  ip = "localhost";
                }
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
            _serverInfo(),
            const SizedBox(height: 20),
            _deviceInfo(),
            const Divider(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _fromEncryptFile(),
                ),
                Expanded(
                  child: _fromDecryptedFile(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'List Users',
              ),
            ),
            const SizedBox(height: 20),
            _listUsers()
          ],
        ),
      ),
    );
  }

  Widget _listUsers() {
    return Expanded(
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              setState(() {
                if (!users[index].isMe) {
                  selectedUser(users[index].id);
                }
              });
            },
            selected: users[index].id == receiverId,
            selectedColor: Colors.blueAccent,
            title: Text(users[index].name),
            subtitle: Text(users[index].id),
            trailing: users[index].isMe
                ? const Icon(Icons.person_outline_rounded)
                : const Icon(Icons.computer_outlined),
          );
        },
      ),
    );
  }

  Widget _fromEncryptFile() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        children: [
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Encrypted file: ${encryptedFile!.name}",
                  style: const TextStyle(fontSize: 20),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }

  Widget _fromDecryptedFile() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          if (receivedFile != null)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Receive file: ${receivedFile!.name}",
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20, width: 20),
                ElevatedButton(
                  onPressed: () {
                    decryptFile();
                  },
                  child: const Text('Decrypt File'),
                ),
              ],
            ),
          const SizedBox(height: 20),
          if (decryptedFile != null)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Decrypted file: ${decryptedFile!.name}",
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20, width: 20),
                ElevatedButton(
                  onPressed: () {
                    saveFile(decryptedFile!);
                  },
                  child: const Text('Save File'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _deviceInfo() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Device Name: $deviceId',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(
          width: 50,
        ),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Enter Device Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                deviceId = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _serverInfo() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Connect Server: http://$ip:8080',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(
          width: 50,
        ),
        Expanded(
          child: TextField(
            controller: ipController,
            decoration: const InputDecoration(
              labelText: 'Enter IP Address',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              ip = value;
            },
          ),
        ),
      ],
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
    print("show");
    EasyLoading.show(status: 'loading...');
    final time = DateTime.now();
    final aesCrypt = AesCrypt();
    final key = base64.decode(aesKey);
    aesCrypt.aesSetKeys(Uint8List.fromList(key), Uint8List.fromList(key));
    aesCrypt.aesSetMode(AesMode.cbc);
    setState(() {
      generateKey = base64.encode(key);
      encryptedFile = aesCrypt.aesEncryptFile(file!);
    });
    final duration = DateTime.now().difference(time).inMilliseconds;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Encrypt file in $duration ms'),
      ),
    );
    EasyLoading.dismiss();
  }

  void decryptFile() {
    EasyLoading.show(status: 'loading...');
    final time = DateTime.now();
    final aesCrypt = AesCrypt();
    final key = base64.decode(aesKey);
    aesCrypt.aesSetKeys(Uint8List.fromList(key), Uint8List.fromList(key));
    aesCrypt.aesSetMode(AesMode.cbc);
    setState(() {
      decryptedFile = aesCrypt.aesDecryptFile(receivedFile!);
    });
    final duration = DateTime.now().difference(time).inMilliseconds;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Decrypt file in $duration ms'),
      ),
    );
    EasyLoading.dismiss();
  }

  void sendFile() {
    EasyLoading.show(status: 'sending...');
    final data = {
      'receiverId': receiverId,
      'data': base64.encode(encryptedFile!.bytes),
      'fileName': encryptedFile!.name,
    };
    channel?.sink.add(jsonEncode(data));
    EasyLoading.dismiss();
  }

  void saveFile(FileModel file) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save File',
      fileName: file.name,
      bytes: file.bytes,
    );
    if (result != null) {
      await File(result).create(recursive: true);
      await File(result).writeAsBytes(file.bytes);
    }
  }

  void selectedUser(String id) {
    setState(() {
      if (receiverId == id) {
        receiverId = '';
      } else {
        receiverId = id;
      }
    });
  }
}
