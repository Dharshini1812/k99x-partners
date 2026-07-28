class Url {
  static const String baseUrl =
      "http://localhost:8080/VEHICLE-CHECK/servlet/api";

//   static const String baseUrl = "https://devvehcheck.k99x.com/servlet/api";

  static const String sendOtp = "$baseUrl/auth/otp/send";
  static const String verifyOtp = "$baseUrl/auth/otp/verify";
  static const String stateUrl =
      "https://dev.k99x.com/servlet/vehicle/getStateList";
  static const String cityUrl =
      "https://dev.k99x.com/servlet/vehicle/getCityList?stateId=";
  static const variantsUrl =
      'https://devvehcheck.k99x.com/servlet/vehicle/getVariants/';
  static const makeUrl =
      'https://devvehcheck.k99x.com/servlet/vehicle/getMakes';
  static const modelUrl =
      'https://devvehcheck.k99x.com/servlet/vehicle/getModels/';
}
