import 'dart:convert';
import 'package:dpp_soft_toys/passport_shell.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/api_constants.dart';
import 'constants/crypto_utils.dart';
import 'providers/dpp_provider.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  int _templateId = 2;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        // _extractParamsAndFetchDataForDevelopment();
        _extractParamsAndFetchDataForProduction();
      });
    });
  }

  Future<void> _extractParamsAndFetchDataForDevelopment() async {
    try {
      final uri = Uri.parse(
        'https://softtoys.reputdev.co.in/?data=XV3RFglFxvUJ%2Fp%2BA7Mf7q6lq64ha%2Fq8oxHl7gcUoL1fxAQyiKNi4aLCyy8D6T%2BCHXKHCuQkuq2moQQ%3D%3D&iv=fC7br7KI62N57jjJ',
      );
      final encryptedData = uri.queryParameters['data'];
      final iv = uri.queryParameters['iv'];
      if (encryptedData == null || iv == null) {
        print('⚠️  Missing data or iv in the dev URL');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      await _decryptAndLoad(encryptedData, iv);
    } catch (e) {
      print('[AppInitializer] Dev error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }
  //------------------_   For  Scanning -------------------

  Future<void> _extractParamsAndFetchDataForProduction() async {
    final uri = Uri.base;
    final encryptedData = uri.queryParameters['data'];
    final iv = uri.queryParameters['iv'];

    if (encryptedData != null && iv != null) {
      await _decryptAndLoad(encryptedData, iv);
    } else {
      print('⚠️  Missing data or iv in the URL');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _decryptAndLoad(
    String encryptedData,
    String iv,
  ) async {
    try {
      final decryptedText = await CryptoHelper.decrypt(
        encryptedBase64: encryptedData,
        ivBase64: iv,
        keyString: ApiConstants.encryptionKey,
      );

      final decodedData = jsonDecode(decryptedText) as Map<String, dynamic>;

      final brandId = decodedData['BrandID'] as int?;
      final batchId = decodedData['BatchID'] as int?;
      final templateId = (decodedData['TemplateID'] ?? 2) as int;

      if (kDebugMode) {
        print('✅ Brand ID: $brandId');
        print('✅ Batch ID: $batchId');
        print('✅ Template ID: $templateId');
        final prettyJson = const JsonEncoder.withIndent(
          '  ',
        ).convert(decodedData);
        print('🔓 Decrypted response structure:\n$prettyJson');
      }

      if (brandId == null || batchId == null) {
        print('❌ Failed to extract BrandID or BatchID');
        if (mounted) setState(() => _isLoading = false);
        return decodedData;
      }

      if (mounted) setState(() => _templateId = templateId);

      final provider = Provider.of<DppProvider>(context, listen: false);
      provider.setIds(brandId: brandId, batchId: batchId);
      provider.setTemplateId(templateId);

      await provider.loadDpp(brandId: brandId, batchId: batchId);

      if (!mounted) return decodedData;
      setState(() => _isLoading = false);
      return decodedData;
    } catch (e) {
      print('❌ [AppInitializer] $e');
      if (mounted) setState(() => _isLoading = false);
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // BUILD - only one UI template exists for soft toys today, so _templateId
  // isn't branched on yet (kept on DppProvider for when more templates
  // exist) — everything routes to PassportShell.
  // ════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.black, strokeWidth: 1.5),
              SizedBox(height: 20),
              Text(
                '® Powered by RePut.ai',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Initialization error:\n$_error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return const PassportShell();
  }
}
