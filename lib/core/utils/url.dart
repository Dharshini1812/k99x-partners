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

  static const uploadUrl = '$baseUrl/dealer/add/media';
  static const getRCDetails = 'https://k99x.com/servlet/vehicle/rc/';
  static const statsUrl = '$baseUrl/dealer/mylisting/stats';
  static const uploadKyc = '$baseUrl//dealer/kyc/submit';
}
