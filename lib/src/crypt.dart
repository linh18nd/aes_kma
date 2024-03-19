/// Dart encryption library for encrypting/decrypting files, plain text and
/// binary data in AES Crypt file format.
///
/// It can be used to integrate AES Crypt functionality into your own Dart or
/// Flutter applications. All algorithms are implemented in pure Dart and work
/// in all platforms. The library is fully compatible with any software using
/// the [AES Crypt](https://www.aescrypt.com/) standard file format.
library aes_crypt;

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

part 'aescrypt.dart';
part 'cryptor.dart';
part 'aes.dart';
part 'exceptions.dart';
part 'extentions.dart';
