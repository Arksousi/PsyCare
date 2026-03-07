import 'assessment_models.dart';

class AssessmentStore {
  AssessmentStore._();
  static final AssessmentStore instance = AssessmentStore._();

  final List<AssessmentPacket> _submissions = [];

  /// Read-only view (prevents outside modification)
  List<AssessmentPacket> get submissions => List.unmodifiable(_submissions);

  /// Quick checks (useful for UI)
  bool get hasSubmissions => _submissions.isNotEmpty;

  /// Most recent submission (because we insert at index 0)
  AssessmentPacket? get latest => _submissions.isEmpty ? null : _submissions.first;

  /// Therapist triage helpers
  List<AssessmentPacket> get flaggedForFollowUp =>
      _submissions.where((p) => p.flaggedForFollowUp).toList(growable: false);

  List<AssessmentPacket> get safetyFlagged =>
      _submissions.where((p) => p.flaggedSafety).toList(growable: false);

  /// Add a new submission (latest first)
  void submit(AssessmentPacket packet) {
    _submissions.insert(0, packet);
  }

  /// Clear all submissions (useful for demo/reset)
  void clear() => _submissions.clear();
}
