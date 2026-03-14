import 'package:hive_flutter/hive_flutter.dart';
import '../models/article.dart';

class LocalStorageService {
  static const String _articlesBoxPrefix = 'articles_';
  static const String _metaBox = 'meta';

  Future<void> saveArticles(String category, List<Article> articles) async {
    final box = await Hive.openBox<Article>('$_articlesBoxPrefix$category');
    await box.clear();
    for (int i = 0; i < articles.length; i++) {
      await box.put(i, articles[i]);
    }

    // Save timestamp
    final metaBox = await Hive.openBox(_metaBox);
    await metaBox.put('${category}_timestamp', DateTime.now().toIso8601String());
  }

  Future<List<Article>> getArticles(String category) async {
    final box = await Hive.openBox<Article>('$_articlesBoxPrefix$category');
    return box.values.toList();
  }

  Future<DateTime?> getLastFetchTime(String category) async {
    final metaBox = await Hive.openBox(_metaBox);
    final timestamp = metaBox.get('${category}_timestamp');
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  Future<bool> isCacheStale(String category,
      {Duration staleDuration = const Duration(minutes: 15)}) async {
    final lastFetch = await getLastFetchTime(category);
    if (lastFetch == null) return true;
    return DateTime.now().difference(lastFetch) > staleDuration;
  }

  Future<void> clearCategory(String category) async {
    final box = await Hive.openBox<Article>('$_articlesBoxPrefix$category');
    await box.clear();
  }

  Future<void> clearAll() async {
    await Hive.deleteFromDisk();
  }

  Future<void> saveBookmark(Article article) async {
    final box = await Hive.openBox<Article>('bookmarks');
    await box.put(article.url, article);
  }

  Future<void> removeBookmark(String url) async {
    final box = await Hive.openBox<Article>('bookmarks');
    await box.delete(url);
  }

  Future<List<Article>> getBookmarks() async {
    final box = await Hive.openBox<Article>('bookmarks');
    return box.values.toList();
  }

  Future<bool> isBookmarked(String url) async {
    final box = await Hive.openBox<Article>('bookmarks');
    return box.containsKey(url);
  }
}
