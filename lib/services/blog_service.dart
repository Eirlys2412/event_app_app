import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/blog_approved.dart';

class BlogService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // This is a mock function that returns fake blog data
  // In a real app, you would connect to an actual API
  Future<List<BlogApproved>> fetchBlogs() async {
    // In a real app, this would be an actual API call:
    // final response = await http.get(Uri.parse('$baseUrl/blogs'));

    // For now, we'll simulate a network delay
    await Future.delayed(Duration(seconds: 1));

    // And return mock data
    return List.generate(
      10,
      (index) => BlogApproved(
        id: index,
        title: 'Blog Post ${index + 1}',
        content:
            'This is the content for blog post ${index + 1}. It contains detailed information about the topic.',
        summary: 'This is a summary of blog post ${index + 1}',
        photo: 'https://picsum.photos/seed/blog-$index/800/400',
        catId: index % 3,
        createdAt: DateTime.now().subtract(Duration(days: index)),
        updatedAt:
            DateTime.now().subtract(Duration(days: index, hours: (index % 24))),
        userId: 'user-${index % 5}',
        authorName: 'User ${index % 5}',
        authorPhoto: 'https://i.pravatar.cc/150?img=${index % 10}',
        authorId: 'user-${index % 5}',
        countBookmarked: index * 3,
        countLike: index * 10,
        countComment: index * 5,
        tags: ['Flutter', 'Mobile', 'Development', 'Tutorial']
            .sublist(0, (index % 4) + 1),
        slug: 'blog-post-${index + 1}',
        is_liked: index % 2 == 0,
        likes_count: index * 5 + 1,
    
      ),
    );
  }

  Future<BlogApproved> fetchBlogById(String id) async {
    // In a real app, you would make an API call
    // final response = await http.get(Uri.parse('$baseUrl/blogs/$id'));

    await Future.delayed(Duration(seconds: 1));

    // Return a mock blog post
    final index = int.tryParse(id.split('-').last) ?? 0;

    return BlogApproved(
      id: index,
      title: 'Blog Post $index',
      content:
          'This is the content for blog post $index. It contains detailed information about the topic.',
      summary: 'This is a summary of blog post $index',
      photo: 'https://picsum.photos/seed/$id/800/400',
      catId: index % 3,
      createdAt: DateTime.now().subtract(Duration(days: index)),
      updatedAt:
          DateTime.now().subtract(Duration(days: index, hours: (index % 24))),
      userId: 'user-${index % 5}',
      authorName: 'User ${index % 5}',
      authorPhoto: 'https://i.pravatar.cc/150?img=${index % 10}',
      authorId: 'user-${index % 5}',
      countBookmarked: index * 3,
      countLike: index * 10,
      countComment: index * 5,

      tags: ['Flutter', 'Mobile', 'Development', 'Tutorial']
          .sublist(0, (index % 4) + 1),
      slug: 'blog-post-$index',
      is_liked: index % 2 == 0,
      likes_count: index * 5 + 1,
    );
  }
}
