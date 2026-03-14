class NewsCategory {
  final String id;
  final String label;
  final String emoji;

  const NewsCategory({
    required this.id,
    required this.label,
    required this.emoji,
  });

  static const List<NewsCategory> categories = [
    NewsCategory(id: 'general', label: 'General', emoji: '🌍'),
    NewsCategory(id: 'technology', label: 'Tech', emoji: '💻'),
    NewsCategory(id: 'business', label: 'Business', emoji: '📈'),
    NewsCategory(id: 'sports', label: 'Sports', emoji: '⚽'),
    NewsCategory(id: 'entertainment', label: 'Entertainment', emoji: '🎬'),
    NewsCategory(id: 'health', label: 'Health', emoji: '🏥'),
    NewsCategory(id: 'science', label: 'Science', emoji: '🔬'),
  ];
}
