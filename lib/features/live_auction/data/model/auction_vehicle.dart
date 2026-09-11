// enum ListingType { auction, oneClickBuy }

// class InspectionDefect {
//   final String title;
//   final String? subtitle;
//   final bool isPassed;
//   final String? imageUrl;
//   final bool hasVideo;

//   const InspectionDefect({
//     required this.title,
//     this.subtitle,
//     this.isPassed = false,
//     this.imageUrl,
//     this.hasVideo = false,
//   });
// }

// class VehicleModel {
//   final String id;
//   final String title;
//   final String location;
//   final String rtoCode;
//   final String specs;
//   final double exteriorRating;
//   final double engineRating;
//   final double acRating;
//   final double electricalsRating;
//   final double steeringRating;
//   final String fairValue;
//   final String currentPriceOrBid;
//   final String bidIncrementPrice;
//   final String timeRemaining;
//   final String mainImage;
//   final List<String> gallery;
//   final ListingType listingType;
//   final String? transitCost;
//   final Map<String, String> documents;
//   final Map<String, String> otherInfo;
//   final Map<String, String> registrationInfo;
//   final List<InspectionDefect> structureChecks;
//   final List<InspectionDefect> otherComponentsChecks;
//   final List<InspectionDefect> windshieldChecks;
//   final List<InspectionDefect> engineChecks;
//   final List<InspectionDefect> exteriorPanelsChecks;
//   final List<InspectionDefect> tyresChecks;
//   final List<InspectionDefect> electricalsChecks;
//   final List<InspectionDefect> steeringChecks;

//   const VehicleModel({
//     required this.id,
//     required this.title,
//     required this.location,
//     required this.rtoCode,
//     required this.specs,
//     required this.exteriorRating,
//     required this.engineRating,
//     this.acRating = 5.0,
//     this.electricalsRating = 5.0,
//     this.steeringRating = 4.5,
//     required this.fairValue,
//     required this.currentPriceOrBid,
//     required this.bidIncrementPrice,
//     required this.timeRemaining,
//     required this.mainImage,
//     required this.gallery,
//     required this.listingType,
//     this.transitCost,
//     required this.documents,
//     required this.otherInfo,
//     required this.registrationInfo,
//     required this.structureChecks,
//     required this.otherComponentsChecks,
//     required this.windshieldChecks,
//     required this.engineChecks,
//     required this.exteriorPanelsChecks,
//     required this.tyresChecks,
//     required this.electricalsChecks,
//     required this.steeringChecks,
//   });
// }

// final List<VehicleModel> mockVehicleFeed = [
//   const VehicleModel(
//     id: "6050027",
//     title: "2021 Maruti Suzuki Swift VXi AMT",
//     location: "CHENNAI",
//     rtoCode: "TN09",
//     specs: "Petrol • Automatic • 89.7k km • 2nd Owner",
//     exteriorRating: 4.0,
//     engineRating: 5.0,
//     fairValue: "₹5,27,000",
//     currentPriceOrBid: "₹3,80,000",
//     bidIncrementPrice: "₹3,85,000",
//     timeRemaining: "00:48:30",
//     mainImage: "",
//     gallery: [],
//     listingType: ListingType.auction,
//     documents: {
//       "RC availability": "Yes",
//       "Insurance": "Expired",
//       "Road tax paid": "Valid till 2036",
//     },
//     otherInfo: {
//       "Duplicate key": "Yes",
//       "Chassis number": "Yes",
//       "Engine number": "Yes",
//       "Party-peshi": "No",
//       "Pollution Norm": "Euro 6 (Bharat Stage VI)",
//     },
//     registrationInfo: {
//       "Manufacturing date": "2021",
//       "Registration date": "2021",
//       "RTO code": "TN09",
//       "RTO name": "Chennai (west) Rto",
//       "Fitness report": "Valid till 2036",
//     },
//     structureChecks: [
//       InspectionDefect(
//           title: "Apron, Dickey, Pillar, Cowl top, Right quarter panel",
//           isPassed: true),
//       InspectionDefect(
//           title: "Left quarter panel", subtitle: "Scratch, Repainted"),
//     ],
//     otherComponentsChecks: [
//       InspectionDefect(
//           title: "Fire wall, Lower member, Right running board",
//           isPassed: true),
//     ],
//     windshieldChecks: [
//       InspectionDefect(
//           title: "Svms, Headlights, Tail lights, Windshield", isPassed: true),
//     ],
//     engineChecks: [
//       InspectionDefect(
//           title: "Clutch, Engine, Exhaust smoke, Engine mounting",
//           isPassed: true),
//     ],
//     exteriorPanelsChecks: [
//       InspectionDefect(
//           title: "Roof, Bonnet, Dickey door, Right fender", isPassed: true),
//     ],
//     tyresChecks: [
//       InspectionDefect(title: "Front left tyre", subtitle: "35% integrity"),
//     ],
//     electricalsChecks: [
//       InspectionDefect(
//           title: "Airbag, Car key, Steering mounted controls", isPassed: true),
//     ],
//     steeringChecks: [
//       InspectionDefect(title: "ABS, Brakes", isPassed: true),
//       InspectionDefect(
//           title: "Steering", subtitle: "Abnormal noise", hasVideo: true),
//     ],
//   ),
//   const VehicleModel(
//     id: "6041331",
//     title: "2016 Alto K10 VXi",
//     location: "CHENNAI",
//     rtoCode: "TN14",
//     specs: "Petrol • Manual • 72.1K km • 2nd owner",
//     exteriorRating: 3.5,
//     engineRating: 4.0,
//     fairValue: "₹2,75,000",
//     currentPriceOrBid: "₹2,43,000",
//     bidIncrementPrice: "₹2,29,000",
//     timeRemaining: "00:02:43",
//     mainImage: "",
//     gallery: [],
//     listingType: ListingType.oneClickBuy,
//     documents: {
//       "RC availability": "Yes",
//       "Insurance": "Valid till Dec 2026",
//       "Road tax paid": "Valid till 2031",
//     },
//     otherInfo: {
//       "Duplicate key": "No",
//       "Chassis number": "Yes",
//       "Engine number": "Yes",
//       "Party-peshi": "No",
//       "Pollution Norm": "Euro 4 (Bharat Stage IV)",
//     },
//     registrationInfo: {
//       "Manufacturing date": "2016",
//       "Registration date": "2016",
//       "RTO code": "TN14",
//       "RTO name": "Chennai (south) Rto",
//       "Fitness report": "Valid till 2031",
//     },
//     structureChecks: [
//       InspectionDefect(title: "Apron, Dickey, Pillar", isPassed: true)
//     ],
//     otherComponentsChecks: [
//       InspectionDefect(title: "Fire wall, Lower member", isPassed: true)
//     ],
//     windshieldChecks: [
//       InspectionDefect(title: "Headlights, Windshield", isPassed: true)
//     ],
//     engineChecks: [
//       InspectionDefect(title: "Clutch, Engine Sound", isPassed: true)
//     ],
//     exteriorPanelsChecks: [
//       InspectionDefect(title: "Roof, Bonnet", isPassed: true)
//     ],
//     tyresChecks: [
//       InspectionDefect(title: "Front left tyre", subtitle: "60% integrity")
//     ],
//     electricalsChecks: [
//       InspectionDefect(title: "AC, Blower, Lights", isPassed: true)
//     ],
//     steeringChecks: [
//       InspectionDefect(title: "Steering, Brakes", isPassed: true)
//     ],
//   ),
// ];
