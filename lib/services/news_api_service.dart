import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsApiService {
  static const String _baseUrl = 'https://newsapi.org/v2';

  static const String _apiKey = '390d544050d6493e927211da511466e5';

  Future<List<Article>> getTopHeadlines({
    String country = 'us',
    String? category,
    String? query,
    int page = 1,
    int pageSize = 20,
  }) async {
    final Map<String, String> queryParams = {
      'apiKey': _apiKey,
      'country': country,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }

    final uri = Uri.parse('$_baseUrl/top-headlines')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          final List articlesJson = data['articles'] ?? [];
          return articlesJson
              .map((json) => Article.fromJson(json))
              .where((a) => a.title != '[Removed]' && a.url.isNotEmpty)
              .toList();
        }
        throw Exception(data['message'] ?? 'Unknown API error');
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your NewsAPI key.');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Article>> searchNews({
    required String query,
    String? language = 'en',
    String? sortBy = 'publishedAt',
    int page = 1,
    int pageSize = 20,
  }) async {
    final Map<String, String> queryParams = {
      'apiKey': _apiKey,
      'q': query,
      'language': language ?? 'en',
      'sortBy': sortBy ?? 'publishedAt',
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    final uri = Uri.parse('$_baseUrl/everything')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          final List articlesJson = data['articles'] ?? [];
          return articlesJson
              .map((json) => Article.fromJson(json))
              .where((a) => a.title != '[Removed]' && a.url.isNotEmpty)
              .toList();
        }
        throw Exception(data['message'] ?? 'Unknown API error');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
