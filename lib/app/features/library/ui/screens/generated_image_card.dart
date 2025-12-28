import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/text_to_image/model/text_to_image_generation_response_model_for_black_forest_label.dart';
import 'package:ginfit/core/core.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class GeneratedImageCard extends StatefulWidget {
  final TextToImageImageGenerationResponseModelForBlackForestLabel image;
  final bool isRealtime;
  const GeneratedImageCard(
      {super.key, required this.image, this.isRealtime = false});

  @override
  State<GeneratedImageCard> createState() => _GeneratedImageCardState();
}

class _GeneratedImageCardState extends State<GeneratedImageCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.router.push(ImageDetailScreenRoute(
          image: widget.image,
          isBase64: widget.image.input?.containsKey('response_format') ?? false,
          imageType: widget.isRealtime ? 'realtime' : 'text_to_image',
        ));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned.fill(
                  child: CachedNetworkImage(
                imageUrl: widget.image.output?.first ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: Theme.of(context).colorScheme.primary,
                    size: 12.h,
                  ),
                ),
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              )),
              // --- DEĞİŞİKLİK BURADA BAŞLIYOR ---
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  // Gradyan etkisinin daha belirgin olması için bir yükseklik veriyoruz.
                  height: 60.h,
                  // Yazıyı gradyan alanının altına hizalıyoruz.
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                    // Aşağıdan yukarıya doğru şeffaflaşan bir gradyan tanımlıyoruz.
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      // Renk geçişinin nasıl olacağını belirtiyoruz.
                      colors: [
                        Colors.black.withOpacity(0.8), // Altta daha opak
                        Colors.transparent, // Üste doğru tamamen şeffaf
                      ],
                      // Gradyanın nerede başlayıp nerede biteceğini kontrol edebilirsiniz.
                      stops: const [0.0, 0.9],
                    ),
                  ),
                  // İçeriğin (yazının) kenarlara olan uzaklığını ayarlıyoruz.
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: Text(
                    widget.isRealtime
                        ? (widget.image.input?['prompt'] ?? '')
                        : widget.image.prompt ?? '',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context.white,
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines:
                        2, // Gradyan alanı büyüdüğü için 2 satıra izin verebiliriz.
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // --- DEĞİŞİKLİK BURADA BİTİYOR ---
            ],
          ),
        ),
      ),
    );
  }
}
