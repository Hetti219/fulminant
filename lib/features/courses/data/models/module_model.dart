class Module {
  final String id;
  final String courseId;
  final String title;
  final String content;

  Module({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
  });

  factory Module.fromMap(Map<String, dynamic> data, String documentId) {
    return Module(
      id: documentId,
      courseId: data['courseId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'content': content,
    };
  }
}
