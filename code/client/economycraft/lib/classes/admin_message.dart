class AdminMessage {
  final int id;
  final String title;
  final String content;
  final DateTime date;
  final String authorName;
  final bool important;

  AdminMessage({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.authorName,
    this.important = false,
  });
}
