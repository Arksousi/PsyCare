import 'assessment_models.dart';

/// NOTE:
/// These questions are inspired by validated screening structures:
/// - PHQ-4 for brief depression/anxiety gate
/// - PHQ-9 / GAD-7 for deeper modules
/// - WHO-5 for well-being
/// Wording is paraphrased to keep it safe for reuse.
class AssessmentBank {
  static const String startId = "gate_1";

  static List<AssessmentQuestion> build() {
    return [
      // ---------- GATE (PHQ-4 inspired) ----------
      AssessmentQuestion(
        id: "gate_1",
        title: "In the past 2 weeks…",
        subtitle: "How often did you feel nervous, tense, or on edge?",
        type: QuestionType.singleChoice,
        choices: _freq4,
      ),
      AssessmentQuestion(
        id: "gate_2",
        title: "In the past 2 weeks…",
        subtitle: "How often was it hard to stop or control worrying?",
        type: QuestionType.singleChoice,
        choices: _freq4,
      ),
      AssessmentQuestion(
        id: "gate_3",
        title: "In the past 2 weeks…",
        subtitle: "How often did you feel down, low, or emotionally heavy?",
        type: QuestionType.singleChoice,
        choices: _freq4,
      ),
      AssessmentQuestion(
        id: "gate_4",
        title: "In the past 2 weeks…",
        subtitle: "How often did you lose interest or pleasure in things you usually enjoy?",
        type: QuestionType.singleChoice,
        choices: _freq4,
      ),

      // ---------- WELL-BEING (WHO-5 inspired) ----------
      AssessmentQuestion(
        id: "wb_1",
        title: "Well-being check",
        subtitle: "How often did you feel calm and relaxed recently?",
        type: QuestionType.singleChoice,
        choices: _freq6Positive,
      ),
      AssessmentQuestion(
        id: "wb_2",
        title: "Well-being check",
        subtitle: "How often did you wake up feeling rested?",
        type: QuestionType.singleChoice,
        choices: _freq6Positive,
      ),

      // ---------- ANXIETY MODULE (GAD-7 inspired) ----------
      AssessmentQuestion(
        id: "anx_1",
        title: "Anxiety check",
        subtitle: "How often did you feel restless or unable to relax?",
        type: QuestionType.singleChoice,
        choices: _freq4,
      ),
      AssessmentQuestion(
        id: "anx_2",
        title: "Anxiety check",
        subtitle: "How often did worry make daily tasks harder (study, work, home)?",
        type: QuestionType.singleChoice,
        choices: _freq4,
      ),

      // ---------- MOOD MODULE (PHQ-9 inspired) ----------
      AssessmentQuestion(
        id: "mood_1",
        title: "Mood check",
        subtitle: "How often did you feel tired or low-energy?",
        type: QuestionType.singleChoice,
        choices: _freq4,
      ),
      AssessmentQuestion(
        id: "mood_2",
        title: "Mood check",
        subtitle: "How often did you struggle with sleep (too little or too much)?",
        type: QuestionType.singleChoice,
        choices: _freq4,
      ),

      // ---------- SAFETY (shown only if triggered) ----------
      AssessmentQuestion(
        id: "safety_1",
        title: "Safety check",
        subtitle: "Have you recently felt unsafe with yourself, or had thoughts of self-harm?",
        type: QuestionType.singleChoice,
        choices: const [
          Choice(id: "safe_no", text: "No", score: 0),
          Choice(id: "safe_yes_but_ok", text: "Yes, but I feel safe right now", score: 2),
          Choice(id: "safe_yes_now", text: "Yes, I feel unsafe right now", score: 3),
        ],
      ),
    ];
  }

  // Standard frequency scale (0–3) used by PHQ/GAD style tools
  static const List<Choice> _freq4 = [
    Choice(id: "f0", text: "Not at all", score: 0),
    Choice(id: "f1", text: "Several days", score: 1),
    Choice(id: "f2", text: "More than half the days", score: 2),
    Choice(id: "f3", text: "Nearly every day", score: 3),
  ];

  // 0–5 positive well-being frequency
  static const List<Choice> _freq6Positive = [
    Choice(id: "p5", text: "All of the time", score: 5),
    Choice(id: "p4", text: "Most of the time", score: 4),
    Choice(id: "p3", text: "More than half the time", score: 3),
    Choice(id: "p2", text: "Less than half the time", score: 2),
    Choice(id: "p1", text: "Some of the time", score: 1),
    Choice(id: "p0", text: "At no time", score: 0),
  ];
}
