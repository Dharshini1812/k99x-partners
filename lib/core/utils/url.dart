class Url {
  static const String baseUrl = "https://dev.k99x.com/servlet/api/";
  static const String base2url = "https://dev.k99x.com/servlet/";
  static const String sendOtp = "$baseUrl/auth/otp/send";
  static const String verifyOtp = "$baseUrl/auth/otp/verify";
  static const String stateUrl = "$base2url/vehicle/getStateList";

  static const String cityUrl = "$base2url/vehicle/getCityList?stateId=";
  static const variantsUrl =
      'https://devvehcheck.k99x.com//servlet/vehicle/getVariants/';
  static const myStockUrl = '$baseUrl/dealer/mylisting';
  static const liveStockUrl = '$baseUrl/dealer/marketing/live-listing';
  static const makeUrl =
      'https://devvehcheck.k99x.com/servlet/vehicle/getMakes';
  static const modelUrl =
      'https://devvehcheck.k99x.com/servlet/vehicle/getModels/';

  static const uploadUrl = '$baseUrl/dealer/vehicle/sell/add/media';
  static const getRCDetails = 'https://k99x.com/servlet/vehicle/rc/';
  static const statsUrl = '$baseUrl/dealer/mylisting/stats';
  static const uploadKyc = '$baseUrl/dealer/kyc/submit';
  static const uploadVehicleW = '$baseUrl/dealer/vehicle/sell/add';
  static const vehicleReviewUrl = '$baseUrl/dealer/vehicle/sell/review';
  static const completeVehicleUrl = '$baseUrl/dealer/vehicle/sell/complete';
  static const editVehicleurl = '$baseUrl/dealer/vehicle/sell/edit';
  static const wantedListUrl = '$baseUrl/dealer/wanted-listing';
  static const addWantedVehicle = '$baseUrl/dealer/wanted-listing/save';
  static const logoutUrl = '$baseUrl/auth/logout';

  //clent

  static const dashboardStatsUrl = '$baseUrl/client/dashboard';
  static const clientStocksUrl = '$baseUrl/client/stocks';
  static const loanApproveUrl = '$baseUrl/client/loan/approve';
  static const clientKycViewUrl = '$baseUrl/client/kyc/view/';
  static const String vehicleReportUrl = "${base2url}dealer/vehicle/report/";
}
