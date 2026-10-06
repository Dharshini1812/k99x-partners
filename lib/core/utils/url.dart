// Reconstructed from the Url class you pasted earlier in this conversation
// (not from an uploaded file this time) — diff this against your actual
// current file before replacing it, in case anything's changed since.
//
// The only change: every constant that was built as "$baseUrl/..." or
// "$base2url/..." (an extra literal slash right after a variable that
// already ends in "/") had that redundant slash removed. Constants that
// were already correct (built as '${baseUrl}...' with no following slash)
// are untouched.
//
// lenderListUrl was actually a TRIPLE slash ('$base2url//vehicle/...') —
// fixed to a single slash like the rest.

class Url {
  static const String baseUrl = "https://dev.k99x.com/servlet/api/";
  static const String base2url = "https://dev.k99x.com/servlet/";
  // static const String baseUrl = "https://k99x.com/servlet/api/";
  // static const String base2url = "https://k99x.com/servlet/";
  static const String sendOtp = "${baseUrl}auth/otp/send";
  static const String verifyOtp = "${baseUrl}auth/otp/verify";
  static const String stateUrl = "${base2url}vehicle/getStateList";

  static const String cityUrl = "${base2url}vehicle/getCityList?stateId=";

  static const myStockUrl = '${baseUrl}dealer/mylisting';
  static const liveStockUrl = '${baseUrl}dealer/marketing/live-listing';
  static const makeUrl = '${base2url}vehicle/getMakes';
  static const modelUrl = '${base2url}vehicle/getModels/';
  static const variantsUrl = '${base2url}vehicle/getVariants/';

  static const uploadUrl = '${baseUrl}dealer/vehicle/sell/add/media';
  static const getRCDetails = 'https://k99x.com/servlet/vehicle/rc/';
  static const statsUrl = '${baseUrl}dealer/mylisting/stats';
  static const uploadKyc = '${baseUrl}dealer/kyc/submit';
  static const uploadVehicleW = '${baseUrl}dealer/vehicle/sell/add';
  static const vehicleReviewUrl = '${baseUrl}dealer/vehicle/sell/review';
  static const completeVehicleUrl = '${baseUrl}dealer/vehicle/sell/complete';
  static const editVehicleurl = '${baseUrl}dealer/vehicle/sell/edit';
  static const wantedListUrl = '${baseUrl}dealer/wanted-listing';
  static const addWantedVehicle = '${baseUrl}dealer/wanted-listing/save';
  static const lenderListUrl = '${base2url}vehicle/getLenderList';
  static const logoutUrl = '${baseUrl}auth/logout';
  static const auctionUrl = '${base2url}admin/live-auction/';
  static const liveAuctionUrl = '${auctionUrl}auction-live/json';
  static const placeBidUrl = '${base2url}api/dealer/bid/placeBid/';
  static const autoBidUrl = '${base2url}api/dealer/bid/autobid/';
  static const activityUrl = '${base2url}api/dealer/bid/activity/';
  static const vehicleDetailView = '${baseUrl}dealer/bid/view/';
  static const String liveAuctionVehiclesUrl =
      '${baseUrl}api/admin/live-auction/vehicles';
  static const String registerUrl = '${baseUrl}auth/register';

  //clent

  static const dashboardStatsUrl = '${baseUrl}client/dashboard';
  static const clientStocksUrl = '${baseUrl}client/stocks';
  static const loanApproveUrl = '${baseUrl}client/loan/approve';
  static const clientKycViewUrl = '${baseUrl}client/kyc/view/';
  static const String vehicleReportUrl = "${base2url}dealer/vehicle/report/";
}
