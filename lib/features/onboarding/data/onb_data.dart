import 'dart:ui';

import 'package:dealer/features/onboarding/data/model/onb_model.dart';

const List<OnboardingPageData> kDealerOnboardingPages = [
  OnboardingPageData(
    imagePath: 'images/onboarding/img1.jpg',
    badge: '01',
    step: 'STEP ONE',
    title: 'Upload your car stock',
    description:
        'Snap two photos, add the videos and condition — your vehicle is live on the floor in minutes.',
    themeColor: Color(0xFF4A55F0),
  ),
  OnboardingPageData(
    imagePath: 'images/onboarding/img2.jpg',
    badge: '02',
    step: 'STEP TWO',
    title: 'Compare against similar stock',
    description:
        'See how your listing stacks up on price, km and condition against similar vehicles nearby.',
    themeColor: Color(0xFFF0964B),
  ),
  OnboardingPageData(
    imagePath: 'images/onboarding/img3.jpg',
    badge: '03',
    step: 'STEP THREE',
    title: 'Sell it faster',
    description:
        'Get matched with ready buyers and close the deal before the listing goes cold.',
    themeColor: Color(0xFF3EBD82),
  ),
];
