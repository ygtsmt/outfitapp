class TextToImageImageGenerationResponseModelForAllFlux {
  final String base64Image;

  TextToImageImageGenerationResponseModelForAllFlux({required this.base64Image});

  factory TextToImageImageGenerationResponseModelForAllFlux.fromJson(
      Map<String, dynamic> json) {
    return TextToImageImageGenerationResponseModelForAllFlux(
      base64Image: json['data'][0]['b64_json'],
    );
  }
}
