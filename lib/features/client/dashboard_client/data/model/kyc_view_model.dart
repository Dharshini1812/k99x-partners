// lib/features/client/data/model/client_kyc_view_model.dart

import 'dart:convert';

class ClientKycViewResponseModel {
  final ClientKycModel? data;
  final bool success;
  final String message;

  ClientKycViewResponseModel({
    required this.data,
    required this.success,
    required this.message,
  });

  factory ClientKycViewResponseModel.fromJson(Map<String, dynamic> json) {
    return ClientKycViewResponseModel(
      data: json['data'] != null ? ClientKycModel.fromJson(json['data']) : null,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class ClientKycModel {
  final String? kycId;
  final String vehicleId;
  final int? dealerId;
  final String? firstName;
  final String? middleInitial;
  final String? lastName;
  final String? suffix;
  final String? address;
  final String? state;
  final String? city;
  final String? pincode;
  final String? mobileNo;
  final String? email;
  final List<String> documentUrls;
  final int? createdAt;
  final KycDocument? aadhaarCard;
  final KycDocument? pancard;

  ClientKycModel({
    this.kycId,
    required this.vehicleId,
    this.dealerId,
    this.firstName,
    this.middleInitial,
    this.lastName,
    this.suffix,
    this.address,
    this.state,
    this.city,
    this.pincode,
    this.mobileNo,
    this.email,
    required this.documentUrls,
    this.createdAt,
    this.aadhaarCard,
    this.pancard,
  });

  factory ClientKycModel.fromJson(Map<String, dynamic> json) {
    return ClientKycModel(
      kycId: json['kycId'],
      vehicleId: json['vehicleId'] ?? '',
      dealerId: json['dealerId'],
      firstName: json['firstName'],
      middleInitial: json['middleInitial'],
      lastName: json['lastName'],
      suffix: json['suffix'],
      address: json['address'],
      state: json['state'],
      city: json['city'],
      pincode: json['pincode'],
      mobileNo: json['mobileNo'],
      email: json['email'],
      documentUrls: _decodeStringList(json['documentUrls']),
      createdAt: json['createdAt'],
      aadhaarCard: _decodeDocument(json['aadhaarCard']),
      pancard: _decodeDocument(json['pancard']),
    );
  }

  /// `documentUrls` arrives as a JSON-encoded STRING (e.g. "[]" or
  /// "[\"url1\",\"url2\"]"), not a real array — decode it, and fall back
  /// to an empty list if it's null/empty/malformed rather than throwing.
  static List<String> _decodeStringList(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// `aadhaarCard`/`pancard` arrive as JSON-encoded STRINGS
  /// (e.g. "{\"fileName\":\"aadhar.jpg\",...}"), not real nested
  /// objects — decode the string first, then parse normally. Returns
  /// null instead of throwing if the field is missing or malformed.
  static KycDocument? _decodeDocument(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return KycDocument.fromJson(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

class KycDocument {
  final String? fileName;
  final String? type;
  final String? url;
  final String? publicId;

  KycDocument({this.fileName, this.type, this.url, this.publicId});

  factory KycDocument.fromJson(Map<String, dynamic> json) {
    return KycDocument(
      fileName: json['fileName'],
      type: json['type'],
      url: json['url'],
      publicId: json['public_id'],
    );
  }
}
