import 'dart:math';

// void main() {
//   // Khởi tạo khóa công khai và khóa bí mật
//   final keys = generateRSAKeys();
//   final publicKey = keys['publicKey']!;
//   final privateKey = keys['privateKey']!;

//   // Message cần mã hóa
//   final message = 'Hello, RSA!';
//   print('Message: $message');

//   // Mã hóa message bằng khóa công khai
//   final encryptedMessage = encrypt(message, publicKey);
//   print('Encrypted message: $encryptedMessage');

//   // Giải mã message bằng khóa bí mật
//   final decryptedMessage = decrypt(encryptedMessage, privateKey);
//   print('Decrypted message: $decryptedMessage');

//   print('------------------------------');
//   print('Public key: $publicKey');
//   print('Private key: $privateKey');
// }

// Hàm tạo khóa RSA và trả về một map chứa khóa công khai và khóa bí mật
Map<String, Map<String, BigInt>> generateRSAKeys() {
  final p = generateLargePrime();
  final q = generateLargePrime();
  final n = p * q;
  final phi = (p - BigInt.one) * (q - BigInt.one);
  final e = BigInt.from(
      65537); // e can be any prime number greater than 2 and less than phi

  final d = modInverse(e, phi);

  final publicKey = {'n': n, 'e': e};
  final privateKey = {'n': n, 'd': d};

  return {'publicKey': publicKey, 'privateKey': privateKey};
}

// Hàm tạo số nguyên tố lớn
BigInt generateLargePrime() {
  final random = Random.secure();
  while (true) {
    final primeCandidate = BigInt.from(random.nextInt(1 << 16));
    if (isPrime(primeCandidate)) {
      return primeCandidate;
    }
  }
}

// Hàm kiểm tra số nguyên tố
bool isPrime(BigInt number) {
  if (number <= BigInt.one) return false;
  if (number <= BigInt.from(3)) return true;
  if (number % BigInt.from(2) == BigInt.zero ||
      number % BigInt.from(3) == BigInt.zero) return false;

  BigInt i = BigInt.from(5);
  BigInt w = BigInt.from(2);

  while (i * i <= number) {
    if (number % i == BigInt.zero) return false;
    i += w;
    w = BigInt.from(6) - w;
  }

  return true;
}

// Hàm tìm nghịch đảo mod
BigInt modInverse(BigInt a, BigInt m) {
  BigInt m0 = m;
  BigInt y = BigInt.zero, x = BigInt.one;

  while (a > BigInt.one) {
    // q là phần nguyên của a/m
    BigInt q = a ~/ m;
    BigInt t = m;

    // m là phần dư của a/m
    m = a % m;
    a = t;
    t = y;

    // Update x và y
    y = x - q * y;
    x = t;
  }

  // Đảo ngược x nếu x âm
  if (x < BigInt.zero) x += m0;

  return x;
}

// Hàm mã hóa RSA
String encrypt(String message, Map<String, BigInt> publicKey) {
  final n = publicKey['n']!;
  final e = publicKey['e']!;
  final encodedMessage = message.codeUnits;
  final encryptedMessage =
      encodedMessage.map((m) => BigInt.from(m).modPow(e, n));
  // map((m) => String.fromCharCode(m.toInt())).join('');

  return encryptedMessage.join(' ');
}

// Hàm giải mã RSA
String decrypt(String encryptedMessage, Map<String, BigInt> privateKey) {
  final n = privateKey['n']!;
  final d = privateKey['d']!;
  final encryptedNumbers = encryptedMessage.split(' ').map(BigInt.parse);
  final decryptedNumbers = encryptedNumbers.map((m) => m.modPow(d, n));
  final decryptedMessage =
      decryptedNumbers.map((m) => String.fromCharCode(m.toInt())).join('');
  return decryptedMessage;
}
