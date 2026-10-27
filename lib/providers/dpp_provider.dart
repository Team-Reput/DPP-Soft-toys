import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/dpp_api_service.dart';
import '../data/dpp_process_models.dart';

/// Holds the decrypted DPP response for the currently-scanned product and
/// exposes it as [processDetail] — the REAL `getToyDppProcessDetail` shape
/// (`dpp_process_models.dart`): batch info, the manufacturing processes
/// (each with waste/water/energy/certification/material/production/
/// transportation detail), wash-care, end-of-life and brand details. Every
/// screen's own view-model reads from this.
class DppProvider extends ChangeNotifier {
  final DppApiService _api = DppApiService();

  // ── Identity (from the decrypted QR payload) ───────────────────────────
  int? _brandId;
  int? _batchId;
  int _templateId = 2;

  int? get brandId => _brandId;
  int? get batchId => _batchId;
  int get templateId => _templateId;

  // ── Data ─────────────────────────────────────────────────────────────
  DppProcessDetailModel? _processDetail;
  bool _isLoading = false;
  String? _error;

  DppProcessDetailModel? get processDetail => _processDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _processDetail != null;

  // ── Setters ─────────────────────────────────────────────────────────────

  void setIds({required int brandId, required int batchId}) {
    _brandId = brandId;
    _batchId = batchId;
    notifyListeners();
  }

  void setTemplateId(int id) {
    _templateId = id;
    notifyListeners();
  }

  // ── Data loading — real backend call ─────────────────────────────────

  Future<void> loadDpp({required int brandId, required int batchId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final raw = await _api.fetchDppDecrypted(
        brandId: brandId,
        batchId: batchId,
      );
      if (kDebugMode) {
        final prettyJson = const JsonEncoder.withIndent('  ').convert(raw);
        debugPrint('🔓 Decrypted DPP response structure:\n$prettyJson');
      }
      _processDetail = DppProcessDetailModel.fromJson(raw);
    } on DppProcessDetailException catch (e) {
      _error = e.message;
      _processDetail = null;
      debugPrint('❌ [DppProvider] Not found: ${e.message}');
    } catch (e, st) {
      _error = e.toString();
      _processDetail = null;
      debugPrint('❌ [DppProvider] FAILED: $e');
      if (kDebugMode) debugPrint(st.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads an already-decrypted DPP JSON map directly, skipping the network
  /// call. Useful for testing against a pasted sample response.
  void loadFromJson(Map<String, dynamic> json) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _processDetail = DppProcessDetailModel.fromJson(json);
    } on DppProcessDetailException catch (e) {
      _error = e.message;
      _processDetail = null;
    } catch (e) {
      _error = e.toString();
      _processDetail = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _brandId = null;
    _batchId = null;
    _templateId = 2;
    _processDetail = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
