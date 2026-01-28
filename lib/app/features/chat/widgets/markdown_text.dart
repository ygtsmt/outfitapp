import 'package:flutter/material.dart';

/// Basit markdown bold parser widget
/// **text** formatındaki metinleri bold yapar
class MarkdownText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const MarkdownText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ?? const TextStyle();
    final spans = _parseMarkdown(text, defaultStyle);

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }

  /// Markdown'ı parse edip TextSpan listesi döner
  List<TextSpan> _parseMarkdown(String text, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final lines = text.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isLastLine = i == lines.length - 1;

      if (line.trim().startsWith('### ')) {
        // --- HEADER (###) ---
        final headerText = line.trim().substring(4); // "### " sil
        spans.add(TextSpan(
          text: headerText + (isLastLine ? '' : '\n'),
          style: baseStyle.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: (baseStyle.fontSize ?? 14) * 1.3, // Biraz büyüt
            height: 1.5, // Satır arası boşluk
          ),
        ));
      } else {
        // --- NORMAL SATIR (Bold kontrolü yap) ---
        spans.addAll(_parseBold(line, baseStyle));
        if (!isLastLine) {
          spans.add(TextSpan(text: '\n'));
        }
      }
    }
    return spans;
  }

  /// Satır içindeki bold (**text**) ifadeleri parseler
  List<TextSpan> _parseBold(String text, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(fontWeight: FontWeight.bold),
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }
    return spans;
  }
}
