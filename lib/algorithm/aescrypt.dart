part of aes_crypt;

/// Enum that specifies the overwrite mode for write file operations
/// during encryption or decryption process.
enum AesCryptOwMode {
  /// If the file exists, stops the operation and throws [AesCryptException]
  /// exception with [AesCryptExceptionType.destFileExists] type.
  /// This mode is set by default.
  warn,

  /// If the file exists, adds index '(1)' to its' name and tries to save.
  /// If such file also exists, adds '(2)' to its name, then '(3)', etc.
  rename,

  /// Overwrites the file if it exists.
  on,
}

/// Enum that specifies the mode of operation of the AES algorithm.
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

/// Wraps encryption and decryption methods and algorithms.
class AesCrypt {
  final _aes = _Aes();

  AesCrypt();

  void aesSetKeys(Uint8List key, [Uint8List? iv]) => _aes.aesSetKeys(key, iv);

  void aesSetMode(AesMode mode) => _aes.aesSetMode(mode);

  void aesSetParams(Uint8List key, Uint8List iv, AesMode mode) {
    aesSetKeys(key, iv);
    aesSetMode(mode);
  }

  Uint8List aesEncrypt(Uint8List data) => _aes.aesEncrypt(data);

  Uint8List aesDecrypt(Uint8List data) => _aes.aesDecrypt(data);

  Uint8List aesEncryptFile(File file) {
    final data = AppConvert.padDataForAES(file.readAsBytesSync());
    return aesEncrypt(data);
  }

  Uint8List aesDecryptFile(File file) {
    final data = aesDecrypt(file.readAsBytesSync());
    return AppConvert.unpadDataForAES(data);
  }
}
