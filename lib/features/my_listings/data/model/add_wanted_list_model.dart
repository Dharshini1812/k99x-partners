// lib/features/wanted/data/model/wanted_listing_request_model.dart

class WantedListingRequestModel {
  final String vehicleType;
  final String makeName;
  final String modelName;
  final String variantName;
  final double budgetFrom;
  final double budgetTo;
  final String neededBy; // yyyy-MM-dd
  final String notes;

  const WantedListingRequestModel({
    required this.vehicleType,
    required this.makeName,
    required this.modelName,
    required this.variantName,
    required this.budgetFrom,
    required this.budgetTo,
    required this.neededBy,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleType': vehicleType,
      'makeName': makeName,
      'modelName': modelName,
      'variantName': variantName,
      'budgetFrom': budgetFrom,
      'budgetTo': budgetTo,
      'neededBy': neededBy,
      'notes': notes,
    };
  }

  /// If the backend actually expects multipart/form-data rather than a
  /// JSON body, use this instead of toJson() when building the request —
  /// every value has to be a String for form fields.
  Map<String, String> toFormData() {
    return {
      'vehicleType': vehicleType,
      'makeName': makeName,
      'modelName': modelName,
      'variantName': variantName,
      'budgetFrom': budgetFrom.toString(),
      'budgetTo': budgetTo.toString(),
      'neededBy': neededBy,
      'notes': notes,
    };
  }
}

// lib/features/wanted/data/model/wanted_listing_save_response_model.dart

class WantedListingSaveResponseModel {
  final bool success;
  final String message;

  const WantedListingSaveResponseModel({
    required this.success,
    required this.message,
  });

  factory WantedListingSaveResponseModel.fromJson(Map<String, dynamic> json) {
    return WantedListingSaveResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
      };
}
