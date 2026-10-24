import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/dpp_api_service.dart';
import '../data/dpp_models.dart';

/// Holds the decrypted DPP response for the currently-scanned (or
/// demo-seeded) product and exposes it to every screen as typed,
/// per-tab models. All 5 screens read from this instead of a static
/// data class.
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
  DppResponseModel? _dppModel;
  bool _isLoading = false;
  String? _error;

  DppResponseModel? get dppModel => _dppModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _dppModel != null;

  // ── Typed per-tab getters — what the screens actually read ────────────
  ToyModel? get toy => _dppModel?.toy;
  ImpactModel? get impact => _dppModel?.impact;
  JourneyModel? get journey => _dppModel?.journey;
  CareModel? get care => _dppModel?.care;
  BrandModel? get brand => _dppModel?.brand;

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

  Future<void> loadDpp({
    required int brandId,
    required int batchId,
  }) async {
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
      _dppModel = DppResponseModel.fromJson(raw);
    } on DppNotFoundException catch (e) {
      _error = e.message;
      _dppModel = null;
      debugPrint('❌ [DppProvider] Not found: ${e.message}');
    } catch (e, st) {
      _error = e.toString();
      _dppModel = null;
      debugPrint('❌ [DppProvider] FAILED: $e');
      if (kDebugMode) debugPrint(st.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads an already-decrypted (or locally-seeded) DPP JSON map directly,
  /// skipping the network call. Used by [AppInitializer] as the demo
  /// fallback when the app is launched without a real scanned `data`/`iv`
  /// query pair — e.g. running via `flutter run` during development.
  void loadFromJson(Map<String, dynamic> json) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dppModel = DppResponseModel.fromJson(json);
    } on DppNotFoundException catch (e) {
      _error = e.message;
      _dppModel = null;
    } catch (e) {
      _error = e.toString();
      _dppModel = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _brandId = null;
    _batchId = null;
    _templateId = 2;
    _dppModel = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
