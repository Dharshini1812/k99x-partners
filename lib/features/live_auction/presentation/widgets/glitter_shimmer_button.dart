// lib/features/live_auction/presentation/widgets/glitter_shimmer_button.dart

import 'package:flutter/material.dart';

class GlitterShimmerButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final List<Color> gradientColors;
  final Duration sweepDuration;

  const GlitterShimmerButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.gradientColors = const [
      Color(0xFF4F46E5), // Electric Indigo
      Color(0xFF7C3AED), // Vivid Purple
      Color(0xFFDB2777), // Shimmer Pink
    ],
    this.sweepDuration = const Duration(milliseconds: 1600),
  });

  @override
  State<GlitterShimmerButton> createState() => _GlitterShimmerButtonState();
}

class _GlitterShimmerButtonState extends State<GlitterShimmerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _shimmerFinished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.sweepDuration,
    );

    // Run the animation strictly once after the first frame mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward().then((_) {
          if (mounted) {
            setState(() {
              _shimmerFinished = true;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: widget.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.gradientColors.first.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Glass glitter sweep line (Runs once, then gets removed)
            if (!_shimmerFinished)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Positioned.fill(
                    child: FractionallySizedBox(
                      widthFactor: 0.35,
                      alignment: Alignment(-2.0 + (4.0 * _controller.value), 0),
                      child: Transform.rotate(
                        angle: 0.35, // Diagonal sweep
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.18),
                                Colors.white.withOpacity(0.85), // Peak sparkle
                                Colors.white.withOpacity(0.18),
                                Colors.white.withOpacity(0.0),
                              ],
                              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Button Ink & Text
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                splashColor: Colors.white24,
                highlightColor: Colors.white10,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        widget.text,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.6,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
