import 'dart:convert';
import 'dart:typed_data';

class AppConvert {
  static List<int> stringToListInt(String inputString) {
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

  static List<int> removeNullBytes(List<int> bytes) {
    return bytes.where((byte) => byte != 0).toList();
  }

  static String listIntToString(List<int> bytes) {
    return utf8.decode(bytes);
  }

  static Uint8List padDataForAES(Uint8List data) {
    final blockSize = 16;
    final paddingLength = blockSize - (data.length % blockSize);
    final paddedData = Uint8List(data.length + paddingLength);

    // Copy dữ liệu gốc vào mảng đã nở ra
    paddedData.setRange(0, data.length, data);

    // Thêm các byte padding với giá trị bằng paddingLength
    for (int i = data.length; i < paddedData.length; i++) {
      paddedData[i] = paddingLength;
    }

    return paddedData;
  }

  static Uint8List unpadDataForAES(Uint8List data) {
    final paddingLength = data[data.length - 1];
    return data.sublist(0, data.length - paddingLength);
  }
}
