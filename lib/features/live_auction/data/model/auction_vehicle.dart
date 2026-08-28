enum ListingType { auction, oneClickBuy }

class InspectionDefect {
  final String title;
  final String? subtitle;
  final bool isPassed;
  final String? imageUrl;
  final bool hasVideo;

  const InspectionDefect({
    required this.title,
    this.subtitle,
    this.isPassed = false,
    this.imageUrl,
    this.hasVideo = false,
  });
}

class VehicleModel {
  final String id;
  final String title;
  final String location;
  final String rtoCode;
  final String specs;
  final double exteriorRating;
  final double engineRating;
  final double acRating;
  final double electricalsRating;
  final double steeringRating;
  final String fairValue;
  final String currentPriceOrBid;
  final String bidIncrementPrice;
  final String timeRemaining;
  final String mainImage;
  final List<String> gallery;
  final ListingType listingType;
  final String? transitCost;
  final Map<String, String> documents;
  final Map<String, String> otherInfo;
  final Map<String, String> registrationInfo;
  final List<InspectionDefect> structureChecks;
  final List<InspectionDefect> otherComponentsChecks;
  final List<InspectionDefect> windshieldChecks;
  final List<InspectionDefect> engineChecks;
  final List<InspectionDefect> exteriorPanelsChecks;
  final List<InspectionDefect> tyresChecks;
  final List<InspectionDefect> electricalsChecks;
  final List<InspectionDefect> steeringChecks;

  const VehicleModel({
    required this.id,
    required this.title,
    required this.location,
    required this.rtoCode,
    required this.specs,
    required this.exteriorRating,
    required this.engineRating,
    this.acRating = 5.0,
    this.electricalsRating = 5.0,
    this.steeringRating = 4.5,
    required this.fairValue,
    required this.currentPriceOrBid,
    required this.bidIncrementPrice,
    required this.timeRemaining,
    required this.mainImage,
    required this.gallery,
    required this.listingType,
    this.transitCost,
    required this.documents,
    required this.otherInfo,
    required this.registrationInfo,
    required this.structureChecks,
    required this.otherComponentsChecks,
    required this.windshieldChecks,
    required this.engineChecks,
    required this.exteriorPanelsChecks,
    required this.tyresChecks,
    required this.electricalsChecks,
    required this.steeringChecks,
  });
}

// -------------------------------------------------------------
// MOCK DATA MATCHING YOUR SCREENSHOTS
// -------------------------------------------------------------
final List<VehicleModel> mockVehicleFeed = [
  // 1. Red Swift (Auction)
  const VehicleModel(
    id: "6050027",
    title: "2021 Maruti Suzuki Swift VXi AMT",
    location: "CHENNAI",
    rtoCode: "TN09",
    specs: "Petrol • Automatic • 89.7k km • 2nd Owner",
    exteriorRating: 4.0,
    engineRating: 5.0,
    acRating: 5.0,
    electricalsRating: 5.0,
    steeringRating: 4.5,
    fairValue: "₹5,27,000",
    currentPriceOrBid: "₹3,80,000",
    bidIncrementPrice: "₹3,85,000",
    timeRemaining: "00:48:30",
    mainImage:
        "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800",
    gallery: [
      "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=400",
      "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400",
      "https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400",
      "https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=400",
      "https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=400",
    ],
    listingType: ListingType.auction,
    documents: {
      "RC availability": "Yes",
      "Insurance": "Expired",
      "Road tax paid": "Valid till 2036",
    },
    otherInfo: {
      "Duplicate key": "Yes",
      "Chassis number": "Yes",
      "Engine number": "Yes",
      "Party-peshi": "No",
      "Pollution Norm": "Euro 6 (Bharat Stage VI)",
    },
    registrationInfo: {
      "Manufacturing date": "2021",
      "Registration date": "2021",
      "RTO code": "TN09",
      "RTO name": "Chennai (west) Rto",
      "Fitness report": "Valid till 2036",
    },
    structureChecks: [
      InspectionDefect(
        title: "Apron, Dickey, Pillar, Cowl top, Right quarter panel",
        isPassed: true,
      ),
      InspectionDefect(
        title: "Left quarter panel",
        subtitle: "Scratch, Repainted",
        imageUrl:
            "https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=150",
      ),
      InspectionDefect(
        title: "Front left leg",
        subtitle: "Surface level rust",
        imageUrl:
            "https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=150",
      ),
    ],
    otherComponentsChecks: [
      InspectionDefect(
        title:
            "Fire wall, Lower member, Right running board, Headlight supports, Upper member (bonnet patti)",
        isPassed: true,
      ),
      InspectionDefect(
        title: "Dickey",
        subtitle: "Toolkit not available",
        imageUrl:
            "https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=150",
      ),
      InspectionDefect(
        title: "Left running board",
        subtitle: "Dent",
        imageUrl:
            "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=150",
      ),
    ],
    windshieldChecks: [
      InspectionDefect(
        title: "Svms, Headlights, Tail lights, Windshield",
        isPassed: true,
      ),
      InspectionDefect(
        title: "Left tail light",
        subtitle: "Crack",
        imageUrl:
            "https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=150",
      ),
    ],
    engineChecks: [
      InspectionDefect(
        title: "Clutch, Engine, Exhaust smoke, Engine mounting",
        isPassed: true,
      ),
      InspectionDefect(
        title: "Engine sound",
        isPassed: true,
      ),
    ],
    exteriorPanelsChecks: [
      InspectionDefect(
        title: "Roof, Bonnet, Dickey door, Right fender",
        isPassed: true,
      ),
      InspectionDefect(
        title: "Rear bumper",
        subtitle: "Scratch",
        imageUrl:
            "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=150",
      ),
      InspectionDefect(
        title: "Front bumper",
        subtitle: "Scratch, Repainted",
        imageUrl:
            "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=150",
      ),
      InspectionDefect(
        title: "Left fender",
        subtitle: "Repainted",
        imageUrl:
            "https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=150",
      ),
      InspectionDefect(
        title: "Rear left door",
        subtitle: "Dent, Scratch",
        imageUrl:
            "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=150",
      ),
      InspectionDefect(
        title: "Rear right door",
        subtitle: "Scratch",
        imageUrl:
            "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=150",
      ),
    ],
    tyresChecks: [
      InspectionDefect(
        title: "Front left tyre",
        subtitle: "35% integrity",
        imageUrl:
            "https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=150",
      ),
      InspectionDefect(
        title: "Front right tyre",
        subtitle: "40% integrity",
        imageUrl:
            "https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=150",
      ),
    ],
    electricalsChecks: [
      InspectionDefect(
        title: "Airbag, Car key, Steering mounted controls",
        isPassed: true,
      ),
      InspectionDefect(
        title: "Interiors",
        subtitle: "Gear knob-damaged",
        imageUrl:
            "https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=150",
      ),
    ],
    steeringChecks: [
      InspectionDefect(
        title: "ABS, Brakes",
        isPassed: true,
      ),
      InspectionDefect(
        title: "Steering",
        subtitle: "Abnormal noise",
        imageUrl:
            "https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=150",
        hasVideo: true,
      ),
      InspectionDefect(
        title: "Suspension",
        subtitle: "Abnormal noise",
      ),
    ],
  ),

  // 2. Dark Grey Alto (One Click Buy)
  const VehicleModel(
    id: "6041331",
    title: "2016 Alto K10 VXi",
    location: "CHENNAI",
    rtoCode: "TN14",
    specs: "Petrol • Manual • 72.1K km • 2nd owner",
    exteriorRating: 3.5,
    engineRating: 4.0,
    acRating: 4.5,
    electricalsRating: 4.0,
    steeringRating: 4.0,
    fairValue: "₹2,75,000",
    currentPriceOrBid: "₹2,43,000",
    bidIncrementPrice: "₹2,29,000",
    timeRemaining: "00:02:43",
    mainImage:
        "https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800",
    gallery: [
      "https://images.unsplash.com/photo-1590362891991-f776e747a588?w=400",
      "https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=400",
    ],
    listingType: ListingType.oneClickBuy,
    documents: {
      "RC availability": "Yes",
      "Insurance": "Valid till Dec 2026",
      "Road tax paid": "Valid till 2031",
    },
    otherInfo: {
      "Duplicate key": "No",
      "Chassis number": "Yes",
      "Engine number": "Yes",
      "Party-peshi": "No",
      "Pollution Norm": "Euro 4 (Bharat Stage IV)",
    },
    registrationInfo: {
      "Manufacturing date": "2016",
      "Registration date": "2016",
      "RTO code": "TN14",
      "RTO name": "Chennai (south) Rto",
      "Fitness report": "Valid till 2031",
    },
    structureChecks: [
      InspectionDefect(title: "Apron, Dickey, Pillar", isPassed: true),
    ],
    otherComponentsChecks: [
      InspectionDefect(title: "Fire wall, Lower member", isPassed: true),
    ],
    windshieldChecks: [
      InspectionDefect(title: "Headlights, Windshield", isPassed: true),
    ],
    engineChecks: [
      InspectionDefect(title: "Clutch, Engine Sound", isPassed: true),
    ],
    exteriorPanelsChecks: [
      InspectionDefect(title: "Roof, Bonnet", isPassed: true),
      InspectionDefect(title: "Front bumper", subtitle: "Minor scratch"),
    ],
    tyresChecks: [
      InspectionDefect(title: "Front left tyre", subtitle: "60% integrity"),
      InspectionDefect(title: "Front right tyre", subtitle: "60% integrity"),
    ],
    electricalsChecks: [
      InspectionDefect(title: "AC, Blower, Lights", isPassed: true),
    ],
    steeringChecks: [
      InspectionDefect(title: "Steering, Brakes", isPassed: true),
    ],
  ),

  // 3. White Swift VDi (One Click Buy with Transit fee)
  const VehicleModel(
    id: "6042138",
    title: "2015 Swift VDi",
    location: "BANGALORE",
    rtoCode: "TN06",
    specs: "Diesel • Manual • 88.8K km • 1st owner",
    exteriorRating: 4.0,
    engineRating: 5.0,
    acRating: 5.0,
    electricalsRating: 5.0,
    steeringRating: 4.5,
    fairValue: "₹4,80,000",
    currentPriceOrBid: "₹4,37,000",
    bidIncrementPrice: "₹4,20,000",
    timeRemaining: "01:06:01",
    transitCost: "₹5,720",
    mainImage:
        "https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800",
    gallery: [
      "https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=400",
      "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=400",
    ],
    listingType: ListingType.oneClickBuy,
    documents: {
      "RC availability": "Yes",
      "Insurance": "Expired",
      "Road tax paid": "Valid till 2030",
    },
    otherInfo: {
      "Duplicate key": "Yes",
      "Chassis number": "Yes",
      "Engine number": "Yes",
      "Party-peshi": "No",
      "Pollution Norm": "Euro 4 (Bharat Stage IV)",
    },
    registrationInfo: {
      "Manufacturing date": "2015",
      "Registration date": "2015",
      "RTO code": "TN06",
      "RTO name": "Chennai (central) Rto",
      "Fitness report": "Valid till 2030",
    },
    structureChecks: [
      InspectionDefect(
          title: "Apron, Dickey, Pillar, Running board", isPassed: true),
    ],
    otherComponentsChecks: [
      InspectionDefect(
          title: "Headlight supports, Upper member", isPassed: true),
    ],
    windshieldChecks: [
      InspectionDefect(title: "Svms, Headlights, Tail lights", isPassed: true),
    ],
    engineChecks: [
      InspectionDefect(title: "Clutch, Engine, Exhaust smoke", isPassed: true),
    ],
    exteriorPanelsChecks: [
      InspectionDefect(title: "Roof, Bonnet, Dickey door", isPassed: true),
    ],
    tyresChecks: [
      InspectionDefect(title: "All Tyres", subtitle: "50% integrity"),
    ],
    electricalsChecks: [
      InspectionDefect(title: "Airbag, Steering controls", isPassed: true),
    ],
    steeringChecks: [
      InspectionDefect(title: "ABS, Brakes", isPassed: true),
    ],
  ),
];
