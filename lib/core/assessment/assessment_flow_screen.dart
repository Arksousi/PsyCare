import 'package:flutter/material.dart';
import 'assessment_bank.dart';
import 'assessment_models.dart';
import 'assessment_store.dart';
import '../widgets/app_button.dart';
import 'assessment_submitted_screen.dart';

//lol
class AssessmentFlowScreen extends StatefulWidget {
  const AssessmentFlowScreen({super.key});

  @override
  State<AssessmentFlowScreen> createState() => _AssessmentFlowScreenState();
}

class _AssessmentFlowScreenState extends State<AssessmentFlowScreen> {
  late final List<AssessmentQuestion> _all;
  late final Map<String, AssessmentQuestion> _byId;

  final List<String> _path = [];
  final List<AssessmentAnswer> _answers = [];

  String _currentId = AssessmentBank.startId;

  bool _locked = false; // prevents double taps / double submit

  @override
  void initState() {
    super.initState();
    _all = AssessmentBank.build();
    _byId = {for (final q in _all) q.id: q};

    _path.add(_currentId);
  }

  AssessmentQuestion? get _q => _byId[_currentId];

  void _select(Choice c) {
    if (_locked) return;

    // Save/replace answer for current question
    _answers.removeWhere((a) => a.questionId == _currentId);
    _answers.add(
      AssessmentAnswer(questionId: _currentId, choiceId: c.id, score: c.score),
    );

    // Decide next
    final next = _nextQuestionId(currentQuestionId: _currentId, choice: c);

    if (next == null) {
      _submit();
      return;
    }

    setState(() {
      _currentId = next;
      _path.add(next);
    });
  }

  void _back() {
    if (_locked) return;

    if (_path.length <= 1) {
      Navigator.of(context).pop(); // Back to Home
      return;
    }
    setState(() {
      _path.removeLast();
      _currentId = _path.last;
      // Keep answers so user can change them
    });
  }

  String? _nextQuestionId({
    required String currentQuestionId,
    required Choice choice,
  }) {
    // Hard-coded adaptive logic (safe and simple)

    // Gate sequence
    if (currentQuestionId == "gate_1") return "gate_2";
    if (currentQuestionId == "gate_2") return "gate_3";
    if (currentQuestionId == "gate_3") return "gate_4";

    if (currentQuestionId == "gate_4") {
      final anx = _scoreOf("gate_1") + _scoreOf("gate_2");
      final dep = _scoreOf("gate_3") + _scoreOf("gate_4");

      // If both low → go to well-being quick check then finish
      if (anx <= 2 && dep <= 2) return "wb_1";

      // If anxiety dominates → anxiety module
      if (anx >= dep) return "anx_1";

      // Else mood module
      return "mood_1";
    }

    // Well-being mini
    if (currentQuestionId == "wb_1") return "wb_2";
    if (currentQuestionId == "wb_2") return null;

    // Anxiety module
    if (currentQuestionId == "anx_1") return "anx_2";
    if (currentQuestionId == "anx_2") {
      // If high anxiety, include safety gate
      final anx =
          _scoreOf("gate_1") +
          _scoreOf("gate_2") +
          _scoreOf("anx_1") +
          _scoreOf("anx_2");
      if (anx >= 7) return "safety_1";
      return null;
    }

    // Mood module
    if (currentQuestionId == "mood_1") return "mood_2";
    if (currentQuestionId == "mood_2") {
      final dep =
          _scoreOf("gate_3") +
          _scoreOf("gate_4") +
          _scoreOf("mood_1") +
          _scoreOf("mood_2");
      if (dep >= 7) return "safety_1";
      return null;
    }

    // Safety ends
    if (currentQuestionId == "safety_1") return null;

    return null;
  }

  int _scoreOf(String qid) {
    final a = _answers.where((x) => x.questionId == qid).toList();
    if (a.isEmpty) return 0;
    return a.first.score;
  }

  int _estimatedTotalSteps() {
    final gateDone = _path.where((id) => id.startsWith("gate_")).length;
    final hasSafety = _path.contains("safety_1");
    final moduleDone = _path
        .where(
          (id) =>
              id.startsWith("wb_") ||
              id.startsWith("anx_") ||
              id.startsWith("mood_"),
        )
        .length;

    final est = 4 + 2 + (hasSafety ? 1 : 0);

    return est < _path.length ? _path.length : est;
  }

  Future<void> _submit() async {
    if (_locked) return;
    setState(() => _locked = true);

    final safetyAnswer = _answers
        .where((a) => a.questionId == "safety_1")
        .toList();
    final flaggedSafety =
        safetyAnswer.isNotEmpty && safetyAnswer.first.choiceId != "safe_no";

    final gateTotal =
        _scoreOf("gate_1") +
        _scoreOf("gate_2") +
        _scoreOf("gate_3") +
        _scoreOf("gate_4");
    final flaggedFollowUp = gateTotal >= 4 || flaggedSafety;

    final packet = AssessmentPacket(
      submittedAt: DateTime.now(),
      answers: List.unmodifiable(_answers),
      flaggedForFollowUp: flaggedFollowUp,
      flaggedSafety: flaggedSafety,
    );

    AssessmentStore.instance.submit(packet);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AssessmentSubmittedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final question = _q;
    if (question == null) {
      // Safe fallback UI instead of crashing
      return Scaffold(
        appBar: AppBar(
          title: const Text("Assessment"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Text(
              "Assessment content is missing (question id: $_currentId).",
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
        ),
      );
    }

    final total = _estimatedTotalSteps();
    final progress = (total == 0)
        ? 0.0
        : (_path.length / total).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assessment"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _back,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(99),
                backgroundColor: cs.outlineVariant,
              ),
              const SizedBox(height: 18),
              Text(
                question.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                question.subtitle,
                style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
              ),
              const SizedBox(height: 18),
              ...question.choices.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppButton(
                    label: c.text,
                    isSecondary: true,
                    onPressed: () {
                      if (_locked) return;
                      _select(c);
                    },
                  ),
                ),
              ),
              const Spacer(),
              Text(
                "This is not a diagnosis. Your therapist will review your answers.",
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
