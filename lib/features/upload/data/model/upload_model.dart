// lib/features/upload/data/model/upload_model.dart
//
// CHANGED from your original: `data` was typed `Null`, so a successful
// response's payload — including the uploaded file's URL — was silently
// discarded. It's now a proper UploadMediaData? with a `url` field.
//
// ADAPT: if your backend's `data` object uses a different key than
// "url" (e.g. "imageUrl", "fileUrl", "path"), change the one line
// marked below in UploadMediaData.fromJson — nothing else needs to
// change.

class UploadModel {
  bool? success;
  String? message;
  UploadMediaData? data;
  int? statusCode;
  dynamic meta;

  UploadModel({
    this.success,
    this.message,
    this.data,
    this.statusCode,
    this.meta,
  });

  UploadModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? UploadMediaData.fromJson(json['data'] as Map<String, dynamic>)
        : null;
    statusCode = json['statusCode'];
    meta = json['meta'];
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'statusCode': statusCode,
      'meta': meta,
    };
  }
}

class UploadMediaData {
  String? url;

  UploadMediaData({this.url});

  UploadMediaData.fromJson(Map<String, dynamic> json) {
    url = json['url']; // ADAPT: change 'url' here if your API key differs
  }

  Map<String, dynamic> toJson() => {'url': url};
}
