import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/bloc/app_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DashBoardCustomCreateCardWidget extends StatelessWidget {
  final String text;
  final String assetPath;
  final String? networkImageUrl; // Opsiyonel network image
  final void Function()? onTap;
  final double? aspectRatio;
  const DashBoardCustomCreateCardWidget({
    Key? key,
    required this.text,
    required this.assetPath,
    required this.onTap,
    this.aspectRatio,
    this.networkImageUrl, // Yeni parametre
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onInverseSurface,
            borderRadius: BorderRadius.circular(8)),
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                      child: AspectRatio(
                        aspectRatio: aspectRatio ?? (1 / 1),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.circular(16),
                          ),
                          child: networkImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: networkImageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child:
                                        LoadingAnimationWidget.fourRotatingDots(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 12.h,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    assetPath,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  assetPath,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
