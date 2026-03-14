import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/news_provider.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/category_chips.dart';
import '../widgets/shimmer_widgets.dart';
import '../widgets/offline_banner.dart';
import '../widgets/error_widgets.dart';
import 'news_detail_screen.dart';
import 'bookmarks_screen.dart';

class HeadlinesScreen extends StatefulWidget {
  const HeadlinesScreen({super.key});

  @override
  State<HeadlinesScreen> createState() => _HeadlinesScreenState();
}

class _HeadlinesScreenState extends State<HeadlinesScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _searchAnimController;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scrollController.addListener(_onScroll);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NewsProvider>();
      provider.fetchHeadlines(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<NewsProvider>().loadMore();
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _searchAnimController.forward();
      } else {
        _searchAnimController.reverse();
        _searchController.clear();
        context.read<NewsProvider>().fetchHeadlines(refresh: true);
      }
    });
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      context.read<NewsProvider>().searchNews(query);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Consumer<NewsProvider>(
            builder: (context, provider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(context, provider),
                  if (provider.isOffline) const OfflineBanner(),
                  if (!_isSearchVisible)
                    CategoryChipsRow(
                      selectedCategory: provider.currentCategory,
                      onCategorySelected: (category) {
                        provider.fetchHeadlines(
                            category: category, refresh: true);
                      },
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildContent(context, provider),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, NewsProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NewsFlash',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideX(begin: -0.2, end: 0, duration: 500.ms),
                    Text(
                      provider.isSearchMode
                          ? 'Search results for "${provider.searchQuery}"'
                          : 'Stay informed, stay ahead',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 100.ms),
                  ],
                ),
              ),
              // Search toggle
              _buildIconButton(
                icon: _isSearchVisible
                    ? Icons.close_rounded
                    : Icons.search_rounded,
                onTap: _toggleSearch,
              ),
              const SizedBox(width: 4),
              // Bookmarks
              _buildIconButton(
                icon: Icons.bookmark_outline_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BookmarksScreen()),
                  );
                },
              ),
            ],
          ),
          if (_isSearchVisible) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              autofocus: true,
              onSubmitted: _onSearch,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search news...',
                prefixIcon:
                    const Icon(Icons.search_rounded, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  color: AppTheme.accentColor,
                  onPressed: () => _onSearch(_searchController.text),
                ),
              ),
            ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.3),
          ],
        ],
      ),
    );
  }

  Widget _buildIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.chipBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppTheme.textPrimary),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, NewsProvider provider) {
    if (provider.state == NewsLoadingState.loading) {
      return const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: ShimmerList(count: 6),
      );
    }

    if (provider.state == NewsLoadingState.error) {
      return NewsErrorWidget(
        message: provider.errorMessage,
        onRetry: () => provider.fetchHeadlines(refresh: true),
      );
    }

    if (provider.articles.isEmpty) {
      return EmptyStateWidget(
        title: 'No articles found',
        subtitle: 'Try a different category or check back later',
        icon: Icons.newspaper_outlined,
        buttonLabel: 'Refresh',
        onAction: () => provider.fetchHeadlines(refresh: true),
      );
    }

    return RefreshIndicator(
      color: AppTheme.accentColor,
      backgroundColor: AppTheme.cardColor,
      onRefresh: () => provider.fetchHeadlines(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.articles.length +
            (provider.state == NewsLoadingState.loadingMore ? 1 : 0) +
            1, // +1 for featured header
        itemBuilder: (context, index) {
          // Featured card (first article)
          if (index == 0 && provider.articles.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FeaturedArticleCard(
                article: provider.articles.first,
                onTap: () => _navigateToDetail(provider.articles.first),
              ),
            );
          }

          // Section header
          if (index == 1) {
            return Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Text(
                    'Latest News',
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${provider.articles.length - 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Loading indicator at bottom
          if (index == provider.articles.length + 1) {
            return Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: provider.hasMore
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.accentColor,
                      ),
                    )
                  : Text(
                      'You\'re all caught up ✓',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
            );
          }

          // Skip first article (used in featured)
          final articleIndex = index - 1; // -1 for the header offset
          if (articleIndex <= 0 ||
              articleIndex >= provider.articles.length) {
            return const SizedBox.shrink();
          }

          final article = provider.articles[articleIndex];
          return ArticleCard(
            article: article,
            onTap: () => _navigateToDetail(article),
            index: articleIndex,
          );
        },
      ),
    );
  }

  void _navigateToDetail(Article article) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NewsDetailScreen(article: article),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}
