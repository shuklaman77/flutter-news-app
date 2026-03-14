import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/news_api_service.dart';
import '../services/local_storage_service.dart';
import '../services/connectivity_service.dart';

enum NewsLoadingState { idle, loading, loaded, error, loadingMore }

class NewsProvider extends ChangeNotifier {
  final NewsApiService _apiService = NewsApiService();
  final LocalStorageService _storageService = LocalStorageService();
  final ConnectivityService _connectivityService = ConnectivityService();

  List<Article> _articles = [];
  List<Article> _bookmarks = [];
  NewsLoadingState _state = NewsLoadingState.idle;
  String _errorMessage = '';
  String _currentCategory = 'general';
  String _searchQuery = '';
  bool _isOffline = false;
  bool _isSearchMode = false;
  int _currentPage = 1;
  bool _hasMore = true;

  // Getters
  List<Article> get articles => _articles;
  List<Article> get bookmarks => _bookmarks;
  NewsLoadingState get state => _state;
  String get errorMessage => _errorMessage;
  String get currentCategory => _currentCategory;
  bool get isOffline => _isOffline;
  bool get isSearchMode => _isSearchMode;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  NewsProvider() {
    _initConnectivity();
    loadBookmarks();
  }

  void _initConnectivity() {
    _connectivityService.connectionStream.listen((isConnected) {
      _isOffline = !isConnected;
      notifyListeners();
      if (isConnected && _articles.isEmpty) {
        fetchHeadlines(refresh: true);
      }
    });
  }

  Future<void> fetchHeadlines({
    String? category,
    bool refresh = false,
  }) async {
    if (category != null) _currentCategory = category;
    _isSearchMode = false;
    _searchQuery = '';

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _articles = [];
    }

    if (_state == NewsLoadingState.loading ||
        _state == NewsLoadingState.loadingMore) return;

    _state = _currentPage == 1
        ? NewsLoadingState.loading
        : NewsLoadingState.loadingMore;
    notifyListeners();

    try {
      final isConnected = await _connectivityService.isConnected();
      _isOffline = !isConnected;

      if (isConnected) {
        final newArticles = await _apiService.getTopHeadlines(
          category: _currentCategory,
          page: _currentPage,
        );

        if (_currentPage == 1) {
          _articles = newArticles;
          await _storageService.saveArticles(_currentCategory, newArticles);
        } else {
          _articles.addAll(newArticles);
        }

        _hasMore = newArticles.length >= 20;
        _currentPage++;
      } else {
        // Load from cache
        if (_currentPage == 1) {
          _articles =
              await _storageService.getArticles(_currentCategory);
          if (_articles.isEmpty) {
            _errorMessage =
                'No internet connection and no cached data available.';
            _state = NewsLoadingState.error;
            notifyListeners();
            return;
          }
        }
        _hasMore = false;
      }

      _state = NewsLoadingState.loaded;
    } catch (e) {
      // Try to load cached data on error
      if (_currentPage == 1) {
        try {
          _articles = await _storageService.getArticles(_currentCategory);
          if (_articles.isNotEmpty) {
            _isOffline = true;
            _state = NewsLoadingState.loaded;
          } else {
            _errorMessage = e.toString().replaceAll('Exception: ', '');
            _state = NewsLoadingState.error;
          }
        } catch (_) {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _state = NewsLoadingState.error;
        }
      } else {
        _state = NewsLoadingState.loaded;
        _hasMore = false;
      }
    }

    notifyListeners();
  }

  Future<void> searchNews(String query) async {
    if (query.trim().isEmpty) {
      _isSearchMode = false;
      fetchHeadlines(refresh: true);
      return;
    }

    _isSearchMode = true;
    _searchQuery = query;
    _articles = [];
    _state = NewsLoadingState.loading;
    notifyListeners();

    try {
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        _errorMessage = 'Search requires an internet connection.';
        _state = NewsLoadingState.error;
        notifyListeners();
        return;
      }

      _articles = await _apiService.searchNews(query: query);
      _state = NewsLoadingState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = NewsLoadingState.error;
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_state == NewsLoadingState.loadingMore || !_hasMore || _isSearchMode) {
      return;
    }
    await fetchHeadlines();
  }

  Future<void> toggleBookmark(Article article) async {
    final isBookmarked = await _storageService.isBookmarked(article.url);
    if (isBookmarked) {
      await _storageService.removeBookmark(article.url);
    } else {
      await _storageService.saveBookmark(article);
    }
    await loadBookmarks();
    notifyListeners();
  }

  Future<bool> isBookmarked(String url) async {
    return _storageService.isBookmarked(url);
  }

  Future<void> loadBookmarks() async {
    _bookmarks = await _storageService.getBookmarks();
    notifyListeners();
  }

  Future<void> checkConnectivity() async {
    final isConnected = await _connectivityService.isConnected();
    _isOffline = !isConnected;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}
