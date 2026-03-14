import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';

class NewsDetailScreen extends StatefulWidget {
  final Article article;
  const NewsDetailScreen({super.key, required this.article});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  bool _isBookmarked = false;
  bool _showFullContent = false;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  Future<void> _checkBookmark() async {
    final isB =
        await context.read<NewsProvider>().isBookmarked(widget.article.url);
    if (mounted) setState(() => _isBookmarked = isB);
  }

  Future<void> _toggleBookmark() async {
    await context.read<NewsProvider>().toggleBookmark(widget.article);
    setState(() => _isBookmarked = !_isBookmarked);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isBookmarked ? 'Bookmarked!' : 'Removed from bookmarks'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.article.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareArticle() {
    Share.share(
      '${widget.article.title}\n\n${widget.article.url}',
      subject: widget.article.title,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.article.urlToImage != null;
    final headerOpacity = hasImage
        ? (1 - (_scrollOffset / 200)).clamp(0.0, 1.0)
        : 1.0;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Hero image / App bar
                SliverAppBar(
                  expandedHeight: hasImage ? 300 : 0,
                  pinned: true,
                  backgroundColor: AppTheme.primaryColor,
                  leading: _buildBackButton(),
                  actions: [
                    _buildActionButton(
                      icon: _isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color: _isBookmarked
                          ? AppTheme.accentColor
                          : AppTheme.textPrimary,
                      onTap: _toggleBookmark,
                    ),
                    _buildActionButton(
                      icon: Icons.share_rounded,
                      onTap: _shareArticle,
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: hasImage
                      ? FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Hero(
                                tag: 'article_${widget.article.url}',
                                child: CachedNetworkImage(
                                  imageUrl: widget.article.urlToImage!,
                                  fit: BoxFit.cover,
                                  placeholder: (c, u) => Container(
                                      color: AppTheme.cardColor),
                                  errorWidget: (c, u, e) => Container(
                                      color: AppTheme.cardColor),
                                ),
                              ),
                              // gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.3),
                                      Colors.transparent,
                                      AppTheme.primaryColor,
                                    ],
                                    stops: const [0, 0.5, 1],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),

                // Article body
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetaRow(),
                        const SizedBox(height: 14),
                        _buildTitle(),
                        const SizedBox(height: 16),
                        _buildDivider(),
                        const SizedBox(height: 16),
                        if (widget.article.description != null)
                          _buildDescription(),
                        const SizedBox(height: 16),
                        _buildContent(),
                        const SizedBox(height: 28),
                        _buildReadMoreButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating bottom bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      Color? color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? Colors.white, size: 18),
      ),
    );
  }

  Widget _buildMetaRow() {
    return Row(
      children: [
        if (widget.article.sourceName != null) ...[
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppTheme.accentColor.withOpacity(0.3)),
            ),
            child: Text(
              widget.article.sourceName!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentLight,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        if (widget.article.publishedAt != null)
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  size: 12, color: AppTheme.textTertiary),
              const SizedBox(width: 4),
              Text(
                AppUtils.formatFullDate(widget.article.publishedAt),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 11,
                    ),
              ),
            ],
          ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildTitle() {
    return Text(
      widget.article.title,
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: 22,
            height: 1.35,
            letterSpacing: -0.5,
          ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.15);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 10,
          height: 3,
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        if (widget.article.author != null &&
            widget.article.author!.isNotEmpty)
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                child: Text(
                  widget.article.author![0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentLight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.article.author!,
                style:
                    Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
              ),
            ],
          ),
        const Spacer(),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.chipBackground,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_stories_outlined,
                  size: 11, color: AppTheme.textTertiary),
              const SizedBox(width: 4),
              Text(
                AppUtils.getReadingTime(
                    widget.article.content, widget.article.description),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.chipBackground),
      ),
      child: Text(
        widget.article.description!,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppTheme.textSecondary,
              height: 1.7,
            ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildContent() {
    final cleanContent =
        AppUtils.cleanContent(widget.article.content);
    if (cleanContent.isEmpty) return const SizedBox.shrink();

    final displayContent = _showFullContent
        ? cleanContent
        : AppUtils.truncateText(cleanContent, 400);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayContent,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.75,
                color: AppTheme.textSecondary,
              ),
        ),
        if (!_showFullContent && cleanContent.length > 400)
          GestureDetector(
            onTap: () => setState(() => _showFullContent = true),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Read more',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 250.ms);
  }

  Widget _buildReadMoreButton() {
    return GestureDetector(
      onTap: _openInBrowser,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.accentColor, AppTheme.accentLight],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentColor.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.open_in_browser_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              'Read Full Article',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .slideY(begin: 0.2);
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor.withOpacity(0),
            AppTheme.primaryColor,
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BottomBarButton(
              icon: Icons.arrow_back_rounded,
              label: 'Back',
              onTap: () => Navigator.pop(context),
              outlined: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _BottomBarButton(
              icon: Icons.share_rounded,
              label: 'Share Article',
              onTap: _shareArticle,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  const _BottomBarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : AppTheme.accentColor,
          borderRadius: BorderRadius.circular(12),
          border: outlined
              ? Border.all(color: AppTheme.chipBackground, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: outlined
                  ? AppTheme.textSecondary
                  : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: outlined
                    ? AppTheme.textSecondary
                    : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
