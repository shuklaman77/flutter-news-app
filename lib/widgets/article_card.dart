import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final int index;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.urlToImage != null) _buildImage(),
              _buildContent(context),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 + index * 60))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildImage() {
    return Hero(
      tag: 'article_${article.url}',
      child: CachedNetworkImage(
        imageUrl: article.urlToImage!,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 180,
          color: AppTheme.shimmerBase,
          child: Center(
            child: Icon(
              Icons.image_outlined,
              color: AppTheme.textTertiary,
              size: 40,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 120,
          color: AppTheme.shimmerBase,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: AppTheme.textTertiary,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source + Time row
          Row(
            children: [
              if (article.sourceName != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    article.sourceName!,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.accentLight,
                          fontSize: 10,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Spacer(),
              Text(
                AppUtils.formatDate(article.publishedAt),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 11,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            article.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  height: 1.4,
                  letterSpacing: -0.2,
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (article.description != null &&
              article.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              article.description!,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          // Footer
          Row(
            children: [
              if (article.author != null && article.author!.isNotEmpty) ...[
                CircleAvatar(
                  radius: 10,
                  backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                  child: Text(
                    article.author!.isNotEmpty
                        ? article.author![0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.accentLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    article.author!,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 11,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else
                const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppTheme.accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeaturedArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const FeaturedArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              if (article.urlToImage != null)
                Hero(
                  tag: 'article_${article.url}',
                  child: CachedNetworkImage(
                    imageUrl: article.urlToImage!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: AppTheme.cardColor),
                    errorWidget: (context, url, error) =>
                        Container(color: AppTheme.cardColor),
                  ),
                )
              else
                Container(color: AppTheme.cardColor),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.2, 0.6, 1.0],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '⚡ FEATURED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (article.sourceName != null)
                            Text(
                              article.sourceName!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const Spacer(),
                          Text(
                            AppUtils.formatDate(article.publishedAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.title,
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  height: 1.3,
                                  letterSpacing: -0.3,
                                ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.95, 0.95), duration: 500.ms, curve: Curves.easeOut);
  }
}
