import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/statistics_provider.dart';
import '../models/statistics.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/url_utils.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statisticsAsyncValue = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sự kiện'),
            Tab(text: 'Bài viết'),
            Tab(text: 'Bình luận'),
            Tab(text: 'Ảnh sự kiện'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.deepPurple[200],
          indicatorColor: Colors.white,
        ),
      ),
      body: statisticsAsyncValue.when(
        data: (statisticsData) {
          return Column(
            children: [
              _buildOverallStatsSection(statisticsData.overallStats),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTopEventList(statisticsData.topEvent),
                    _buildTopBlogList(statisticsData.topBlogs),
                    _buildTopCommentList(statisticsData.topComments),
                    _buildTopEventImageList(statisticsData.topEventImages),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Lỗi tải dữ liệu thống kê: ${err.toString()}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildOverallStatsSection(OverallStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.deepPurple[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan thống kê:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple[800],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Sự kiện', stats.totalEvent),
              _buildStatItem('Bài viết', stats.totalBlogs),
              _buildStatItem('Bình luận', stats.totalComments),
              _buildStatItem('Likes', stats.totalLikes),
              _buildStatItem('Votes', stats.totalVotes),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: _buildStatItem('Đánh giá sự kiện TB',
                stats.averageEventRating.toStringAsFixed(2)),
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, dynamic value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[900],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildTopItemCard({
    required int rank,
    required String title,
    String? subtitle,
    String? imageUrl,
    required String valueLabel,
    required String value,
  }) {
    final bool hasOriginalImageUrl = imageUrl != null && imageUrl.isNotEmpty;

    final String? finalImageUrl =
        hasOriginalImageUrl ? getFullPhotoUrl(imageUrl!) : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[700],
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (finalImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: finalImageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) {
                    print('CachedNetworkImage Error: $error for URL: $url');
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              )
            else
              const SizedBox.shrink(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: subtitle == null ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  valueLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopEventList(List<TopEvent> events) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildTopItemCard(
          rank: index + 1,
          title: event.title,
          valueLabel: 'Rating',
          value: event.averageRating.toStringAsFixed(2),
        );
      },
    );
  }

  Widget _buildTopBlogList(List<TopBlog> blogs) {
    return ListView.builder(
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        final blog = blogs[index];
        print('--- Blog Item Index: $index ---');
        print('Blog Title: ${blog.title}');
        print('Blog Author Name: ${blog.authorName}');
        print(
            'Blog Author Avatar URL: N/A (API does not provide avatar URL here)');
        print('Total Likes: ${blog.totalLikes}');
        print('-----------------------------');

        return _buildTopItemCard(
          rank: index + 1,
          title: blog.title ?? '',
          subtitle: 'Bởi ${blog.authorName ?? 'Unknown'}',
          imageUrl: null,
          valueLabel: 'Likes',
          value: blog.totalLikes?.toString() ?? '-',
        );
      },
    );
  }

  Widget _buildTopCommentList(List<TopComment> comments) {
    return ListView.builder(
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        print('--- Comment Item Index: $index ---');
        print('Comment Content: ${comment.content}');
        print('Comment Author Name: ${comment.authorName}');
        print(
            'Comment Author Avatar URL: N/A (API does not provide avatar URL here)');
        print('Total Likes: ${comment.totalLikes}');
        print('---------------------------------');

        return _buildTopItemCard(
          rank: index + 1,
          title: comment.content ?? '',
          subtitle: 'Bởi ${comment.authorName ?? 'Unknown'}',
          imageUrl: null,
          valueLabel: 'Likes',
          value: comment.totalLikes?.toString() ?? '-',
        );
      },
    );
  }

  Widget _buildTopEventImageList(List<TopEventImage> images) {
    if (images.isEmpty) {
      return const Center(
          child: Text('Chưa có ảnh sự kiện nào trong top.',
              style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        print('--- Event Image Item Index: $index ---');
        print('Image Title: ${image.title}');
        print('Image URL (from model): ${image.url}');
        print('Image Author Name: ${image.authorName}');
        print(
            'Image Author Avatar URL: N/A (API does not provide avatar URL here)');
        print('Total Likes: ${image.totalLikes}');
        print('------------------------------------');

        return _buildTopItemCard(
          rank: index + 1,
          title: image.title ?? 'Image',
          subtitle: 'Bởi ${image.authorName ?? 'Unknown'}',
          imageUrl: image.url,
          valueLabel: 'Likes',
          value: image.totalLikes?.toString() ?? '-',
        );
      },
    );
  }
}
