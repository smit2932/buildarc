import 'dart:math';

int getDeterministicRandomSeed(String document) {
  return document.runes.fold(0, (prev, elem) => prev + elem);
}

String generateDocumentId(int length, Random random) {
  const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(length, (index) => chars[random.nextInt(chars.length)])
      .join();
}
