import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../utils/url_utils.dart';

class MediaViewer extends StatefulWidget {
  final List<dynamic>? resources;
  final double height;
  final double width;
  final double borderRadius;
  final BoxFit fit;
  final double? aspectRatio;

  const MediaViewer({
    Key? key,
    required this.resources,
    this.height = 140,
    this.width = double.infinity,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
    this.aspectRatio,
  }) : super(key: key);

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  int _retryCount = 0;
  static const int maxRetries = 3;

  @override
  void dispose() {
    _videoController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resources = widget.resources;
    if (resources == null || resources.isEmpty) {
      return _buildNoMedia();
    }

    // 1. Ảnh
    final image = resources.firstWhere(
      (e) => e['type']?.toString().startsWith('image/') ?? false,
      orElse: () => <String, dynamic>{},
    );
    if (image != null && image['url'] != null) {
      final imageUrl = fixImageUrl(image['url']);
      return _buildImage(imageUrl);
    }

    // 2. Video mp4
    final video = resources.firstWhere(
      (e) => e['type']?.toString().startsWith('video/') ?? false,
      orElse: () => <String, dynamic>{},
    );
    if (video != null && video['url'] != null) {
      final videoUrl = fixImageUrl(video['url']);
      if (_videoController == null ||
          _videoController!.dataSource != videoUrl) {
        _videoController?.dispose();
        _videoController = VideoPlayerController.network(videoUrl)
          ..initialize().then((_) {
            setState(() {});
          }).catchError((error) {
            print('Error initializing video: $error');
            setState(() {});
          });
      }
      if (_videoController!.value.isInitialized) {
        return _buildVideo(_videoController!);
      } else {
        return _buildLoading();
      }
    }

    // 3. YouTube
    final youtube = resources.firstWhere(
      (e) => e['type'] == 'youtube' && e['url'] != null,
      orElse: () => <String, dynamic>{},
    );
    if (youtube != null && youtube['url'] != null) {
      final videoId = YoutubePlayer.convertUrlToId(youtube['url']);
      if (videoId != null) {
        if (_youtubeController == null ||
            _youtubeController!.initialVideoId != videoId) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(autoPlay: false),
          );
        }
        return _buildYoutube(_youtubeController!);
      }
    }

    return _buildNoMedia();
  }

  Widget _buildImage(String imageUrl) => ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
          placeholder: (context, url) => _buildLoading(),
          errorWidget: (context, url, error) {
            print('Error loading image: $error');
            print('Failed URL: $url');
            if (_retryCount < maxRetries) {
              _retryCount++;
              return _buildImage(imageUrl);
            }
            return _buildNoMedia();
          },
          memCacheWidth: 800,
          memCacheHeight: 800,
          maxWidthDiskCache: 800,
          maxHeightDiskCache: 800,
        ),
      );

  Widget _buildVideo(VideoPlayerController controller) => ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: AspectRatio(
          aspectRatio: widget.aspectRatio ?? controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );

  Widget _buildYoutube(YoutubePlayerController controller) => ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: YoutubePlayer(
          controller: controller,
          showVideoProgressIndicator: true,
          width: widget.width,
          aspectRatio: widget.aspectRatio ?? 16 / 9,
        ),
      );

  Widget _buildNoMedia() => Container(
        height: widget.height,
        width: widget.width,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, size: 50),
      );

  Widget _buildLoading() => Container(
        height: widget.height,
        width: widget.width,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );
}
