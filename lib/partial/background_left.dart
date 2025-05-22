import 'package:flutter/material.dart';
import 'package:event_app/partial/verticlecurve.dart';

class BackgroundLeft extends StatefulWidget {
  const BackgroundLeft({
    Key? key,
    required this.size,
    required this.gradientStart,
    required this.gradientEnd,
  }) : super(key: key);

  final Size size;
  final Color gradientStart;
  final Color gradientEnd;

  @override
  _BackgroundLeftState createState() => _BackgroundLeftState();
}

class _BackgroundLeftState extends State<BackgroundLeft>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  int _currentIndex = 0;
  DateTime? _lastPausedTime;
  final List<String> _backgroundImages = [
     "assets/backgroud.jpg",
    "assets/amnhac2.jpg",
    "assets/amnhac3.jpg",
    "assets/amnhac4.jpg",
    "assets/amnhac5.jpg",
    "assets/amnhac7.jpg",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _startImageRotation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lastPausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_lastPausedTime != null) {
        final elapsedSeconds = DateTime.now().difference(_lastPausedTime!).inSeconds;
        int skippedImages = elapsedSeconds ~/ 5;
        setState(() {
          _currentIndex = (_currentIndex + skippedImages) % _backgroundImages.length;
        });
      }
      _startImageRotation();
    }
  }

  void _startImageRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _backgroundImages.length;
        });
        _startImageRotation();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      child: IgnorePointer(
        child: TickerMode(
          enabled: true,
          child: Stack(
            children: [
              // Background Image with rotation
              AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: Container(
                  key: ValueKey<String>(_backgroundImages[_currentIndex]),
                  width: widget.size.width,
                  height: widget.size.height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_backgroundImages[_currentIndex]),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
              ),
              // Gradient Overlay
              Container(
                width: widget.size.width,
                height: widget.size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.gradientStart.withOpacity(0.6),
                      widget.gradientEnd.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}