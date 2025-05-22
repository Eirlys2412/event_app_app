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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> allEvents = [];
  List<Map<String, dynamic>> filteredEvents = [];
  List<Map<String, dynamic>> blogs = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _currentEventIndex = 0;

  @override
  void initState() {
    super.initState();
    loadData();
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
    try {
      setState(() => isLoading = true);

      // Load events
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

          // Fix URL cho tất cả resource của event
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
        } else {
          print('Error loading events: ${eventResponse.statusCode}');
          print('Error response: ${eventResponse.body}');
          setState(() {
            allEvents = [];
            filteredEvents = [];
          });
        }
      } catch (e) {
        print('Error loading events: $e');
        setState(() {
          allEvents = [];
          filteredEvents = [];
        });
      }

      // Load blogs
      try {
        final headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };

        final blogResponse = await http.get(
          Uri.parse(api_getblog),
          headers: headers,
        );

        print('Blog Response Status: ${blogResponse.statusCode}');
        print('Blog Response Body: ${blogResponse.body}');

        if (blogResponse.statusCode == 200) {
          final blogData =
              jsonDecode(blogResponse.body)['blogs']['data'] as List;
          final sortedBlogs = List<Map<String, dynamic>>.from(
            blogData.map((item) => Map<String, dynamic>.from(item as Map)),
          )..sort((a, b) {
              final dateA = DateTime.parse(a['created_at'] ?? '');
              final dateB = DateTime.parse(b['created_at'] ?? '');
              return dateB.compareTo(dateA);
            });

          setState(() {
            blogs = sortedBlogs.take(5).toList();
          });
        } else {
          print('Error loading blogs: ${blogResponse.statusCode}');
          print('Error response: ${blogResponse.body}');
          setState(() {
            blogs = [];
          });
        }
      } catch (e) {
        print('Error loading blogs: $e');
        setState(() {
          blogs = [];
        });
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
    final themeState = ref.watch(themeProvider);

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Sự kiện gần đây',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  CarouselSlider.builder(
                    itemCount:
                        filteredEvents.isNotEmpty ? filteredEvents.length : 1,
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
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
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
                  const SizedBox(height: 8),
                  Row(
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
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bài viết sự kiện nổi bật',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to all blogs
                          },
                          child: Text(
                            'Xem tất cả',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: blogs.length,
                    itemBuilder: (context, index) {
                      return _buildBlogCard(blogs[index], Theme.of(context));
                    },
                  ),
                ],
              ),
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
            MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
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
                height: 140,
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
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event['location'] ?? 'Không rõ địa điểm',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  Widget _buildBlogCard(Map<String, dynamic> blog, ThemeData theme) {
    String? imageUrl;
    if (blog['resources_data'] != null && blog['resources_data'] is List) {
      final image = (blog['resources_data'] as List).firstWhere(
        (e) => e['type']?.toString().startsWith('image/') ?? false,
        orElse: () => <String, dynamic>{},
      );
      if (image != null) {
        print('Original URL: ${image['url']}');
        imageUrl = fixImageUrl(image['url']);
        print('Fixed URL: ${fixImageUrl(image['url'])}');
      }
    } else if (blog['photo'] != null && blog['photo'].toString().isNotEmpty) {
      imageUrl = fixImageUrl(blog['photo']);
    }

    final content = blog['content'];
    final String safeContent;
    if (content is String) {
      safeContent = content.replaceAll(RegExp(r'<[^>]*>'), '');
    } else {
      safeContent = '';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () {
          final parsedBlog = BlogApproved.fromJson(blog);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlogDetailScreen(
                blog: parsedBlog,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          print('Error loading blog image: $error');
                          print('Failed URL: $url');
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          );
                        },
                        memCacheWidth: 300,
                        memCacheHeight: 300,
                      )
                    : Container(
                        width: 80,
                        height: 80,
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
                      blog['title'] ?? 'Không tiêu đề',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      safeContent,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
}
