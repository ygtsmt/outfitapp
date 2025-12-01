import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/bloc/app_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DashBoardSliderWidget extends StatelessWidget {
  final String text;
  final String previewUrl;
  final void Function()? onTap;
  final double? aspectRatio;

  const DashBoardSliderWidget({
    Key? key,
    required this.text,
    required this.previewUrl,
    required this.onTap,
    this.aspectRatio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: onTap,
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            return Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                AspectRatio(
                  aspectRatio: aspectRatio ?? 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Image.network(
                          previewUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : Center(
                                      child: LoadingAnimationWidget
                                          .fourRotatingDots(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        size: 24.h,
                                      ),
                                    ),
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),

                        // Gölge efekti
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.9),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4.h,
                          left: 4.w,
                          child: Text(
                            text,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
