class ApiConstants {
  ApiConstants._();

  static const String _key = '0123456789abcdef';
  static String get encryptionKey => _key;

  static const String softToysDppEndpoint =
      // 'https://api-dev.reput.world/getToyDppProcessDetail';
      'https://api.reput.world/getToyDppProcessDetail';
}
