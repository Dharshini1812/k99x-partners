import 'package:dealer/core/route/router.gr.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:dealer/features/onboarding/data/model/onb_model.dart';
import 'package:dealer/features/onboarding/data/onb_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DealerOnboardingPage extends ConsumerStatefulWidget {
  const DealerOnboardingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DealerOnboardingPageState();
}

class _DealerOnboardingPageState extends ConsumerState<DealerOnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _visitedDotColor = Color(0xFF4A55F0);
  static const _upcomingDotColor = Color(0xFFE2E4EA);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _skip() {
    ref.read(routeService).pushAndRemoveUntil(const LoginRoute(), context);
  }

  void _next() {
    final isLast = _currentPage == kDealerOnboardingPages.length - 1;
    if (isLast) {
      ref.read(routeService).pushAndRemoveUntil(const LoginRoute(), context);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = kDealerOnboardingPages[_currentPage];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _skip,
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Pages ────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: kDealerOnboardingPages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  return _OnboardingPageView(
                    data: kDealerOnboardingPages[index],
                  );
                },
              ),
            ),

            // ── Dot indicator ────────────────────────────────────
            _PageIndicator(
              current: _currentPage,
              count: kDealerOnboardingPages.length,
              activeColor: current.themeColor,
              visitedColor: _visitedDotColor,
              upcomingColor: _upcomingDotColor,
            ),

            const SizedBox(height: 20),

            // ── Next button ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: current.themeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
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

// ─────────────────────────────────────────────────────────────────────────────
// SINGLE PAGE — image with badge, step label, headline, description
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingPageView extends StatelessWidget {
  final OnboardingPageData data;

  const _OnboardingPageView({required this.data});

  @override
  Widget build(BuildContext context) {
    final imageHeight = MediaQuery.of(context).size.height * 0.34;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero image + numbered badge ─────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  data.imagePath,
                  width: double.infinity,
                  height: imageHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: imageHeight,
                    color: const Color(0xFFF1F2F6),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      size: 48,
                      color: Color(0xFFC7CAD1),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF11142A).withOpacity(0.82),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data.badge,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Step label ───────────────────────────────────────────
          Text(
            data.step,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: data.themeColor,
            ),
          ),

          const SizedBox(height: 10),

          // ── Headline ─────────────────────────────────────────────
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.15,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 14),

          // ── Description ──────────────────────────────────────────
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE INDICATOR — visited pages: small solid dot. Current page: elongated
// light pill. Upcoming pages: small light grey dot.
// ─────────────────────────────────────────────────────────────────────────────

class _PageIndicator extends StatelessWidget {
  final int current;
  final int count;
  final Color activeColor;
  final Color visitedColor;
  final Color upcomingColor;

  const _PageIndicator({
    required this.current,
    required this.count,
    required this.activeColor,
    required this.visitedColor,
    required this.upcomingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        final isVisited = i < current;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withOpacity(0.35)
                : (isVisited ? visitedColor : upcomingColor),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
