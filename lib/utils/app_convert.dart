import 'dart:convert';

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
}
