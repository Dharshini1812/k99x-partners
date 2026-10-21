// lib/features/live_auction/data/model/vehicle_item_mapper.dart

import 'dart:developer';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/data/model/new_auction_detail_model.dart';

extension VehicleItemMapper on VehicleItem {
  LiveAuctionModel toLiveAuctionModel() {
    final v = vehicle;
    final a = auction;
    final l = lender;
    final imgs = vehicleImages;

    final Set<String> collected = {};
    final double? resolvedUserBid = (dealerMaxBid != null && dealerMaxBid! > 0)
        ? dealerMaxBid
        : ((userHighestPrice != null && userHighestPrice! > 0)
            ? userHighestPrice
            : null);

    void addUrl(dynamic imgSource) {
      if (imgSource == null) return;
      if (imgSource is VehicleImageModelF) {
        final u = imgSource.url?.trim();
        if (u != null && u.isNotEmpty) collected.add(u);
      } else if (imgSource is String) {
        final u = imgSource.trim();
        if (u.isNotEmpty) collected.add(u);
      } else if (imgSource is Map<String, dynamic>) {
        final u = imgSource['url']?.toString().trim();
        if (u != null && u.isNotEmpty) collected.add(u);
      }
    }

    // 1. Exterior
    addUrl(imgs?.frontView);
    addUrl(imgs?.frontLeftView);
    addUrl(imgs?.rearView);
    addUrl(imgs?.rearRightView);

    // 2. Interior
    addUrl(imgs?.interiorFrontView);
    addUrl(imgs?.interiorBackView);
    addUrl(imgs?.odometerView);

    // 3. Engine & Chassis
    addUrl(imgs?.engineView);
    addUrl(imgs?.chassisView);
    addUrl(imgs?.chassisImprintView);

    // 4. Tyres
    addUrl(imgs?.leftFrontTyre);
    addUrl(imgs?.rightFrontTyre);
    addUrl(imgs?.leftRearTyre);
    addUrl(imgs?.rightRearTyre);

    // 5. Other images
    addUrl(imgs?.otherImage1);
    addUrl(imgs?.otherImage2);
    addUrl(imgs?.otherImage3);
    addUrl(imgs?.otherImage4);
    addUrl(imgs?.otherImage5);

    // 6. Direct fallback fields on VehicleItem
    addUrl(frontImage);
    addUrl(backImage);
    addUrl(interiorImage);
    addUrl(engineImage);

    // 7. allImageUrls fallback if present
    if (imgs?.allImageUrls != null) {
      for (final u in imgs!.allImageUrls) {
        addUrl(u);
      }
    }

    final List<String> finalUrls = collected.toList();
    log('Vehicle [${v?.regno ?? a?.regno}] Total Images Collected: ${finalUrls.length}');

    // Primary thumbnail image
    VehicleImageModelF? primaryImage;
    if (imgs?.frontView != null &&
        (imgs!.frontView!.url?.trim().isNotEmpty ?? false)) {
      primaryImage = imgs.frontView;
    } else if (frontImage != null && frontImage!.trim().isNotEmpty) {
      primaryImage = VehicleImageModelF(url: frontImage!.trim());
    } else if (finalUrls.isNotEmpty) {
      primaryImage = VehicleImageModelF(url: finalUrls.first);
    }

    return LiveAuctionModel(
      vehicleId: v?.vehicleId ?? a?.vehicleId,
      loanNo: v?.loanNo ?? a?.loanNo,
      lotNo: v?.lotNo ?? '1',
      mfgYear: v?.mfgYear,
      make: v?.make,
      model: v?.model,
      variant: v?.variant,
      regno: v?.regno ?? a?.regno,
      fuel: v?.fuel,
      kmsDriven: v?.kmsDriven,
      ownerCount: v?.ownerCount,
      basePrice: v?.basePrice,
      startingprice: v?.startingPrice,
      status: status ?? v?.status,
      auctionStartDt: a?.startTime != null
          ? DateTime.fromMillisecondsSinceEpoch(a!.startTime!).toIso8601String()
          : null,
      auctionCloseDt: a?.effectiveEnd != null
          ? a!.effectiveEnd!.toIso8601String()
          : (a?.endTime != null
              ? DateTime.fromMillisecondsSinceEpoch(a!.endTime!)
                  .toIso8601String()
              : null),
      extendedEndTime: a?.extendedEndTime != null
          ? DateTime.fromMillisecondsSinceEpoch(a!.extendedEndTime!)
              .toIso8601String()
          : null,
      lenderId: l?.sno ?? v?.lenderId,
      lenderName: l?.lenderName,
      categoryName: category ?? v?.category,
      stateName: state?.stateName ?? v?.state,
      cityName: city?.cityName ?? v?.city,
      mode: int.tryParse(a?.mode ?? v?.mode ?? ''),
      imageUrl: primaryImage,
      imageUrls: finalUrls,
      bids: [
        if (resolvedUserBid != null)
          BidsModel(
            amount: resolvedUserBid,
            vehicleId: v?.vehicleId,
          ),
      ],
    );
  }
}
