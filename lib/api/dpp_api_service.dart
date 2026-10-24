import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../constants/crypto_utils.dart';

/// Calls the soft-toys DPP backend with the decrypted `{brandId, batchId}`
/// pair (lifted from the scanned QR code), then decrypts its response.
///
/// Request:  POST [ApiConstants.softToysDppEndpoint]
///           body: { "brandid": <int>, "batchid": <int> }
/// Response: { "data": "<base64 AES-GCM ciphertext>" }  +  header "x-iv"
///           → decrypt → the full DPP JSON envelope:
///           { "issuccessful": bool,
///             "data": [ { "o_status": bool, "o_message": string,
///                         "details": { toy, impact, journey, care, brand } } ] }
class DppApiService {
  Future<Map<String, dynamic>> fetchDppDecrypted({
    required int brandId,
    required int batchId,
  }) async {
    const url = ApiConstants.softToysDppEndpoint;

    final body = jsonEncode({
      'brandid': brandId,
      'batchid': batchId,
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Soft-toys DPP API error: HTTP ${response.statusCode}\n${response.body}',
      );
    }

    final outer = jsonDecode(response.body) as Map<String, dynamic>;

    // Response: { "data": "<base64-encrypted-payload>" }
    // IV is in the x-iv response header.
    final encryptedB64 = outer['data'] as String?;
    if (encryptedB64 == null || encryptedB64.isEmpty) {
      throw Exception('Soft-toys DPP API: missing "data" field in response');
    }

    final iv = response.headers['x-iv'];
    if (iv == null || iv.isEmpty) {
      throw Exception('Soft-toys DPP API: missing x-iv header');
    }

    final decrypted = await CryptoHelper.decrypt(
      encryptedBase64: encryptedB64,
      ivBase64: iv,
      keyString: ApiConstants.encryptionKey,
    );

    final decryptedMap = jsonDecode(decrypted) as Map<String, dynamic>;

    final isOk = decryptedMap['issuccessful'];
    if (isOk == false || isOk == 'false') {
      final msg = decryptedMap['message'] ?? 'Unknown error';
      throw Exception('DPP API error: $msg');
    }

    return decryptedMap;
  }
}
