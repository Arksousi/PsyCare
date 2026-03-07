enum QuestionType { singleChoice }

class Choice {
  final String id;
  final String text;
  final int score; // For routing only (not shown to patient)

  const Choice({
    required this.id,
    required this.text,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'score': score,
  };

  factory Choice.fromJson(Map<String, dynamic> json) => Choice(
    id: json['id'] as String,
    text: json['text'] as String,
    score: (json['score'] as num).toInt(),
  );
}

class AssessmentQuestion {
  final String id;
  final String title;
  final String subtitle;
  final QuestionType type;
  final List<Choice> choices;

  /// Optional branching: map from choiceId -> nextQuestionId
  final Map<String, String>? nextByChoice;

  const AssessmentQuestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.choices,
    this.nextByChoice,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'type': type.name,
    'choices': choices.map((c) => c.toJson()).toList(),
    'nextByChoice': nextByChoice,
  };

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) => AssessmentQuestion(
    id: json['id'] as String,
    title: json['title'] as String,
    subtitle: json['subtitle'] as String,
    type: QuestionType.values.firstWhere(
          (t) => t.name == (json['type'] as String),
      orElse: () => QuestionType.singleChoice,
    ),
    choices: (json['choices'] as List)
        .map((e) => Choice.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    nextByChoice: json['nextByChoice'] == null
        ? null
        : Map<String, String>.from(json['nextByChoice'] as Map),
  );
}

class AssessmentAnswer {
  final String questionId;
  final String choiceId;
  final int score;

  const AssessmentAnswer({
    required this.questionId,
    required this.choiceId,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'choiceId': choiceId,
    'score': score,
  };

  factory AssessmentAnswer.fromJson(Map<String, dynamic> json) => AssessmentAnswer(
    questionId: json['questionId'] as String,
    choiceId: json['choiceId'] as String,
    score: (json['score'] as num).toInt(),
  );
}

class AssessmentPacket {
  final DateTime submittedAt;
  final List<AssessmentAnswer> answers;

  /// Flags for therapist triage (patient will NOT see these)
  final bool flaggedForFollowUp;
  final bool flaggedSafety;

  const AssessmentPacket({
    required this.submittedAt,
    required this.answers,
    required this.flaggedForFollowUp,
    required this.flaggedSafety,
  });

  int get totalScore => answers.fold(0, (sum, a) => sum + a.score);

  Map<String, dynamic> toJson() => {
    'submittedAt': submittedAt.toIso8601String(),
    'answers': answers.map((a) => a.toJson()).toList(),
    'flaggedForFollowUp': flaggedForFollowUp,
    'flaggedSafety': flaggedSafety,
    'totalScore': totalScore,
  };

  factory AssessmentPacket.fromJson(Map<String, dynamic> json) => AssessmentPacket(
    submittedAt: DateTime.parse(json['submittedAt'] as String),
    answers: (json['answers'] as List)
        .map((e) => AssessmentAnswer.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    flaggedForFollowUp: json['flaggedForFollowUp'] as bool,
    flaggedSafety: json['flaggedSafety'] as bool,
  );
}
