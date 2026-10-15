class EventResponseModel {
  final EventDataModel? data;
  final bool success;
  final String message;

  EventResponseModel({
    this.data,
    required this.success,
    required this.message,
  });

  factory EventResponseModel.fromJson(Map<String, dynamic> json) {
    return EventResponseModel(
      data: json['data'] != null ? EventDataModel.fromJson(json['data']) : null,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class EventDataModel {
  final int totalVehiclesCount;
  final List<EventModel> events;

  EventDataModel({
    required this.totalVehiclesCount,
    required this.events,
  });

  factory EventDataModel.fromJson(Map<String, dynamic> json) {
    return EventDataModel(
      totalVehiclesCount: json['totalVehiclesCount'] ?? 0,
      events: (json['events'] as List<dynamic>?)
              ?.map((item) => EventModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class EventModel {
  final String id;
  final String? eventId;
  final int? lenderId;
  final String lenderName;
  final EventCategoryModel? category;
  final String mode;
  final String status;
  final int auctionStartDate;
  final int auctionEndDate;
  final int? stateId;
  final String stateName;
  final EventVehicleDocumentModel? vehicleDetailsDocument;
  final int soldVehiclesCount;
  final int unsoldVehiclesCount;
  final int totalVehiclesCount;
  final int? userId;
  final dynamic displayFlag;
  final int? updatedAt;
  final int? createdAt;

  EventModel({
    required this.id,
    this.eventId,
    this.lenderId,
    required this.lenderName,
    this.category,
    required this.mode,
    required this.status,
    required this.auctionStartDate,
    required this.auctionEndDate,
    this.stateId,
    required this.stateName,
    this.vehicleDetailsDocument,
    required this.soldVehiclesCount,
    required this.unsoldVehiclesCount,
    required this.totalVehiclesCount,
    this.userId,
    this.displayFlag,
    this.updatedAt,
    this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      eventId: json['eventId'],
      lenderId: json['lenderId'],
      lenderName: json['lenderName'] ?? '',
      category: json['category'] != null
          ? EventCategoryModel.fromJson(json['category'])
          : null,
      mode: json['mode'] ?? '',
      status: json['status'] ?? '',
      auctionStartDate: json['auctionStartDate'] ?? 0,
      auctionEndDate: json['auctionEndDate'] ?? 0,
      stateId: json['stateId'],
      stateName: json['stateName'] ?? '',
      vehicleDetailsDocument: json['vehicleDetailsDocument'] != null
          ? EventVehicleDocumentModel.fromJson(json['vehicleDetailsDocument'])
          : null,
      soldVehiclesCount: json['soldVehiclesCount'] ?? 0,
      unsoldVehiclesCount: json['unsoldVehiclesCount'] ?? 0,
      totalVehiclesCount: json['totalVehiclesCount'] ?? 0,
      userId: json['userId'],
      displayFlag: json['displayFlag'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
    );
  }
}

class EventCategoryModel {
  final int id;
  final String code;
  final String name;
  final bool status;

  EventCategoryModel({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
  });

  factory EventCategoryModel.fromJson(Map<String, dynamic> json) {
    return EventCategoryModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? false,
    );
  }
}

class EventVehicleDocumentModel {
  final String url;
  final String type;
  final String fileName;
  final String publicId;

  EventVehicleDocumentModel({
    required this.url,
    required this.type,
    required this.fileName,
    required this.publicId,
  });

  factory EventVehicleDocumentModel.fromJson(Map<String, dynamic> json) {
    return EventVehicleDocumentModel(
      url: json['url'] ?? '',
      type: json['type'] ?? '',
      fileName: json['fileName'] ?? '',
      publicId: json['public_id'] ?? '',
    );
  }
}
