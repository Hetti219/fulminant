class ActivityModel {
  final String type; // e.g., "mcq"
  final String question;
  final List<String> options;
  final String answer;

  ActivityModel({
    required this.type,
    required this.question,
    required this.options,
    required this.answer,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> data) {
    return ActivityModel(
      type: data['type'] ?? 'mcq',
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      answer: data['answer'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'question': question,
      'options': options,
      'answer': answer,
    };
  }
}
