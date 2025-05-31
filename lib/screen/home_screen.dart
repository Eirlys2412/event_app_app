import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/apilist.dart';
import 'detail_event_screen.dart';
import '../widget/drawer_custom.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'blog_detail_screen.dart';
import '../widgets/theme_button.dart';
import '../widgets/theme_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../models/blog_approved.dart';
import '../constants/pref_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/media_viewer.dart';
import '../utils/url_utils.dart';
import '../providers/blog_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> allEvents = [];
  List<Map<String, dynamic>> filteredEvents = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _currentEventIndex = 0;

  @override
  void initState() {
    super.initState();
    print('_HomeScreenState initState started.'); // Log khi initState bắt đầu
    print('Calling loadData from initState.'); // Log trước khi gọi loadData
    loadData();
    print('_HomeScreenState initState finished.'); // Log khi initState kết thúc
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      final token = await PrefData.getToken();
      print(
          'Auth token: ${token?.substring(0, 10)}...'); // Debug log - only show first 10 chars

      if (token == null || token.isEmpty) {
        throw Exception('Vui lòng đăng nhập để thực hiện chức năng này');
      }

      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      print('Error getting auth headers: $e'); // Debug log
      throw Exception('Lỗi xác thực: ${e.toString()}');
    }
  }

  Future<void> loadData() async {
    print('loadData method started in HomeScreen.');
    try {
      setState(() => isLoading = true);

      // Load events
      print('Starting event loading section...'); // Log before event loading
      try {
        final headers = await _getAuthHeaders();
        final eventResponse = await http.get(
          Uri.parse(api_event),
          headers: headers,
        );

        print('Event Response Status: ${eventResponse.statusCode}');
        print('Event Response Body: ${eventResponse.body}');

        if (eventResponse.statusCode == 200) {
          final eventData = jsonDecode(eventResponse.body)['data'] as List;

          // Fix URL for all event resources
          for (var event in eventData) {
            if (event['resources_data'] != null &&
                event['resources_data'] is List) {
              for (var res in event['resources_data']) {
                if (res['url'] != null) {
                  res['url'] = fixImageUrl(res['url']);
                }
              }
            }
          }

          final sortedEvents = List<Map<String, dynamic>>.from(
            eventData.map((item) => Map<String, dynamic>.from(item as Map)),
          )..sort((a, b) {
              final dateA = DateTime.parse(a['created_at'] ?? '');
              final dateB = DateTime.parse(b['created_at'] ?? '');
              return dateB.compareTo(dateA);
            });

          setState(() {
            allEvents = sortedEvents.take(5).toList();
            filteredEvents = allEvents;
          });
          print(
              'Event loading section finished successfully.'); // Log after successful event loading
        } else {
          print('Error loading events: ${eventResponse.statusCode}');
          print('Error response: ${eventResponse.body}');
          setState(() {
            allEvents = [];
            filteredEvents = [];
          });
          print(
              'Event loading section finished with API error.'); // Log after API error in event loading
        }
      } catch (e) {
        print('Error loading events in HomeScreen: $e');
        setState(() {
          allEvents = [];
          filteredEvents = [];
        });
        print(
            'Event loading section finished with exception.'); // Log after exception in event loading
      }
    } catch (e) {
      print("Error in loadData: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _search(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        filteredEvents = allEvents;
      } else {
        filteredEvents = allEvents
            .where((event) => (event['title'] ?? '')
                .toLowerCase()
                .contains(keyword.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('_HomeScreenState build method called.'); // Log khi build được gọi
    final themeState = ref.watch(themeProvider);
    // Watch the blog list from the provider
    final blogList = ref.watch(blogListProvider);

    // Select the latest 5 blogs
    final latestBlogs = blogList.take(5).toList();

    return Scaffold(
      drawer: const DrawerCustom(),
      backgroundColor: themeState.backgroundColor,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sự kiện...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: themeState.secondaryTextColor),
                ),
                style: TextStyle(color: themeState.primaryTextColor),
                onChanged: _search,
              )
            : Text(
                'Trang chủ',
                style: TextStyle(color: themeState.primaryTextColor),
              ),
        backgroundColor: themeState.appBarColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: themeState.primaryTextColor,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _search('');
                }
              });
            },
          ),
          const ThemeButton(),
          const ThemeSelector(),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sự kiện gần đây',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CarouselSlider.builder(
              itemCount: filteredEvents.isNotEmpty ? filteredEvents.length : 1,
              options: CarouselOptions(
                height: 280,
                viewportFraction: 0.8,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentEventIndex = index;
                  });
                },
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
              ),
              itemBuilder: (context, index, realIndex) {
                if (filteredEvents.isEmpty) {
                  return Center(
                    child: Text(
                      'Không có sự kiện nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return _buildEventCard(
                    filteredEvents[index], Theme.of(context));
              },
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: 8),
          ),
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: filteredEvents.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(
                          _currentEventIndex == entry.key ? 0.9 : 0.4,
                        ),
                  ),
                );
              }).toList(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bài viết sự kiện nổi bật',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (latestBlogs.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to all blogs
                      },
                      child: Text(
                        'Xem tất cả',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isLoading)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (latestBlogs.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Không có bài viết nào',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= latestBlogs.length) return null;
                  final blog = latestBlogs[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: _buildBlogCard(blog, Theme.of(context)),
                  );
                },
                childCount: latestBlogs.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, ThemeData theme) {
    final resources =
        event['resources_data'] is List ? event['resources_data'] : [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => EventDetailScreen(eventId: event['id'])),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: MediaViewer(
                resources: event['resources_data'] as List?,
                height: 149,
                width: double.infinity,
                borderRadius: 16,
                fit: BoxFit.cover,
                aspectRatio: 16 / 9,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] ?? 'Không tiêu đề',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        _getEventTime(event),
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.info, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        _getEventStatus(event),
                        style: TextStyle(
                          fontSize: 13,
                          color: _getEventStatusColor(event),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogCard(BlogApproved blog, ThemeData theme) {
    print('Building Blog Card for blog ID: ${blog.id}');
    String? imageUrl;
    if (blog.photo.isNotEmpty) {
      imageUrl = fixImageUrl(blog.photo);
    }

    final content = blog.content;
    final String safeContent;
    if (content.isNotEmpty) {
      safeContent = content.replaceAll(RegExp(r'<[^>]*>'), '');
    } else {
      safeContent = '';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlogDetailScreen(
                blog: blog,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          print('Error loading blog image: $error');
                          print('Failed URL: $url');
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.article_outlined,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog.title.isNotEmpty ? blog.title : 'Không tiêu đề',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      safeContent.isNotEmpty ? safeContent : 'Không nội dung',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(blog.createdAt.toIso8601String()),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEventTime(Map<String, dynamic> event) {
    final start = event['timestart'];
    final end = event['timeend'];
    if (start != null && end != null) {
      return '${_formatDate(start)} - ${_formatDate(end)}';
    }
    return 'Chưa cập nhật';
  }

  String _getEventStatus(Map<String, dynamic> event) {
    final now = DateTime.now();
    final start = event['timestart'] != null
        ? DateTime.tryParse(event['timestart'])
        : null;
    final end =
        event['timeend'] != null ? DateTime.tryParse(event['timeend']) : null;
    if (start == null || end == null) return 'Không xác định';
    if (now.isBefore(start)) return 'Sắp diễn ra';
    if (now.isAfter(end)) return 'Đã kết thúc';
    return 'Đang diễn ra';
  }

  Color _getEventStatusColor(Map<String, dynamic> event) {
    final status = _getEventStatus(event);
    switch (status) {
      case 'Sắp diễn ra':
        return Colors.orange;
      case 'Đang diễn ra':
        return Colors.green;
      case 'Đã kết thúc':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
