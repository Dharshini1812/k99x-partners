class InspectionItem {
  final String title;
  final String? issue;
  final String? image;
  final bool passed;

  const InspectionItem({
    required this.title,
    this.issue,
    this.image,
    this.passed = false,
  });
}

class VehicleInspectionDetail {
  final String id;
  final String name;
  final String specsSubtitle;
  final String mainImage;
  final List<String> thumbnails;
  final Map<String, double> ratings;
  final Map<String, String> documents;
  final Map<String, String> otherInfo;
  final Map<String, String> registrationInfo;
  final List<InspectionItem> structureDefects;
  final List<InspectionItem> otherComponents;
  final List<InspectionItem> windshieldLights;
  final List<InspectionItem> tyres;

  const VehicleInspectionDetail({
    required this.id,
    required this.name,
    required this.specsSubtitle,
    required this.mainImage,
    required this.thumbnails,
    required this.ratings,
    required this.documents,
    required this.otherInfo,
    required this.registrationInfo,
    required this.structureDefects,
    required this.otherComponents,
    required this.windshieldLights,
    required this.tyres,
  });
}

VehicleInspectionDetail getMockInspectionDetail(String id) {
  return const VehicleInspectionDetail(
    id: "6050027",
    name: "2021 Maruti Suzuki Swift VXi AMT",
    specsSubtitle: "Petrol • Automatic • 89.7k km • 2nd Owner",
    mainImage:
        "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800",
    thumbnails: [
      "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=200",
      "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=200",
      "https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=200",
    ],
    ratings: {
      "Exterior": 4.0,
      "Engine": 5.0,
      "AC": 5.0,
      "Electricals": 5.0,
      "Steering": 4.5,
    },
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
    structureDefects: [
      InspectionItem(
          title: "Apron, Dickey, Pillar, Cowl top, Right quarter panel",
          passed: true),
      InspectionItem(
          title: "Left quarter panel",
          issue: "Scratch, Repainted",
          image:
              "https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=200"),
      InspectionItem(
          title: "Front left leg",
          issue: "Surface level rust",
          image:
              "https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=200"),
    ],
    otherComponents: [
      InspectionItem(
          title:
              "Fire wall, Lower member, Right running board, Headlight supports, Upper member",
          passed: true),
      InspectionItem(
          title: "Dickey",
          issue: "Toolkit not available",
          image:
              "https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=200"),
      InspectionItem(
          title: "Left running board",
          issue: "Dent",
          image:
              "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=200"),
    ],
    windshieldLights: [
      InspectionItem(
          title: "Svms, Headlights, Tail lights, Windshield", passed: true),
      InspectionItem(
          title: "Left tail light",
          issue: "Crack",
          image:
              "https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=200"),
    ],
    tyres: [
      InspectionItem(
          title: "Front left tyre",
          issue: "35% integrity",
          image:
              "https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=200"),
      InspectionItem(
          title: "Front right tyre",
          issue: "40% integrity",
          image:
              "https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=200"),
    ],
  );
}
