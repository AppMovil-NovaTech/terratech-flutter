/// US29: interest metrics returned by the protected product API.
final class ProductInterest {
  const ProductInterest({
    required this.productId,
    required this.interestThreshold,
    required this.monthlyConsultations,
    required this.consultationMonth,
    required this.consultationYear,
    required this.lastConsultationAt,
  });

  final int productId;
  final int interestThreshold;
  final int monthlyConsultations;
  final int consultationMonth;
  final int consultationYear;
  final DateTime? lastConsultationAt;

  factory ProductInterest.fromJson(Map<String, dynamic> json) {
    int asInt(Object? value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final lastConsultation = json['lastConsultationAt']?.toString();
    return ProductInterest(
      productId: asInt(json['productId']),
      interestThreshold: asInt(json['interestThreshold']),
      monthlyConsultations: asInt(json['monthlyConsultations']),
      consultationMonth: asInt(json['consultationMonth']),
      consultationYear: asInt(json['consultationYear']),
      lastConsultationAt: lastConsultation == null
          ? null
          : DateTime.tryParse(lastConsultation),
    );
  }
}
