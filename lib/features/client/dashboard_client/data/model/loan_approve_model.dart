// lib/features/client/data/model/loan_approve_model.dart

class LoanApproveRequestModel {
  final String vehicleId;
  final double loanAmount;
  final double interestRate;
  final int tenureMonths;

  LoanApproveRequestModel({
    required this.vehicleId,
    required this.loanAmount,
    required this.interestRate,
    required this.tenureMonths,
  });

  Map<String, dynamic> toJson() => {
        'vehicleId': vehicleId,
        'loanAmount': loanAmount,
        'interestRate': interestRate,
        'tenureMonths': tenureMonths,
      };
}

class LoanApproveResponseModel {
  final bool success;
  final String message;

  LoanApproveResponseModel({
    required this.success,
    required this.message,
  });

  factory LoanApproveResponseModel.fromJson(Map<String, dynamic> json) {
    return LoanApproveResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
