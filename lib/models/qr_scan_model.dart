// lib/models/qr_scan_model.dart

class QrScanModel {
  final int? id;
  final String qrText;
  final String scanDate;

  const QrScanModel({
    this.id,
    required this.qrText,
    required this.scanDate,
  });

  /// Create model from SQLite map
  factory QrScanModel.fromMap(Map<String, dynamic> map) {
    return QrScanModel(
      id: map['id'] as int?,
      qrText: map['qrText'] as String,
      scanDate: map['scanDate'] as String,
    );
  }

  /// Convert model to SQLite map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'qrText': qrText,
      'scanDate': scanDate,
    };
  }

  /// Copy with modifications
  QrScanModel copyWith({
    int? id,
    String? qrText,
    String? scanDate,
  }) {
    return QrScanModel(
      id: id ?? this.id,
      qrText: qrText ?? this.qrText,
      scanDate: scanDate ?? this.scanDate,
    );
  }

  @override
  String toString() =>
      'QrScanModel(id: $id, qrText: $qrText, scanDate: $scanDate)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QrScanModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          qrText == other.qrText &&
          scanDate == other.scanDate;

  @override
  int get hashCode => Object.hash(id, qrText, scanDate);
}
