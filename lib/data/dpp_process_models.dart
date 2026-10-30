/// Typed models for the REAL soft-toys DPP backend response
/// (`POST /getToyDppProcessDetail`, called from `api/dpp_api_service.dart`),
/// once decrypted:
///
///   { "issuccessful": bool, "message": string,
///     "data": {
///       "batch": { ... },
///       "processes": [ { "process_id", "process_name",
///                         "waste_details", "water_details",
///                         "certifications", "energy_details",
///                         "material_details", "production_details",
///                         "transportation_details" }, ... ],
///       "wash_care": [ { "instruction" }, ... ],
///       "end_of_life": { ... },
///       "brand_details": { ... },
///       "product_details": { ... }
///     } }
///
/// This is the ONLY DPP response model now — exposed on [DppProvider] as
/// `processDetail`. Every screen builds its own small view-model (e.g.
/// `_HomeContent`, `_ImpactContent`, defined at the bottom of each screen
/// file) directly from this real shape; `dpp_models.dart` now holds only
/// the plain UI value types those view-models construct
/// (`DetailRow`/`ChipItem`/`LinkRow`/`TinyRow`/`StoryBoxContent`), not a
/// second response model.
///
/// `material_details` and `production_details` are deliberately NOT typed
/// per-field: their shape is different for every manufacturing process
/// (e.g. Cutting's fields aren't Sewing's, Packaging's aren't Embroidery's
/// — see the sample response). Rather than invent 8 near-duplicate classes
/// before we know which fields each screen will actually show, each entry
/// is kept as a [ProcessFieldSet] — the decoded JSON object as-is, with
/// typed readers for whichever key you ask for. When a specific screen's
/// section is wired up, read the exact keys it needs (the API's own field
/// names, unchanged) via `.str(...)`/`.num_(...)`/`.int_(...)`/`.bool_(...)`.
library dpp_process_models;

// ════════════════════════════════════════════════════════════════════════
// JSON COERCION HELPERS — tolerant of String/num/bool-as-string/int-as-bool
// payloads, matching the style already used in dpp_models.dart.
// ════════════════════════════════════════════════════════════════════════

String _s(Map<String, dynamic> j, String key, [String fb = '']) {
  final v = j[key];
  if (v == null) return fb;
  final s = v.toString().trim();
  return s.isEmpty ? fb : s;
}

double _d(Map<String, dynamic> j, String key, [double fb = 0.0]) {
  final v = j[key];
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fb;
  return fb;
}

int _i(Map<String, dynamic> j, String key, [int fb = 0]) {
  final v = j[key];
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fb;
  return fb;
}

/// Backend sends booleans as real `bool`, `"true"/"false"` strings, and
/// (e.g. `is_submit`) `0`/`1` ints — all three show up in the sample data.
bool _b(Map<String, dynamic> j, String key, [bool fb = false]) {
  final v = j[key];
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v.toLowerCase() == 'true' || v == '1';
  return fb;
}

List<Map<String, dynamic>> _list(Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v is List) return v.whereType<Map<String, dynamic>>().toList();
  return [];
}

List<String> _strList(Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v is List) return v.map((e) => e.toString()).toList();
  return [];
}

Map<String, dynamic> _obj(Map<String, dynamic> j, String key) {
  final v = j[key];
  return v is Map<String, dynamic> ? v : {};
}

/// Thrown when the API returns `issuccessful: false`.
class DppProcessDetailException implements Exception {
  final String message;
  const DppProcessDetailException(this.message);
  @override
  String toString() => message;
}

// ════════════════════════════════════════════════════════════════════════
// BATCH — `data.batch`
// ════════════════════════════════════════════════════════════════════════

class BatchModel {
  final int batchId;
  final String batchNo;
  final String batchUrl;
  final int brandId;
  final bool isSubmit;
  final String poNumber;
  final int productId;
  final int poQuantity;
  final int toyTemplateId;
  final String batchLotNumber;
  final String batchStartDate;
  final String productNameStyle;
  final List<String> documentAttachments;
  final String manufacturingFacility;
  final int unitsActuallyProduced;
  final String manufacturingPeriodEnd;
  final String manufacturingPeriodStart;

  const BatchModel({
    required this.batchId,
    required this.batchNo,
    required this.batchUrl,
    required this.brandId,
    required this.isSubmit,
    required this.poNumber,
    required this.productId,
    required this.poQuantity,
    required this.toyTemplateId,
    required this.batchLotNumber,
    required this.batchStartDate,
    required this.productNameStyle,
    required this.documentAttachments,
    required this.manufacturingFacility,
    required this.unitsActuallyProduced,
    required this.manufacturingPeriodEnd,
    required this.manufacturingPeriodStart,
  });

  factory BatchModel.fromJson(Map<String, dynamic> j) => BatchModel(
    batchId: _i(j, 'batch_id'),
    batchNo: _s(j, 'batch_no'),
    batchUrl: _s(j, 'batchurl'),
    brandId: _i(j, 'brand_id'),
    isSubmit: _b(j, 'is_submit'),
    poNumber: _s(j, 'po_number'),
    productId: _i(j, 'product_id'),
    poQuantity: _i(j, 'po_quantity'),
    toyTemplateId: _i(j, 'toy_template_id'),
    batchLotNumber: _s(j, 'batch_lot_number'),
    batchStartDate: _s(j, 'batch_start_date'),
    productNameStyle: _s(j, 'product_name_style'),
    documentAttachments: _strList(j, 'document_attachments'),
    manufacturingFacility: _s(j, 'manufacturing_facility'),
    unitsActuallyProduced: _i(j, 'units_actually_produced'),
    manufacturingPeriodEnd: _s(j, 'manufacturing_period_end'),
    manufacturingPeriodStart: _s(j, 'manufacturing_period_start'),
  );
}

// ════════════════════════════════════════════════════════════════════════
// PER-PROCESS DETAIL LISTS — these ARE consistent across every process, so
// each gets its own typed class.
// ════════════════════════════════════════════════════════════════════════

class WasteDetail {
  final int id;
  final String wasteType;
  final String isHazardous;
  final String disposalMethod;
  final String reportingBasis;
  final double wasteGenerated;
  final double calculatedEmission;
  final String wasteGeneratedUnit;
  final String hazardousHandlingDisposalNotes;

  const WasteDetail({
    required this.id,
    required this.wasteType,
    required this.isHazardous,
    required this.disposalMethod,
    required this.reportingBasis,
    required this.wasteGenerated,
    required this.calculatedEmission,
    required this.wasteGeneratedUnit,
    required this.hazardousHandlingDisposalNotes,
  });

  factory WasteDetail.fromJson(Map<String, dynamic> j) => WasteDetail(
    id: _i(j, 'id'),
    wasteType: _s(j, 'waste_type'),
    isHazardous: _s(j, 'is_hazardous'),
    disposalMethod: _s(j, 'disposal_method'),
    reportingBasis: _s(j, 'reporting_basis'),
    wasteGenerated: _d(j, 'waste_generated'),
    calculatedEmission: _d(j, 'calculated_emission'),
    wasteGeneratedUnit: _s(j, 'waste_generated_unit'),
    hazardousHandlingDisposalNotes: _s(j, 'hazardous_handling_disposal_notes'),
  );
}

class WaterDetail {
  final int id;
  final String waterSource;
  final double waterQuantity;
  final double calculatedEmission;
  final String waterQuantityUnit;
  final String waterReportingBasis;
  final double recycledOrReusedWater;
  final String recycledOrReusedWaterUnit;

  const WaterDetail({
    required this.id,
    required this.waterSource,
    required this.waterQuantity,
    required this.calculatedEmission,
    required this.waterQuantityUnit,
    required this.waterReportingBasis,
    required this.recycledOrReusedWater,
    required this.recycledOrReusedWaterUnit,
  });

  factory WaterDetail.fromJson(Map<String, dynamic> j) => WaterDetail(
    id: _i(j, 'id'),
    waterSource: _s(j, 'water_source'),
    waterQuantity: _d(j, 'water_quantity'),
    calculatedEmission: _d(j, 'calculated_emission'),
    waterQuantityUnit: _s(j, 'water_quantity_unit'),
    waterReportingBasis: _s(j, 'water_reporting_basis'),
    recycledOrReusedWater: _d(j, 'recycled_or_reused_water'),
    recycledOrReusedWaterUnit: _s(j, 'recycled_or_reused_water_unit'),
  );
}

class CertificationDetail {
  final int id;
  final String standard;
  final String issuedBy;
  final String issueDate;
  final String certificateId;
  final String uploadEvidence;
  final String verificationUrl;
  final String validityExpiryDate;
  final String documentCertificateName;

  const CertificationDetail({
    required this.id,
    required this.standard,
    required this.issuedBy,
    required this.issueDate,
    required this.certificateId,
    required this.uploadEvidence,
    required this.verificationUrl,
    required this.validityExpiryDate,
    required this.documentCertificateName,
  });

  factory CertificationDetail.fromJson(Map<String, dynamic> j) =>
      CertificationDetail(
        id: _i(j, 'id'),
        standard: _s(j, 'standard'),
        issuedBy: _s(j, 'issued_by'),
        issueDate: _s(j, 'issue_date'),
        certificateId: _s(j, 'certificate_id'),
        uploadEvidence: _s(j, 'upload_evidence'),
        verificationUrl: _s(j, 'verification_url'),
        validityExpiryDate: _s(j, 'validity_expiry_date'),
        documentCertificateName: _s(j, 'document_certificate_name'),
      );
}

class EnergyDetail {
  final int id;
  final String energyUnit;
  final String energySource;
  final String renewableEnergy;
  final double calculatedEmission;
  final double measuredConsumption;
  final String meterInvoiceEvidence;

  const EnergyDetail({
    required this.id,
    required this.energyUnit,
    required this.energySource,
    required this.renewableEnergy,
    required this.calculatedEmission,
    required this.measuredConsumption,
    required this.meterInvoiceEvidence,
  });

  factory EnergyDetail.fromJson(Map<String, dynamic> j) => EnergyDetail(
    id: _i(j, 'id'),
    energyUnit: _s(j, 'energy_unit'),
    energySource: _s(j, 'energy_source'),
    renewableEnergy: _s(j, 'renewable_energy'),
    calculatedEmission: _d(j, 'calculated_emission'),
    measuredConsumption: _d(j, 'measured_consumption'),
    meterInvoiceEvidence: _s(j, 'meter_invoice_evidence'),
  );
}

class TransportationDetail {
  final int id;
  final String originFrom;
  final String distanceUnit;
  final double fuelMeasured;
  final String destinationTo;
  final String transportMode;
  final double transportedMass;
  final String allocationMethod;
  final String shipmentEvidence;
  final double distanceTravelled;
  final String fuelMeasuredUnit;
  final double calculatedEmission;
  final String transportedMassUnit;
  final double vehicleLoadCapacity;
  final String vehicleLoadCapacityUnit;

  const TransportationDetail({
    required this.id,
    required this.originFrom,
    required this.distanceUnit,
    required this.fuelMeasured,
    required this.destinationTo,
    required this.transportMode,
    required this.transportedMass,
    required this.allocationMethod,
    required this.shipmentEvidence,
    required this.distanceTravelled,
    required this.fuelMeasuredUnit,
    required this.calculatedEmission,
    required this.transportedMassUnit,
    required this.vehicleLoadCapacity,
    required this.vehicleLoadCapacityUnit,
  });

  factory TransportationDetail.fromJson(Map<String, dynamic> j) =>
      TransportationDetail(
        id: _i(j, 'id'),
        originFrom: _s(j, 'origin_from'),
        distanceUnit: _s(j, 'distance_unit'),
        fuelMeasured: _d(j, 'fuel_measured'),
        destinationTo: _s(j, 'destination_to'),
        transportMode: _s(j, 'transport_mode'),
        transportedMass: _d(j, 'transported_mass'),
        allocationMethod: _s(j, 'allocation_method'),
        shipmentEvidence: _s(j, 'shipment_evidence'),
        distanceTravelled: _d(j, 'distance_travelled'),
        fuelMeasuredUnit: _s(j, 'fuel_measured_unit'),
        calculatedEmission: _d(j, 'calculated_emission'),
        transportedMassUnit: _s(j, 'transported_mass_unit'),
        vehicleLoadCapacity: _d(j, 'vehicle_load_capacity'),
        vehicleLoadCapacityUnit: _s(j, 'vehicle_load_capacity_unit'),
      );
}

/// One `material_details`/`production_details` entry. See the library doc
/// comment above for why these stay untyped-by-field.
class ProcessFieldSet {
  final Map<String, dynamic> raw;
  const ProcessFieldSet(this.raw);

  factory ProcessFieldSet.fromJson(Map<String, dynamic> j) =>
      ProcessFieldSet(j);

  /// Every non-empty entry across every process has these two.
  int get id => _i(raw, 'id');
  double get calculatedEmission => _d(raw, 'calculated_emission');

  /// Read any other field by its exact API key.
  String str(String key, [String fb = '']) => _s(raw, key, fb);
  double num_(String key, [double fb = 0.0]) => _d(raw, key, fb);
  int int_(String key, [int fb = 0]) => _i(raw, key, fb);
  bool bool_(String key, [bool fb = false]) => _b(raw, key, fb);
}

// ════════════════════════════════════════════════════════════════════════
// PROCESS — one manufacturing step, `data.processes[]`
// ════════════════════════════════════════════════════════════════════════

class ProcessModel {
  final int processId;
  final String processName;
  final List<WasteDetail> wasteDetails;
  final List<WaterDetail> waterDetails;
  final List<CertificationDetail> certifications;
  final List<EnergyDetail> energyDetails;
  final List<ProcessFieldSet> materialDetails;
  final List<ProcessFieldSet> productionDetails;
  final List<TransportationDetail> transportationDetails;

  const ProcessModel({
    required this.processId,
    required this.processName,
    required this.wasteDetails,
    required this.waterDetails,
    required this.certifications,
    required this.energyDetails,
    required this.materialDetails,
    required this.productionDetails,
    required this.transportationDetails,
  });

  factory ProcessModel.fromJson(Map<String, dynamic> j) => ProcessModel(
    processId: _i(j, 'process_id'),
    processName: _s(j, 'process_name'),
    wasteDetails: _list(j, 'waste_details').map(WasteDetail.fromJson).toList(),
    waterDetails: _list(j, 'water_details').map(WaterDetail.fromJson).toList(),
    certifications: _list(
      j,
      'certifications',
    ).map(CertificationDetail.fromJson).toList(),
    energyDetails: _list(
      j,
      'energy_details',
    ).map(EnergyDetail.fromJson).toList(),
    materialDetails: _list(
      j,
      'material_details',
    ).map(ProcessFieldSet.fromJson).toList(),
    productionDetails: _list(
      j,
      'production_details',
    ).map(ProcessFieldSet.fromJson).toList(),
    transportationDetails: _list(
      j,
      'transportation_details',
    ).map(TransportationDetail.fromJson).toList(),
  );
}

// ════════════════════════════════════════════════════════════════════════
// WASH CARE — `data.wash_care[]`
// ════════════════════════════════════════════════════════════════════════

class WashCareInstruction {
  final String instruction;
  const WashCareInstruction(this.instruction);

  factory WashCareInstruction.fromJson(Map<String, dynamic> j) =>
      WashCareInstruction(_s(j, 'instruction'));
}

// ════════════════════════════════════════════════════════════════════════
// END OF LIFE — `data.end_of_life`
// ════════════════════════════════════════════════════════════════════════

class EndOfLifeModel {
  final int id;
  final String disposalInstructions;
  final String productRecyclability;
  final String takebackProgramStatus;
  final String canBeDonatedOrReused;
  final String takebackDescriptionUrl;
  final String careAndRepairInstructions;
  final String endOfLifeGuidanceApplicable;
  final String materialSeparationInstructions;
  final String packagingRecyclingInstructions;

  const EndOfLifeModel({
    required this.id,
    required this.disposalInstructions,
    required this.productRecyclability,
    required this.takebackProgramStatus,
    required this.canBeDonatedOrReused,
    required this.takebackDescriptionUrl,
    required this.careAndRepairInstructions,
    required this.endOfLifeGuidanceApplicable,
    required this.materialSeparationInstructions,
    required this.packagingRecyclingInstructions,
  });

  factory EndOfLifeModel.fromJson(Map<String, dynamic> j) => EndOfLifeModel(
    id: _i(j, 'id'),
    disposalInstructions: _s(j, 'disposal_instructions'),
    productRecyclability: _s(j, 'product_recyclability'),
    takebackProgramStatus: _s(j, 'takeback_program_status'),
    canBeDonatedOrReused: _s(j, 'can_be_donated_or_reused'),
    takebackDescriptionUrl: _s(j, 'takeback_description_url'),
    careAndRepairInstructions: _s(j, 'care_and_repair_instructions'),
    endOfLifeGuidanceApplicable: _s(j, 'end_of_life_guidance_applicable'),
    materialSeparationInstructions: _s(j, 'material_separation_instructions'),
    packagingRecyclingInstructions: _s(j, 'packaging_recycling_instructions'),
  );
}

// ════════════════════════════════════════════════════════════════════════
// BRAND DETAILS — `data.brand_details`
// ════════════════════════════════════════════════════════════════════════

class BrandDetailsModel {
  final String status;
  final int brandId;
  final String brandCode;
  final int companyId;
  final String brandName;
  final String insertedBy;
  final bool isAuditor;
  final bool isPartneredWith;
  final bool isTraceComplete;

  const BrandDetailsModel({
    required this.status,
    required this.brandId,
    required this.brandCode,
    required this.companyId,
    required this.brandName,
    required this.insertedBy,
    required this.isAuditor,
    required this.isPartneredWith,
    required this.isTraceComplete,
  });

  factory BrandDetailsModel.fromJson(Map<String, dynamic> j) =>
      BrandDetailsModel(
        status: _s(j, 'status'),
        brandId: _i(j, 'brand_id'),
        brandCode: _s(j, 'brandcode'),
        companyId: _i(j, 'companyid'),
        brandName: _s(j, 'brand_name'),
        insertedBy: _s(j, 'insertedby'),
        isAuditor: _b(j, 'is_auditor'),
        isPartneredWith: _b(j, 'ispartneredwith'),
        isTraceComplete: _b(j, 'istracecomplete'),
      );
}

// ════════════════════════════════════════════════════════════════════════
// PRODUCT DETAILS — `data.product_details`
// ════════════════════════════════════════════════════════════════════════

class ProductDetailsModel {
  final int userId;
  final int brandId;
  final String eanGtin;
  final int industryId;
  final int productId;
  final String hsnHsCode;
  final String productImage;
  final String toySizeUnit;
  final String styleCodeSku;
  final String manufacturedBy;
  final String storyCollection;
  final String countryOfOrigin;
  final String productNameStyle;
  final String productDescription;
  final double toySizeDimensions;
  final String ageGradingWarnings;
  final String productCategoryType;

  const ProductDetailsModel({
    required this.userId,
    required this.brandId,
    required this.eanGtin,
    required this.industryId,
    required this.productId,
    required this.hsnHsCode,
    required this.productImage,
    required this.toySizeUnit,
    required this.styleCodeSku,
    required this.manufacturedBy,
    required this.storyCollection,
    required this.countryOfOrigin,
    required this.productNameStyle,
    required this.productDescription,
    required this.toySizeDimensions,
    required this.ageGradingWarnings,
    required this.productCategoryType,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> j) =>
      ProductDetailsModel(
        userId: _i(j, 'userid'),
        brandId: _i(j, 'brand_id'),
        eanGtin: _s(j, 'ean_gtin'),
        industryId: _i(j, 'industryid'),
        productId: _i(j, 'product_id'),
        hsnHsCode: _s(j, 'hsn_hs_code'),
        productImage: _s(j, 'product_image'),
        toySizeUnit: _s(j, 'toy_size_unit'),
        styleCodeSku: _s(j, 'style_code_sku'),
        manufacturedBy: _s(j, 'manufactured_by'),
        storyCollection: _s(j, 'story_collection'),
        countryOfOrigin: _s(j, 'country_of_origin'),
        productNameStyle: _s(j, 'product_name_style'),
        productDescription: _s(j, 'product_description'),
        toySizeDimensions: _d(j, 'toy_size_dimensions'),
        ageGradingWarnings: _s(j, 'age_grading_warnings'),
        productCategoryType: _s(j, 'product_category_type'),
      );
}

// ════════════════════════════════════════════════════════════════════════
// TOP-LEVEL RESPONSE — the full decrypted `getToyDppProcessDetail` payload.
// ════════════════════════════════════════════════════════════════════════

class DppProcessDetailModel {
  final bool issuccessful;
  final String message;
  final BatchModel batch;
  final List<ProcessModel> processes;
  final List<WashCareInstruction> washCare;
  final EndOfLifeModel endOfLife;
  final BrandDetailsModel brandDetails;
  final ProductDetailsModel productDetails;

  const DppProcessDetailModel({
    required this.issuccessful,
    required this.message,
    required this.batch,
    required this.processes,
    required this.washCare,
    required this.endOfLife,
    required this.brandDetails,
    required this.productDetails,
  });

  /// [json] is the full decrypted map:
  ///   { "issuccessful": bool, "message": string,
  ///     "data": { "batch", "processes", "wash_care", "end_of_life",
  ///               "brand_details", "product_details" } }
  /// Throws [DppProcessDetailException] when `issuccessful` is `false`.
  factory DppProcessDetailModel.fromJson(Map<String, dynamic> json) {
    final ok = _b(json, 'issuccessful', true);
    final message = _s(json, 'message');
    if (!ok) {
      throw DppProcessDetailException(
        message.isEmpty ? 'Request failed' : message,
      );
    }

    final data = _obj(json, 'data');
    return DppProcessDetailModel(
      issuccessful: ok,
      message: message,
      batch: BatchModel.fromJson(_obj(data, 'batch')),
      processes: _list(data, 'processes').map(ProcessModel.fromJson).toList(),
      washCare: _list(
        data,
        'wash_care',
      ).map(WashCareInstruction.fromJson).toList(),
      endOfLife: EndOfLifeModel.fromJson(_obj(data, 'end_of_life')),
      brandDetails: BrandDetailsModel.fromJson(_obj(data, 'brand_details')),
      productDetails: ProductDetailsModel.fromJson(
        _obj(data, 'product_details'),
      ),
    );
  }

  /// Finds a process by its exact `process_name` (case-insensitive) — e.g.
  /// `processByName('Packaging')` — or `null` if the backend didn't send
  /// that step for this batch. Handy once a screen is wired to one
  /// specific manufacturing step rather than the whole list.
  ProcessModel? processByName(String name) {
    final lower = name.toLowerCase();
    for (final p in processes) {
      if (p.processName.toLowerCase() == lower) return p;
    }
    return null;
  }
}
