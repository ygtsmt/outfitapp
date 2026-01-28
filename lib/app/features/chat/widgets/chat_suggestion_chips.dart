import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatSuggestionChips extends StatelessWidget {
  final bool hasMedia;
  final Function(String) onChipSelected;

  const ChatSuggestionChips({
    super.key,
    required this.hasMedia,
    required this.onChipSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Media durumuna göre önerileri belirle
    final suggestions = hasMedia
        ? [
            'Bunu benim dolapla yap',
            'Bu stili analiz et',
            'Benzer kombin öner',
            'Bu hangi tarz?',
          ]
        : [
            'Yarın ne giysem?',
            'Haftasonu için rahat kombin',
            'İş görüşmesi için resmi kombin',
            'Siyah ağırlıklı bir şeyler öner',
            'Bugün hava nasıl?',
          ];

    return SizedBox(
      height: 36.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ActionChip(
              label: Text(
                suggestions[index],
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                ),
              ),
              onPressed: () => onChipSelected(suggestions[index]),
            ),
          );
        },
      ),
    );
  }
}
