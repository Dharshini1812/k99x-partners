// lib/features/my_listings/presentation/pages/vehicle_media_gallery_page.dart

import 'package:chewie/chewie.dart';
import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

/// One playable/viewable item pulled out of a DealerVehicleInspection
/// — photos and videos are both represented here so the gallery can
/// build its list generically instead of hand-writing each field.
class _MediaItem {
  final String label;
  final String url;
  final bool isVideo;
  const _MediaItem(
      {required this.label, required this.url, required this.isVideo});
}

class VehicleMediaGalleryPage extends StatelessWidget {
  final DealerVehicleInspection? inspection;
  final String vehicleTitle;

  const VehicleMediaGalleryPage({
    super.key,
    required this.inspection,
    this.vehicleTitle = 'Vehicle Media',
  });

  List<_MediaItem> _collectItems() {
    final insp = inspection;
    if (insp == null) return const [];

    final items = <_MediaItem>[];

    void addIfPresent(MediaFile? file, String label, {required bool video}) {
      final url = file?.url;
      if (url != null && url.trim().isNotEmpty) {
        items.add(_MediaItem(label: label, url: url, isVideo: video));
      }
    }

    // Photos first.
    addIfPresent(insp.frontVehicleImageUrl, 'Front View', video: false);
    addIfPresent(insp.odometerImageUrl, 'Odometer', video: false);

    // Then videos. mergedVideoUrl can come back as {"status": "ERROR"}
    // instead of a real media object — addIfPresent already skips it
    // safely since its `.url` will be null in that case.
    addIfPresent(insp.exteriorVideoUrl, 'Exterior', video: true);
    addIfPresent(insp.interiorVideoUrl, 'Interior', video: true);
    addIfPresent(insp.engineBayVideoUrl, 'Engine Bay', video: true);
    addIfPresent(insp.tyreVideoUrl, 'Tyres', video: true);
    addIfPresent(insp.mergedVideoUrl, 'Full Walkaround', video: true);

    return items;
  }

  Future<void> _openYoutube(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the YouTube link')),
      );
    }
  }

  void _openPhoto(BuildContext context, List<_MediaItem> photos, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PhotoViewerPage(photos: photos, initialIndex: index),
      ),
    );
  }

  void _openVideo(BuildContext context, _MediaItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _VideoPlayerPage(title: item.label, url: item.url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _collectItems();
    final photos = items.where((i) => !i.isVideo).toList();
    final videos = items.where((i) => i.isVideo).toList();
    final youtubeUrl = inspection?.youtubeVideoUrl?.youtubeUrl;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(vehicleTitle, style: const TextStyle(fontSize: 15)),
      ),
      body: (items.isEmpty && youtubeUrl == null)
          ? const Center(
              child: Text(
                'No photos or videos available for this vehicle',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (photos.isNotEmpty) ...[
                  const _SectionLabel('Photos'),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: photos.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (_, i) {
                      final p = photos[i];
                      return GestureDetector(
                        onTap: () => _openPhoto(context, photos, i),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                p.url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF1C1C1E),
                                  child: const Icon(Icons.broken_image_rounded,
                                      color: Colors.white38),
                                ),
                              ),
                              Positioned(
                                left: 6,
                                bottom: 6,
                                child: _CaptionChip(text: p.label),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                if (videos.isNotEmpty) ...[
                  const _SectionLabel('Videos'),
                  const SizedBox(height: 10),
                  ...videos.map(
                    (v) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => _openVideo(context, v),
                        child: Container(
                          height: 64,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF3F51E8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_arrow_rounded,
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  v.label,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: Colors.white38),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (youtubeUrl != null && youtubeUrl.trim().isNotEmpty) ...[
                  const _SectionLabel('YouTube'),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _openYoutube(context, youtubeUrl),
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF0000),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.smart_display_rounded,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Watch on YouTube',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                          ),
                          const Icon(Icons.open_in_new_rounded,
                              color: Colors.white38, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _CaptionChip extends StatelessWidget {
  final String text;
  const _CaptionChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Full-screen photo viewer (swipe between photos, pinch to zoom) ──

class _PhotoViewerPage extends StatefulWidget {
  final List<_MediaItem> photos;
  final int initialIndex;

  const _PhotoViewerPage({required this.photos, required this.initialIndex});

  @override
  State<_PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<_PhotoViewerPage> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${widget.photos[_index].label} (${_index + 1}/${widget.photos.length})',
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.photos.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, i) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: Image.network(
                widget.photos[i].url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white38,
                    size: 48),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Full-screen video player ─────────────────────────────────────────

class _VideoPlayerPage extends StatefulWidget {
  final String title;
  final String url;

  const _VideoPlayerPage({required this.title, required this.url});

  @override
  State<_VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<_VideoPlayerPage> {
  late final VideoPlayerController _videoController;
  ChewieController? _chewieController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _videoController.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFF3F51E8),
            handleColor: const Color(0xFF3F51E8),
            bufferedColor: Colors.white24,
            backgroundColor: Colors.white10,
          ),
        );
      });
    }).catchError((e) {
      if (!mounted) return;
      setState(() => _error = 'Could not load this video');
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(fontSize: 15)),
      ),
      body: Center(
        child: _error != null
            ? Text(_error!, style: const TextStyle(color: Colors.white70))
            : (_chewieController == null
                ? const CircularProgressIndicator(color: Colors.white)
                : AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio == 0
                        ? 16 / 9
                        : _videoController.value.aspectRatio,
                    child: Chewie(controller: _chewieController!),
                  )),
      ),
    );
  }
}
