class TryOnResponseModel {
  final String requestId;

  TryOnResponseModel({
    required this.requestId,
  });

  factory TryOnResponseModel.fromJson(Map<String, dynamic> json) {
    return TryOnResponseModel(
      requestId: json['request_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
    };
  }
}



