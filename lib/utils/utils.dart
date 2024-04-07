import 'dart:math';

class Utils {
  static List<int> generateRandomKey(int length) {
    Random random = Random();
    List<int> randomList =
        List.generate(length, (index) => random.nextInt(100));
    return randomList;
  }
}
