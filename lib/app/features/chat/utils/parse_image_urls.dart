/// Gemini'nin cevabından image URL'lerini çıkarır ve metinden temizler
/// Örnek: imageUrl: "https://firebasestorage..."
/// Returns: (cleanedText, imageUrls)
({String cleanedText, List<String> imageUrls}) parseImageUrls(String text) {
  final List<String> urls = [];

  // "https://" ile başlayan URL'leri yakala
  final regex = RegExp('https://[^\\s"\']+');
  final matches = regex.allMatches(text);

  for (final match in matches) {
    final url = match.group(0);
    if (url != null && url.contains('firebasestorage')) {
      urls.add(url);
    }
  }

  // "imageUrl: ..." satırlarını temizle (hem tam satır hem de inline)
  String cleanedText = text;

  // "imageUrl: https://..." satırlarını kaldır
  cleanedText = cleanedText.replaceAll(
    RegExp(r'imageUrl:\s*https://[^\s"\047]+\s*', multiLine: true),
    '',
  );

  // Birden fazla boş satırı tek satıra indir
  cleanedText = cleanedText.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

  // Başta/sonda boşlukları temizle
  cleanedText = cleanedText.trim();

  return (cleanedText: cleanedText, imageUrls: urls);
}
