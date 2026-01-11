import 'package:cloud_firestore/cloud_firestore.dart';

class Case {
  final CaseType type; // required
  final TimeShift shift;
  final String imageUrl;
  final String? description;
  final CaseState state;
  final DateTime date;

  Case({
    required this.type,
    required this.shift,
    required this.imageUrl,
    this.description,
    this.state = CaseState.pending,
    required this.date,
  });

  /// 🔥 From Firestore document
  factory Case.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Case(
      type: CaseType.values.byName(data['type']),
      shift: TimeShift.values.byName(data['shift']),
      imageUrl: data['imageUrl'],
      description: data['description'],
      state: data['state'] != null
          ? CaseState.values.byName(data['state'])
          : CaseState.pending,
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}


enum CaseType {
  toothExtraction,
  cavityFilling,
  rootCanal,
  scalingPolishing,
  dentalCheckup,
  fluorideTreatment,
  fissureSealant,
  cosmeticConsultation,
  emergencyPainRelief,
}
extension CaseTypeExtension on CaseType {
  String get label {
    switch (this) {
      case CaseType.toothExtraction:
        return "Tooth Extraction";
      case CaseType.cavityFilling:
        return "Cavity Filling";
      case CaseType.rootCanal:
        return "Root Canal";
      case CaseType.scalingPolishing:
        return "Scaling & Polishing";
      case CaseType.dentalCheckup:
        return "Dental Checkup";
      case CaseType.fluorideTreatment:
        return "Fluoride Treatment";
      case CaseType.fissureSealant:
        return "Fissure Sealant";
      case CaseType.cosmeticConsultation:
        return "Cosmetic Consultation";
      case CaseType.emergencyPainRelief:
        return "Emergency Pain Relief";
    }
  }
}


enum TimeShift {
  morning , //9-12
  afternoon, //12-3
  evening //3-6
}

enum CaseState {
  pending,
  booked,
  cancelled,
  timedOut,
  completed,

}