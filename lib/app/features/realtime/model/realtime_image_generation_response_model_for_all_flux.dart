class RealtimeImageGenerationResponseModelForAllFlux {
  final String base64Image;

  RealtimeImageGenerationResponseModelForAllFlux({required this.base64Image});

  factory RealtimeImageGenerationResponseModelForAllFlux.fromJson(
      Map<String, dynamic> json) {
    return RealtimeImageGenerationResponseModelForAllFlux(
      base64Image: json['data'][0]['b64_json'],
    );
  }
}
