import 'dart:io';
import 'dart:typed_data';
import 'package:aes_kma/algorithm/aes.dart';
import 'package:aes_kma/algorithm/convert.dart';

enum AesMode {
  /// ECB (Electronic Code Book)
  ecb,

  /// CBC (Cipher Block Chaining)
  cbc,

  /// CFB (Cipher Feedback)
  cfb,

  /// OFB (Output Feedback)
  ofb,
}

class AesCrypt {
  final _aes = Aes();

  AesCrypt();

  void aesSetKeys(Uint8List key, [Uint8List? iv]) => _aes.aesSetKeys(key, iv);

  void aesSetMode(AesMode mode) => _aes.aesSetMode(mode);

  void aesSetParams(Uint8List key, Uint8List iv, AesMode mode) {
    aesSetKeys(key, iv);
    aesSetMode(mode);
  }

  Uint8List aesEncrypt(Uint8List data) => _aes.aesEncrypt(data);

  Uint8List aesDecrypt(Uint8List data) => _aes.aesDecrypt(data);

  FileModel aesEncryptFile(FileModel file) {
    final data = AppConvert.padDataForAES(file.bytes);
    final encryptedData = aesEncrypt(data);
    return file.copyWith(bytes: encryptedData, name: '${file.name}.aes');
  }

  FileModel aesDecryptFile(FileModel file) {
    final data = aesDecrypt(file.bytes);
    final decryptedData = AppConvert.unpadDataForAES(data);
    final name = file.name.substring(0, file.name.length - 4);
    return file.copyWith(bytes: decryptedData, name: name);
  }
}

class FileModel {
  final String name;
  final Uint8List bytes;

  FileModel.asset(this.name, this.bytes);
// \
  FileModel(File file)
      : name = file.path.split('\\').last,
        bytes = file.readAsBytesSync();

  FileModel copyWith({String? name, Uint8List? bytes}) {
    return FileModel.asset(
      name ?? this.name,
      bytes ?? this.bytes,
    );
  }
}
